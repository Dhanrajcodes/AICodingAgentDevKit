#!/usr/bin/env bash
# Tests for install.sh. Run via tests/run.sh.
SUITE=install.sh
. "$(dirname "$0")/lib.sh"
INSTALL="$ROOT/install.sh"
TPL="$ROOT/kit/.agentkit/templates"

CASE=fresh
t=$(mktarget "fresh ws")
out=$(sh "$INSTALL" "$t" 2>&1); code=$?
assert_eq "$code" 0 "exit"
for f in .agentkit/VERSION .agentkit/INDEX.md AGENTS.md CLAUDE.md GEMINI.md \
         .agentkit.local/overrides.md .agentkit.local/budgets.env \
         docs/agent/STATUS.md docs/agent/LOG.md docs/agent/DECISIONS.md docs/agent/OPEN-QUESTIONS.md \
         docs/agent/plans/.gitkeep docs/agent/decisions/.gitkeep docs/agent/research/.gitkeep docs/agent/log/.gitkeep; do
  assert_file "$t/$f"
done
assert_same "$t/AGENTS.md" "$TPL/AGENTS.md"
assert_same "$t/CLAUDE.md" "$TPL/stub.md"
assert_same "$t/docs/agent/STATUS.md" "$TPL/status.md"
assert_contains "$out" "created .agentkit/ (v" "first install"
assert_contains "$out" "created AGENTS.md" "agents"
assert_contains "$out" "created docs/agent/STATUS.md" "status"

CASE=rerun
printf 'MINE\n' >> "$t/docs/agent/STATUS.md"
printf 'PROJECT-NOTE\n' >> "$t/AGENTS.md"
printf 'stale\n' > "$t/.agentkit/stale.md"
out=$(sh "$INSTALL" "$t" 2>&1); code=$?
assert_eq "$code" 0 "exit"
assert_file_has "$t/docs/agent/STATUS.md" "MINE"
assert_file_has "$t/AGENTS.md" "PROJECT-NOTE"
assert_no_file "$t/.agentkit/stale.md"
assert_contains "$out" "updated .agentkit/ (v" "update"
assert_contains "$out" "kept docs/agent/STATUS.md" "status kept"
assert_contains "$out" "updated kit block in AGENTS.md" "block"
assert_contains "$out" "kept CLAUDE.md" "stub kept"

CASE=block-refresh
sedi 's/Read this first./OLD TEXT/' "$t/AGENTS.md"
sh "$INSTALL" "$t" >/dev/null 2>&1
assert_file_has "$t/AGENTS.md" "Read this first."
assert_file_lacks "$t/AGENTS.md" "OLD TEXT"
assert_file_has "$t/AGENTS.md" "PROJECT-NOTE"
n=$(grep -c 'agentkit:start' "$t/AGENTS.md"); assert_eq "$n" 1 "one start marker"

CASE=update-recreates-stub
rm "$t/GEMINI.md"
out=$(sh "$INSTALL" "$t" 2>&1); code=$?
assert_eq "$code" 0 "exit"
assert_contains "$out" "created GEMINI.md" "stub recreated on update"
assert_same "$t/GEMINI.md" "$TPL/stub.md"

CASE=crlf
t=$(mktarget crlf)
sh "$INSTALL" "$t" >/dev/null 2>&1
sedi 's/Read this first./OLD TEXT/' "$t/AGENTS.md"; to_crlf "$t/AGENTS.md"
printf 'CRLF-NOTE\r\n' >> "$t/AGENTS.md"
out=$(sh "$INSTALL" "$t" 2>&1)
assert_contains "$out" "updated kit block in AGENTS.md" "crlf block"
assert_file_has "$t/AGENTS.md" "Read this first."
assert_file_lacks "$t/AGENTS.md" "OLD TEXT"
assert_file_has "$t/AGENTS.md" "CRLF-NOTE"

CASE=foreign-agentkit
t=$(mktarget foreign)
mkdir -p "$t/.agentkit"; printf 'x\n' > "$t/.agentkit/keep.txt"
out=$(sh "$INSTALL" "$t" 2>&1); code=$?
assert_eq "$code" 3 "exit"
assert_file "$t/.agentkit/keep.txt"
assert_no_file "$t/AGENTS.md"

CASE=adopt
t=$(mktarget adopt)
printf '# mine\n' > "$t/AGENTS.md"; printf 'custom rules\n' > "$t/CLAUDE.md"
out=$(sh "$INSTALL" "$t" 2>&1); code=$?
assert_eq "$code" 0 "exit"
assert_eq "$(cat "$t/AGENTS.md")" "# mine" "agents untouched"
assert_eq "$(cat "$t/CLAUDE.md")" "custom rules" "claude untouched"
assert_contains "$out" "adopt AGENTS.md" "agents adopt"
assert_contains "$out" "adopt CLAUDE.md" "claude adopt"
assert_file "$t/GEMINI.md"

CASE=dry-run
t=$(mktarget dry)
out=$(sh "$INSTALL" --dry-run "$t" 2>&1); code=$?
assert_eq "$code" 0 "exit"
assert_eq "$(ls -A "$t" | wc -l | tr -d ' ')" 0 "dir still empty"
assert_contains "$out" "would: created AGENTS.md" "dry agents"

CASE=bad-target
out=$(sh "$INSTALL" "$TMP_ROOT/does-not-exist" 2>&1); code=$?
assert_eq "$code" 2 "exit"
out=$(sh "$INSTALL" 2>&1); code=$?
assert_eq "$code" 2 "no args"

CASE=crlf-preserved
t=$(mktarget crlf2)
sh "$INSTALL" "$t" >/dev/null 2>&1
to_crlf "$t/AGENTS.md"
lines=$(wc -l < "$t/AGENTS.md" | tr -d ' ')
sh "$INSTALL" "$t" >/dev/null 2>&1
crs=$(tr -cd '\r' < "$t/AGENTS.md" | wc -c | tr -d ' ')
assert_eq "$crs" "$lines" "every line keeps CRLF"

CASE=agentkit-is-a-file
t=$(mktarget filekit)
printf 'data\n' > "$t/.agentkit"
out=$(sh "$INSTALL" "$t" 2>&1); code=$?
assert_eq "$code" 3 "exit"
assert_eq "$(cat "$t/.agentkit")" "data" "file untouched"

CASE=target-is-kit-payload
c="$TMP_ROOT/kitcopy"; rm -rf "$c"; mkdir -p "$c"; cp "$INSTALL" "$c/"; cp -R "$ROOT/kit" "$c/kit"
out=$(sh "$c/install.sh" "$c/kit" 2>&1); code=$?
assert_eq "$code" 3 "exit"
assert_file "$c/kit/.agentkit/VERSION"
out=$(cd "$c/kit" && sh ../install.sh . 2>&1); code=$?
assert_eq "$code" 3 "relative dot"
assert_file "$c/kit/.agentkit/INDEX.md"

CASE=extra-arg
t=$(mktarget extra)
out=$(sh "$INSTALL" "$t" "$t" 2>&1); code=$?
assert_eq "$code" 2 "two targets"

summary
