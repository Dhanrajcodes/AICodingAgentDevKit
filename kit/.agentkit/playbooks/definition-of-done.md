# Playbook: definition of done

Use before saying any task is done, fixed, working or complete. Every applicable line must be true, with evidence from this session. If a box can't be ticked, say which and why. Don't say done.

## Code
- [ ] It does what the task asked, nothing more. No unrelated changes in the diff.
- [ ] Tests cover the normal path and the edge cases that apply. New logic and bug fixes had a test that failed first.
- [ ] No test was skipped, weakened, deleted or had its expected value changed to get green.
- [ ] Format, lint, typecheck, the test suite and the build were run. You read the output. Paste the summary lines.
- [ ] The feature was actually run: the screen opened in a browser, the endpoint called, the job executed, the CLI invoked. Not just compiled.
- [ ] Errors are handled where they happen: visible, logged with context, retried only if safe. No empty catch, no silent fallback.
- [ ] No TODO, stub, placeholder, fake data, debug logging or commented-out code left.
- [ ] No secrets or real personal data in code, fixtures, logs or commits.
- [ ] New dependencies verified on their registry (exact name, publisher, maintained, no known vulnerabilities), justified and logged in DECISIONS.
- [ ] No hard rule in `security/RULEBOOK.md` broken. If the task touched a security surface, the matching checklists were run. Production releases also passed `playbooks/security-review.md`.

## UI (if the task touched a screen)
- [ ] Checked against `rules/frontend-ui.md`: tokens only, no banned patterns.
- [ ] Loading, empty, error and content states all exist and were seen.
- [ ] Keyboard and focus work. Contrast passes. Works at 320 px.
- [ ] Screenshots saved, and the paths exist on disk. Reference them in the LOG entry.

## Backend (if the task touched an API, job or data)
- [ ] Checked against `rules/backend.md`.
- [ ] Called with valid, invalid, unauthorised and duplicate input. Responses shown.
- [ ] Migrations run forward cleanly.

## Docs and memory
- [ ] Facts match the code and DECISIONS. Guesses are marked.
- [ ] Tracker row, STATUS and LOG updated. Decisions logged.

## Evidence format (for the LOG entry)
`Changed: ... | Files: ... | Evidence: <command> → <result>; <screenshot path> | Side effects: ...`

A claim of verification without evidence on disk or in output is treated as not done.
