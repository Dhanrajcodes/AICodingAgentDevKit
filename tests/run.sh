#!/usr/bin/env bash
# Runs every bash test suite. Exit 0 only if all pass.
cd "$(dirname "$0")" || exit 1
status=0
for suite in test_kit.sh test_install.sh test_doctor.sh; do
  [ -f "$suite" ] || continue
  bash "$suite" || status=1
done
rm -rf "${TMPDIR:-/tmp}/agentkit-tests"
exit $status
