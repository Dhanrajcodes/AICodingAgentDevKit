# Playbook: bugfix

Use when fixing a bug, a failing test, a crash or a regression. Fix the cause, not the symptom.

1. **Pin it down.** Write the bug as three lines (`templates/bugfix.md` for anything non-trivial):
   - Current behaviour: what happens, with exact error text and steps.
   - Expected behaviour: what should happen, and the source for that expectation.
   - Must not change: behaviour around it that has to stay the same.
2. **Reproduce.** Get the failure to happen on demand: a failing test if possible, otherwise exact steps or a command. No reproduction, no fix; if you can't reproduce, say so and gather more data.
3. **Find the cause.** Read the error and the stack trace fully. Trace backwards from the symptom to where the bad value or state first appears. Check recent changes (`git log -p`, `git bisect` for regressions). Form one hypothesis at a time and test it.
4. **Don't guess-fix.** If two attempts didn't work, stop, re-read the evidence and question your assumptions. Don't stack changes.
5. **Fix minimally** at the cause. No unrelated refactors in the same change.
6. **Prove it.** The reproduction test now passes. The full suite passes. The "must not change" behaviour is checked.
7. **Look for siblings.** Search for the same pattern elsewhere. Fix the ones in scope; list the rest in OPEN-QUESTIONS or as new tracker IDs.
8. **Record.** LOG entry: cause in one line, fix, evidence. If the cause was a wrong assumption in docs or memory files, correct them.

## Never
- Change or delete a test's assertion to make it pass, unless the user agrees the test was wrong.
- Wrap the failure in a try/catch, a default value or a retry to make it go away.
- Mark it fixed because the error stopped showing once.
