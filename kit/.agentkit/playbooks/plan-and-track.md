# Playbook: plan and track

Use to choose a tier, to write a spec, plan and tracker for feature-tier work, and to work through a tracker.

## 1. Choose the tier
| Tier | When | Artifacts |
|---|---|---|
| Quick | One obvious change, no design choice | One LOG line |
| Small | One behaviour, a few files, done this session | 3-6 line plan in chat; LOG entry |
| Feature | New capability, several parts, decisions needed, or spans sessions | `docs/agent/plans/<YYYY-MM-DD-slug>/` with `spec.md`, `plan.md`, `tracker.md` |

Say the tier. Move up the moment the work grows; never pad a small task with ceremony.

## 2. Spec (feature tier): `templates/spec.md`
- Why, goals, non-goals, anti-goals (what would make it a failure even if it works).
- Requirements in the user's words. Every requirement has a source: the user, a doc, or a decision ID. Nothing invented.
- Constraints, edge cases (`playbooks/edge-cases.md`), and open questions.
- Ask the user to approve the spec before planning. Log the approval as a decision.

## 3. Plan: `templates/plan.md`
- File map: which files are created or changed, one responsibility each.
- Tasks with IDs (`T-01`, `T-02`...). Each task: goal, files, interfaces it uses or produces, done criteria that can be observed, and the exact verify command.
- A task is the smallest unit that can be verified on its own and reviewed. Fold setup into the task that needs it.
- Decide names, signatures and values in the plan; leave obvious code to the builder. A plan longer than the code it describes is too long.
- Order by dependency, then by priority (P0 must ship, P1 should, P2 nice to have).

## 4. Tracker: `templates/tracker.md`
One table, one-line cells: `ID | Task | Priority | Status | Commit`.
Status words: `todo`, `doing`, `done`, `blocked (reason)`, `dropped (reason)`.

Rules:
- Exactly one `doing` at a time.
- Next task = the first `todo` in the highest priority, in ID order, whose dependencies are done.
- IDs are never renumbered or reused. Superseded work: `dropped (replaced by T-09)`.
- New work found mid-task becomes a new ID at the bottom, not scope creep.
- `blocked` always has a reason and what would unblock it. Add it to `OPEN-QUESTIONS.md` if a human is needed.
- Notes never go in the tracker. They go in LOG.

## 5. The cycle (one task at a time)
1. Set the row to `doing`. Update STATUS "In progress".
2. Re-read the task in `plan.md` (not your memory of it).
3. Build in small steps; tests first for logic and bugs.
4. Run the verify command and read the output.
5. Run `playbooks/definition-of-done.md`.
6. Commit. Set the row to `done` with the hash.
7. Append a LOG entry: Changed | Files | Evidence | Side effects.
8. Next task, or `playbooks/handoff.md` if stopping.

## 6. When the plan is wrong
Make the smallest change that still meets the spec, log it as a decision (`agent (proposed)` if the user hasn't seen it), and note it in the task's LOG entry. A silent deviation is a decision made in secret.

## 7. Finishing a plan
All rows `done` or `dropped` → final review (`playbooks/review.md`) → STATUS says the plan is complete → the plan folder stays as history.
