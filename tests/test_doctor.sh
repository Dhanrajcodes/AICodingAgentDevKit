#!/usr/bin/env bash
# Tests for .agentkit/doctor.sh. Run via tests/run.sh.
SUITE=doctor.sh
. "$(dirname "$0")/lib.sh"

fresh() { # fresh <name> -> installed workspace path
  d=$(mktarget "$1")
  sh "$ROOT/install.sh" "$d" >/dev/null 2>&1
  printf '%s' "$d"
}
doc() { out=$(sh "$1/.agentkit/doctor.sh" "${2:-$1}" 2>&1); code=$?; }
lines() { i=0; while [ $i -lt "$2" ]; do echo "line $i"; i=$((i + 1)); done >> "$1"; }

LABELS="kit-installed kit-markers stub-claude stub-gemini ring0-size agents-lines status-lines decisions-lines log-size status-fresh tracker-single-doing no-secrets env-ignored no-hidden-unicode"

CASE=clean
t=$(fresh "clean ws")
doc "$t"
assert_eq "$code" 0 "exit"
for l in $LABELS; do assert_contains "$out" "ok   $l" "$l"; done
assert_contains "$out" "doctor: 0 warning(s)" "summary"

CASE=default-target
out=$(cd "$TMP_ROOT" && sh "$t/.agentkit/doctor.sh" 2>&1); code=$?
assert_eq "$code" 0 "runs against its own workspace from any cwd"

CASE=kit-installed
t=$(fresh k1); rm "$t/.agentkit/VERSION"; doc "$t"
assert_eq "$code" 1 "exit"; assert_contains "$out" "warn kit-installed" "label"

CASE=kit-markers
t=$(fresh k2); printf '# mine\n' > "$t/AGENTS.md"; doc "$t"
assert_contains "$out" "warn kit-markers" "label"

CASE=stubs
t=$(fresh k3); printf 'custom\n' > "$t/CLAUDE.md"; rm "$t/GEMINI.md"; doc "$t"
assert_contains "$out" "warn stub-claude" "claude"
assert_contains "$out" "warn stub-gemini" "gemini"

CASE=ring0-size
t=$(fresh k4); printf 'RING0_MAX_BYTES=100\n' >> "$t/.agentkit.local/budgets.env"; doc "$t"
assert_contains "$out" "warn ring0-size" "label"
assert_contains "$out" "ok   status-lines" "others unaffected"

CASE=agents-lines
t=$(fresh k5); lines "$t/AGENTS.md" 200; doc "$t"
assert_contains "$out" "warn agents-lines" "label"

CASE=status-lines
t=$(fresh k6); lines "$t/docs/agent/STATUS.md" 50; doc "$t"
assert_contains "$out" "warn status-lines" "label"

CASE=decisions-lines
t=$(fresh k7); lines "$t/docs/agent/DECISIONS.md" 90; doc "$t"
assert_contains "$out" "warn decisions-lines" "label"

CASE=log-size
t=$(fresh k8); printf 'LOG_MAX_BYTES=10\n' >> "$t/.agentkit.local/budgets.env"; doc "$t"
assert_contains "$out" "warn log-size" "label"

CASE=status-fresh
t=$(fresh k9)
sedi 's/^Last updated: [0-9-]*/Last updated: 2026-01-01/' "$t/docs/agent/STATUS.md"
printf '\n## 2026-02-01: later work\n- x\n' >> "$t/docs/agent/LOG.md"
doc "$t"
assert_contains "$out" "warn status-fresh" "stale"
sedi 's/^Last updated: [0-9-]*/Last updated: 2026-03-01/' "$t/docs/agent/STATUS.md"
doc "$t"
assert_contains "$out" "ok   status-fresh" "fresh"

CASE=crlf-status
to_crlf "$t/docs/agent/STATUS.md"
doc "$t"
assert_contains "$out" "ok   status-fresh" "crlf parses"
sedi 's/^Last updated: [0-9-]*/Last updated: 2026-01-01/' "$t/docs/agent/STATUS.md"
doc "$t"
assert_contains "$out" "warn status-fresh" "crlf stale"

CASE=tracker
t=$(fresh k10); mkdir -p "$t/docs/agent/plans/p"
printf '| ID | Task | Priority | Status | Commit |\n|---|---|---|---|---|\n| T-01 | a | P0 | doing | |\n| T-02 | b | P0 |  doing  | |\n' > "$t/docs/agent/plans/p/tracker.md"
doc "$t"
assert_contains "$out" "warn tracker-single-doing" "label"
assert_contains "$out" "plans/p/tracker.md" "names the file"

CASE=secrets
t=$(fresh k11); printf 'key sk-abcdefghijklmnopqrstuvwx1234\n' >> "$t/docs/agent/STATUS.md"; doc "$t"
assert_contains "$out" "warn no-secrets" "label"
assert_contains "$out" "STATUS.md" "names the file"
assert_lacks "$out" "sk-abcdefghij" "never prints the secret"

CASE=env-ignored
t=$(fresh "envtest ws"); git -C "$t" init -q
printf 'SECRET=1\n' > "$t/.env"; printf 'X=\n' > "$t/.env.example"
doc "$t"
assert_contains "$out" "warn env-ignored" "unignored .env"
assert_lacks "$out" ".env.example" "example files are fine"
printf '.env\n' > "$t/.gitignore"; doc "$t"
assert_contains "$out" "ok   env-ignored" "ignored .env"
mkdir -p "$t/app"; printf 'K=1\n' > "$t/app/.env.local"; doc "$t"
assert_contains "$out" "warn env-ignored" "nested unignored"
assert_contains "$out" "app/.env.local" "names nested file"
t=$(fresh envnogit); printf 'K=1\n' > "$t/.env"; doc "$t"
assert_contains "$out" "ok   env-ignored" "not a git repo: cannot be committed"

CASE=hidden-unicode
t=$(fresh hu1)
printf 'Normal line\n\363\240\201\201\363\240\201\202 hidden tag chars\n' >> "$t/AGENTS.md"
doc "$t"
assert_contains "$out" "warn no-hidden-unicode" "tag characters"
assert_contains "$out" "AGENTS.md" "names the file"
t=$(fresh hu2)
printf 'abc\342\200\256def\n' >> "$t/docs/agent/STATUS.md"
doc "$t"
assert_contains "$out" "warn no-hidden-unicode" "bidi override"
t=$(fresh hu3)
printf 'zero\342\200\213width\n' >> "$t/.agentkit.local/overrides.md"
doc "$t"
assert_contains "$out" "warn no-hidden-unicode" "zero-width space"
t=$(fresh hu4)
printf 'Plain UTF-8 is fine: caf\303\251, \342\206\222, \342\211\244 40 lines\n' >> "$t/docs/agent/STATUS.md"
doc "$t"
assert_contains "$out" "ok   no-hidden-unicode" "ordinary unicode ok"

summary
