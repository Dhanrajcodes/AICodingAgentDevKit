#!/bin/sh
# AI Coding Agent Dev Kit installer (macOS, Linux, Git Bash on Windows).
# Usage: sh install.sh [--dry-run] TARGET
# Installing again is the update: it replaces .agentkit/ and the marked block
# in AGENTS.md, and never touches your own files.
# Copyright (c) 2026 Dhanraj Singh. See LICENSE.
set -eu

usage() {
  echo "usage: sh install.sh [--dry-run] TARGET" >&2
  echo "  TARGET  workspace folder to install into (must exist)" >&2
  exit 2
}

DRY=0
TARGET=""
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY=1 ;;
    -h|--help) usage ;;
    -*) echo "unknown option: $arg" >&2; usage ;;
    *) [ -z "$TARGET" ] || usage; TARGET=$arg ;;
  esac
done
[ -n "$TARGET" ] || usage
[ -d "$TARGET" ] || { echo "error: target folder not found: $TARGET" >&2; exit 2; }

SRC=$(cd "$(dirname "$0")/kit" && pwd)
KIT="$SRC/.agentkit"
TPL="$KIT/templates"
VERSION=$(tr -d '\r\n' < "$KIT/VERSION")
START='<!-- agentkit:start -->'
END='<!-- agentkit:end -->'

say() { if [ "$DRY" -eq 1 ]; then echo "would: $*"; else echo "$*"; fi; }

# 1. Guard: never delete a .agentkit folder that isn't ours.
if [ -d "$TARGET/.agentkit" ] && [ ! -f "$TARGET/.agentkit/VERSION" ]; then
  echo "error: $TARGET/.agentkit exists but is not a kit install (no VERSION file)." >&2
  echo "Move or rename it, then run the installer again. Nothing was changed." >&2
  exit 3
fi

# 2. Kit core: replace whole.
if [ -d "$TARGET/.agentkit" ]; then action=updated; else action=created; fi
if [ "$DRY" -eq 0 ]; then
  rm -rf "$TARGET/.agentkit"
  cp -R "$KIT" "$TARGET/.agentkit"
fi
say "$action .agentkit/ (v$VERSION)"

# has_markers FILE -> 0 if exactly one start marker followed later by one end marker
has_markers() {
  tr -d '\r' < "$1" | awk -v s="$START" -v e="$END" '
    $0 == s { ns++; if (ne == 0) sl = NR }
    $0 == e { ne++; el = NR }
    END { exit !(ns == 1 && ne == 1 && sl < el) }'
}

# 3. AGENTS.md
A="$TARGET/AGENTS.md"
if [ ! -f "$A" ]; then
  [ "$DRY" -eq 1 ] || cp "$TPL/AGENTS.md" "$A"
  say "created AGENTS.md"
elif has_markers "$A"; then
  if [ "$DRY" -eq 0 ]; then
    tmp="$A.agentkit-tmp"
    # Keep the target's line endings outside the block; write the new block in the same style.
    if grep -q "$(printf '\r')" "$A"; then cr=1; else cr=0; fi
    tr -d '\r' < "$A" | awk -v s="$START" -v e="$END" -v blk="$TPL/AGENTS.md" '
      BEGIN { while ((getline l < blk) > 0) { sub(/\r$/, "", l); if (l == s) inb = 1; if (inb) b = b l "\n"; if (l == e) inb = 0 } }
      $0 == s { printf "%s", b; skip = 1; next }
      $0 == e { skip = 0; next }
      !skip { print }' > "$tmp"
    if [ "$cr" -eq 1 ]; then sed 's/$/\r/' "$tmp" > "$tmp.2" && mv "$tmp.2" "$tmp"; fi
    mv "$tmp" "$A"
  fi
  say "updated kit block in AGENTS.md"
else
  say "adopt AGENTS.md: no kit markers; see .agentkit/playbooks/adopt.md"
fi

# 4. Tool stubs
for stub in CLAUDE.md GEMINI.md; do
  f="$TARGET/$stub"
  if [ ! -f "$f" ]; then
    [ "$DRY" -eq 1 ] || cp "$TPL/stub.md" "$f"
    say "created $stub"
  elif grep -qF '@AGENTS.md' "$f"; then
    say "kept $stub"
  else
    say "adopt $stub: has its own content; see .agentkit/playbooks/adopt.md"
  fi
done

# seed SRC DEST_REL -> copy only if missing
seed() {
  dest="$TARGET/$2"
  if [ -e "$dest" ]; then say "kept $2"; return; fi
  if [ "$DRY" -eq 0 ]; then
    mkdir -p "$(dirname "$dest")"
    if [ -n "$1" ]; then cp "$1" "$dest"; else : > "$dest"; fi
  fi
  say "created $2"
}

# 5. User-owned seeds (created once, never overwritten)
for f in README.md overrides.md budgets.env; do
  seed "$SRC/.agentkit.local/$f" ".agentkit.local/$f"
done
seed "$TPL/status.md"          docs/agent/STATUS.md
seed "$TPL/log.md"             docs/agent/LOG.md
seed "$TPL/decisions-index.md" docs/agent/DECISIONS.md
seed "$TPL/open-questions.md"  docs/agent/OPEN-QUESTIONS.md
for d in decisions plans research log; do
  seed "" "docs/agent/$d/.gitkeep"
done

echo ""
if [ "$DRY" -eq 1 ]; then
  echo "Dry run: nothing was changed."
else
  echo "Kit v$VERSION installed in $TARGET."
  echo "Next: open the workspace in your AI tool and say \"start a session\"."
  echo "Check health any time: sh .agentkit/doctor.sh"
fi
