#!/usr/bin/env bash
# Token-budget and consistency checks on the kit payload itself.
SUITE=kit
. "$(dirname "$0")/lib.sh"
K="$ROOT/kit/.agentkit"

CASE=ring0-budget
bytes=$(cat "$K/templates/AGENTS.md" "$K/templates/status.md" "$K/templates/decisions-index.md" | wc -c | tr -d ' ')
[ "$bytes" -le 8192 ] && ok || bad "fresh ring 0 is $bytes bytes (> 8192)"

CASE=kit-block-lines
n=$(sed -n '/agentkit:start/,/agentkit:end/p' "$K/templates/AGENTS.md" | wc -l | tr -d ' ')
[ "$n" -le 70 ] && ok || bad "kit block is $n lines (> 70)"

CASE=file-lines
for f in "$K"/rules/*.md "$K"/playbooks/*.md "$K"/security/*.md "$K"/security/checklists/*.md; do
  n=$(wc -l < "$f" | tr -d ' ')
  [ "$n" -le 150 ] && ok || bad "$(basename "$f") is $n lines (> 150)"
done

CASE=index-links
for p in $(grep -o '\(rules\|playbooks\|templates\|security\)/[A-Za-z/-]*\.md' "$K/INDEX.md" | sort -u); do
  assert_file "$K/$p"
done
for f in "$K"/rules/*.md "$K"/playbooks/*.md "$K"/security/*.md "$K"/security/checklists/*.md; do
  rel=${f#"$K/"}
  grep -qF "$rel" "$K/INDEX.md" && ok || bad "$rel not listed in INDEX.md"
done

CASE=cross-refs
for p in $(cat "$K"/rules/*.md "$K"/playbooks/*.md "$K"/security/*.md "$K"/security/checklists/*.md "$K/templates/AGENTS.md" | grep -o '\(docs/agent/\)\{0,1\}\(rules\|playbooks\|templates\|security\)/[a-z/-]*\.md' | grep -v '^docs/agent/' | sort -u); do
  assert_file "$K/$p"
done
# Checklist names referenced from inside security/ (relative, e.g. `checklists/api-input.md` or `api-input.md`)
for p in $(cat "$K"/security/*.md | grep -o '`checklists/[a-z-]*\.md`' | tr -d '`' | sort -u); do
  assert_file "$K/security/$p"
done
for p in $(cat "$K"/security/checklists/*.md | grep -o '`[a-z-]*\.md`' | tr -d '`' | sort -u); do
  assert_file "$K/security/checklists/$p"
done

CASE=license-copy
assert_same "$K/LICENSE" "$ROOT/LICENSE"

CASE=version
grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$' "$K/VERSION" && ok || bad "VERSION not semver"

CASE=no-hidden-unicode
UPAT=$(printf '\363\240\200\n\363\240\201\n\342\200\213\n\342\200\214\n\342\200\215\n\342\200\216\n\342\200\217\n\342\201\240\n\342\200\252\n\342\200\253\n\342\200\254\n\342\200\255\n\342\200\256\n\342\201\246\n\342\201\247\n\342\201\250\n\342\201\251')
found=$(LC_ALL=C grep -rlF -e "$UPAT" "$ROOT/kit" "$ROOT/install.sh" "$ROOT/install.ps1" "$ROOT/INSTALL.md" "$ROOT/AGENTS.md" 2>/dev/null)
[ -z "$found" ] && ok || bad "hidden unicode in: $found"

CASE=ps1-ascii
for f in "$ROOT"/install.ps1 "$ROOT"/kit/.agentkit/doctor.ps1 "$ROOT"/tests/*.ps1; do
  n=$(LC_ALL=C tr -d '\000-\177' < "$f" | wc -c | tr -d ' ')
  [ "$n" -eq 0 ] && ok || bad "$(basename "$f") has $n non-ASCII bytes"
done

CASE=example-workspace
EX="$ROOT/examples/sample-workspace"
a=$(sed -n '/agentkit:start/,/agentkit:end/p' "$EX/AGENTS.md"); b=$(sed -n '/agentkit:start/,/agentkit:end/p' "$K/templates/AGENTS.md")
[ "$a" = "$b" ] && ok || bad "example kit block differs from templates/AGENTS.md"
w="$TMP_ROOT/example copy"; rm -rf "$w"; mkdir -p "$TMP_ROOT"; cp -R "$EX" "$w"
out=$(sh "$ROOT/install.sh" "$w" 2>&1)
assert_contains "$out" "kept docs/agent/STATUS.md" "example memory kept"
assert_contains "$out" "updated kit block in AGENTS.md" "example block refreshed"
assert_same "$w/docs/agent/STATUS.md" "$EX/docs/agent/STATUS.md"
dout=$(sh "$w/.agentkit/doctor.sh" "$w" 2>&1); dcode=$?
assert_eq "$dcode" 0 "doctor clean on example: $dout"

summary
