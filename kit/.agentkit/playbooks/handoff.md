# Playbook: handoff

Use when finishing a task, before pausing, when switching tools, or when the chat has grown long. The test: a different AI tool, in a fresh chat with no history, continues from the files alone without asking what happened.

1. **Tracker** (feature tier): set the task's status. `done` only after `playbooks/definition-of-done.md`. Write the commit hash. If stopping mid-task, leave it `doing`.
2. **LOG.md:** append one entry with `templates/log-entry.md`:
   - `## YYYY-MM-DD: <task id or short title>`
   - Changed, Files, Evidence (commands run and results, screenshot paths), Side effects or follow-ups.
3. **STATUS.md:** rewrite it with `templates/status.md`. Max 40 lines.
   - Phase: one line.
   - Active plan: path, or "none".
   - In progress: exactly where it stopped. File paths, what's half-done, what state it's in (compiles? tests red?).
   - Next step: the very next action, specific enough to start without asking.
   - Blocked on: what's waiting on whom.
   - Remove anything that is history; that's in LOG.
4. **Decisions:** log every new choice with `playbooks/log-decision.md`.
5. **Open questions:** add new ones to `OPEN-QUESTIONS.md`; delete answered ones (the answer becomes a decision).
6. **Check:** no secrets, tokens or real personal data in anything you wrote. Run doctor if a shell is available (`sh .agentkit/doctor.sh` or `powershell -ExecutionPolicy Bypass -File .agentkit/doctor.ps1`) and fix what it flags.
7. **Commit** if the project commits memory files, with a message like `docs(agent): handoff after T-07`.
8. **Tell the user** in one or two lines what was saved and whether a fresh session is a good idea now.

## Mid-task handoff (context running out, usage limit, tool switch)
Speed over polish. Minimum:
- STATUS "In progress" and "Next step" precise enough to resume.
- Tracker row still `doing`.
- One LOG line saying the handoff was mid-task and what's uncommitted.
Uncommitted work: commit it on a branch as `wip:` if the user allows, or describe it exactly in STATUS.
