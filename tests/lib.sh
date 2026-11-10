# Shared helpers for the bash test suites. Sourced, not executed.

ROOT=$(cd "$(dirname "$0")/.." && pwd)
TMP_ROOT="$ROOT/tests/.tmp"
PASS=0
FAIL=0

mktarget() {
  # mktarget <name> -> prints a fresh empty directory path (may contain spaces)
  d="$TMP_ROOT/$1"
  rm -rf "$d"
  mkdir -p "$d"
  printf '%s' "$d"
}

ok()   { PASS=$((PASS + 1)); }
bad()  { FAIL=$((FAIL + 1)); printf '  FAIL [%s] %s\n' "$CASE" "$1"; }

assert_eq()       { [ "$1" = "$2" ] && ok || bad "expected '$2', got '$1' ($3)"; }
assert_file()     { [ -f "$1" ] && ok || bad "missing file $1"; }
assert_no_file()  { [ ! -e "$1" ] && ok || bad "should not exist: $1"; }
assert_contains() { printf '%s' "$1" | grep -qF -- "$2" && ok || bad "output lacks '$2' ($3)"; }
assert_lacks()    { printf '%s' "$1" | grep -qF -- "$2" && bad "output has '$2' ($3)" || ok; }
assert_file_has() { grep -qF -- "$2" "$1" && ok || bad "$1 lacks '$2'"; }
assert_file_lacks() { grep -qF -- "$2" "$1" && bad "$1 has '$2'" || ok; }
assert_same()     { cmp -s "$1" "$2" && ok || bad "$1 differs from $2"; }

summary() {
  printf '%s: %d passed, %d failed\n' "$SUITE" "$PASS" "$FAIL"
  [ "$FAIL" -eq 0 ]
}
