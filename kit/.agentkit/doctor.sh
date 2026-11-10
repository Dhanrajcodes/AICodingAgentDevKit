#!/bin/sh
# AI Coding Agent Dev Kit doctor: checks memory sizes, stale status, stubs and secrets.
# Usage: sh .agentkit/doctor.sh [WORKSPACE]   (default: the folder that holds .agentkit/)
# Exit 0 when clean, 1 when there are warnings. Budgets: .agentkit.local/budgets.env
# Copyright (c) 2026 Dhanraj Singh. See LICENSE.
set -u

W=${1:-"$(dirname "$0")/.."}
[ -d "$W" ] || { echo "error: workspace not found: $W" >&2; exit 2; }
M="$W/docs/agent"

RING0_MAX_BYTES=8192
AGENTS_MAX_LINES=120
STATUS_MAX_LINES=40
DECISIONS_MAX_LINES=80
LOG_MAX_BYTES=24576
B="$W/.agentkit.local/budgets.env"
if [ -f "$B" ]; then
  # Only accept KEY=NUMBER lines for known keys; never execute the file.
  for k in RING0_MAX_BYTES AGENTS_MAX_LINES STATUS_MAX_LINES DECISIONS_MAX_LINES LOG_MAX_BYTES; do
    v=$(tr -d '\r' < "$B" | sed -n "s/^[[:space:]]*$k=\([0-9]\{1,18\}\)[[:space:]]*\(#.*\)\{0,1\}\$/\1/p" | tail -n 1)
    [ -n "$v" ] && eval "$k=$v"
  done
fi

WARN=0
ok()   { echo "ok   $1"; }
warn() { echo "warn $1: $2"; WARN=$((WARN + 1)); }
bytes() { if [ -f "$1" ]; then wc -c < "$1" | tr -d ' '; else echo 0; fi; }
nlines() { if [ -f "$1" ]; then tr -d '\r' < "$1" | wc -l | tr -d ' '; else echo 0; fi; }

# kit-installed
if [ -f "$W/.agentkit/VERSION" ]; then ok kit-installed
else warn kit-installed ".agentkit/VERSION missing; reinstall the kit"; fi

# kit-markers
A="$W/AGENTS.md"
# Same rule as the installer: exactly one start marker before exactly one end marker.
if [ -f "$A" ] && tr -d '\r' < "$A" | awk '
    $0 == "<!-- agentkit:start -->" { ns++; if (ne == 0) sl = NR }
    $0 == "<!-- agentkit:end -->"   { ne++; el = NR }
    END { exit !(ns == 1 && ne == 1 && sl < el) }'; then ok kit-markers
else warn kit-markers "AGENTS.md missing, or its kit markers are missing or duplicated, so updates can't refresh it; see .agentkit/playbooks/adopt.md"; fi

# stubs
for pair in claude:CLAUDE.md gemini:GEMINI.md; do
  label="stub-${pair%%:*}"; f="${pair#*:}"
  if [ -f "$W/$f" ] && grep -qF '@AGENTS.md' "$W/$f"; then ok "$label"
  else warn "$label" "$f missing or doesn't import @AGENTS.md"; fi
done

# ring0-size
r0=$(( $(bytes "$A") + $(bytes "$M/STATUS.md") + $(bytes "$M/DECISIONS.md") ))
if [ "$r0" -le "$RING0_MAX_BYTES" ]; then ok ring0-size
else warn ring0-size "AGENTS.md + STATUS.md + DECISIONS.md = $r0 bytes (budget $RING0_MAX_BYTES); run .agentkit/playbooks/compact.md"; fi

# line budgets
check_lines() { # label file max
  n=$(nlines "$2")
  if [ "$n" -le "$3" ]; then ok "$1"
  else warn "$1" "${2#"$W/"} has $n lines (budget $3); run .agentkit/playbooks/compact.md"; fi
}
check_lines agents-lines "$A" "$AGENTS_MAX_LINES"
check_lines status-lines "$M/STATUS.md" "$STATUS_MAX_LINES"
check_lines decisions-lines "$M/DECISIONS.md" "$DECISIONS_MAX_LINES"

# log-size
lb=$(bytes "$M/LOG.md")
if [ "$lb" -le "$LOG_MAX_BYTES" ]; then ok log-size
else warn log-size "LOG.md is $lb bytes (budget $LOG_MAX_BYTES); rotate old months with .agentkit/playbooks/compact.md"; fi

# status-fresh: newest LOG entry date must not be after STATUS "Last updated"
sd=$( [ -f "$M/STATUS.md" ] && tr -d '\r' < "$M/STATUS.md" | sed -n 's/^Last updated: \([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\).*/\1/p' | head -n 1)
ld=$( [ -f "$M/LOG.md" ] && tr -d '\r' < "$M/LOG.md" | sed -n 's/^## \([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\).*/\1/p' | sort | tail -n 1)
sdn=$(printf '%s' "${sd:-}" | tr -d '-'); ldn=$(printf '%s' "${ld:-}" | tr -d '-')
if [ -z "$ldn" ]; then ok status-fresh
elif [ -z "$sdn" ]; then warn status-fresh "STATUS.md has no 'Last updated: YYYY-MM-DD' line but LOG.md has entries; run .agentkit/playbooks/handoff.md"
elif [ "$ldn" -gt "$sdn" ]; then warn status-fresh "STATUS.md last updated $sd, but LOG.md has an entry from $ld; run .agentkit/playbooks/handoff.md"
else ok status-fresh; fi

# tracker-single-doing
multi=""
if [ -d "$M/plans" ]; then
  for f in "$M"/plans/*/tracker.md; do
    [ -f "$f" ] || continue
    n=$(tr -d '\r' < "$f" | grep -cE '\|[[:space:]]*doing[[:space:]]*\|')
    [ "$n" -gt 1 ] && multi="$multi ${f#"$W/"}($n)"
  done
fi
if [ -z "$multi" ]; then ok tracker-single-doing
else warn tracker-single-doing "more than one 'doing' task in:$multi"; fi

# no-secrets (file names only, never the match)
# Key prefixes need a left boundary so words like "task-tracking-..." don't match.
PAT='(^|[^A-Za-z0-9_-])(sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{30,}|AIza[0-9A-Za-z_-]{35}|xox[baprs]-[A-Za-z0-9-]{10,})|-----BEGIN [A-Z ]*PRIVATE KEY-----'
hits=""
for d in "$W/AGENTS.md" "$W/CLAUDE.md" "$W/GEMINI.md" "$M" "$W/.agentkit.local"; do
  [ -e "$d" ] || continue
  hits="$hits$(grep -rlE -- "$PAT" "$d" 2>/dev/null | while IFS= read -r f; do printf ' %s' "${f#"$W/"}"; done)"
done
if [ -z "$hits" ]; then ok no-secrets
else warn no-secrets "possible secret in:$hits (remove it and rotate the key)"; fi

# env-ignored: .env files inside a git repo must be git-ignored (templates like .env.example are fine)
unignored=""
if command -v git >/dev/null 2>&1; then
  unignored=$(find "$W" -maxdepth 3 \( -name node_modules -o -name .git -o -name .venv \) -prune -o \
      -type f -name '.env*' -print 2>/dev/null | while IFS= read -r f; do
    case "${f##*/}" in .env.example|.env.sample|.env.template|.env.dist) continue ;; esac
    d=$(dirname "$f")
    git -C "$d" rev-parse --is-inside-work-tree >/dev/null 2>&1 || continue
    git -C "$d" check-ignore -q "$f" 2>/dev/null || printf ' %s' "${f#"$W/"}"
  done)
fi
if [ -z "$unignored" ]; then ok env-ignored
else warn env-ignored "not git-ignored, could be committed:$unignored (add to .gitignore)"; fi

# no-hidden-unicode: invisible characters that can hide instructions in agent files
# (Unicode tag characters, zero-width characters, bidirectional controls). One grep, fixed byte patterns.
UPAT=$(printf '\363\240\200\n\363\240\201\n\342\200\213\n\342\200\214\n\342\200\215\n\342\200\216\n\342\200\217\n\342\201\240\n\342\200\252\n\342\200\253\n\342\200\254\n\342\200\255\n\342\200\256\n\342\201\246\n\342\201\247\n\342\201\250\n\342\201\251')
hits_u=$( {
  find "$W" -maxdepth 1 -type f \( -name AGENTS.md -o -name CLAUDE.md -o -name GEMINI.md \) -exec env LC_ALL=C grep -lF -e "$UPAT" {} +
  for d in "$W/.agentkit.local" "$M"; do [ -d "$d" ] && find "$d" -type f -exec env LC_ALL=C grep -lF -e "$UPAT" {} +; done
} 2>/dev/null | while IFS= read -r f; do printf ' %s' "${f#"$W/"}"; done )
if [ -z "$hits_u" ]; then ok no-hidden-unicode
else warn no-hidden-unicode "invisible or bidi characters in:$hits_u (could hide instructions; inspect and remove)"; fi

echo "doctor: $WARN warning(s)"
[ "$WARN" -eq 0 ]
