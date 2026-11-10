# Playbook: review

Use when reviewing a change: your own before handing over, another agent's, or a pull request. A fresh session or a different agent reviews better than the author; use one for feature-tier work when you can.

## Inputs
The task or spec, the diff (`git diff <base>..HEAD`), the tracker row, and the LOG entry with its evidence.

## Check, in this order
1. **Does it do the task?** Against the spec and the done criteria, not against what the code seems to intend. Missing requirements first.
2. **Is it true?** Do the claimed checks actually pass? Rerun the verify command. Do referenced screenshots exist? A claim without evidence is a finding.
3. **Correctness:** logic errors, wrong conditions, off-by-one, unhandled states, races, broken error paths. Walk the edge cases that apply.
4. **Safety:** secrets, personal data, auth and access checks, injection, unsafe input handling.
5. **Honesty:** weakened or skipped tests, silenced errors, hidden fallbacks, stubs or TODOs, hardcoded test values.
6. **Fit:** follows project patterns and the rules files; no duplicate helpers; no scope creep.
7. **Quality:** naming, size, clarity, UI against `rules/frontend-ui.md`, backend against `rules/backend.md`.

## Report
For each finding: severity, `file:line`, what's wrong, the concrete failure it causes, and a suggested fix.
- **Critical:** wrong result, data loss, security hole, or a false "done" claim. Must fix.
- **Important:** a real bug in a plausible case, or a rule broken. Should fix before done.
- **Minor:** polish. Note it; the owner decides.

No findings is a valid result. Don't invent issues to look thorough.

## After
- Critical and Important: fix with a test that fails first, then rerun the suite.
- Minor: list in the LOG entry or OPEN-QUESTIONS.
- Reviewer's name in the LOG entry (`Reviewed by: fresh session` or the tool).
