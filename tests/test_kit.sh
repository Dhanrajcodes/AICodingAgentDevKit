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
for f in "$K"/rules/*.md "$K"/playbooks/*.md; do
  n=$(wc -l < "$f" | tr -d ' ')
  [ "$n" -le 150 ] && ok || bad "$(basename "$f") is $n lines (> 150)"
done

CASE=index-links
for p in $(grep -o '\(rules\|playbooks\|templates\)/[A-Za-z-]*\.md' "$K/INDEX.md" | sort -u); do
  assert_file "$K/$p"
done
for f in "$K"/rules/*.md "$K"/playbooks/*.md; do
  rel=${f#"$K/"}
  grep -qF "$rel" "$K/INDEX.md" && ok || bad "$rel not listed in INDEX.md"
done

CASE=cross-refs
for p in $(cat "$K"/rules/*.md "$K"/playbooks/*.md "$K/templates/AGENTS.md" | grep -o '\(rules\|playbooks\|templates\)/[a-z-]*\.md' | sort -u); do
  assert_file "$K/$p"
done

CASE=license-copy
assert_same "$K/LICENSE" "$ROOT/LICENSE"

CASE=version
grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$' "$K/VERSION" && ok || bad "VERSION not semver"

summary
