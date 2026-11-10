# Sample workspace

What a workspace's agent files look like after three working sessions on a small invoicing SaaS. Everything here is fictional: no real people, companies, data or commits.

The `.agentkit/` folder is left out; it is exactly `kit/.agentkit/` from this repo. To try it, copy this folder somewhere and run the installer on the copy. The installer keeps every file here and adds `.agentkit/`.

## What to look at
| File | Shows |
|---|---|
| `AGENTS.md` | The kit block, then a filled-in project section: what, layout, commands, stack, project rules |
| `docs/agent/STATUS.md` | A mid-task handoff: the exact file, the failing test and the next action |
| `docs/agent/LOG.md` | Append-only entries with evidence (command → result) |
| `docs/agent/DECISIONS.md` | A one-line index; D-0003 is an agent proposal awaiting confirmation |
| `docs/agent/decisions/D-0004-invoice-numbering.md` | A full decision record, used for a choice that had real alternatives |
| `docs/agent/research/invoice-numbering.md` | Research by experiment, with confidence labels |
| `docs/agent/plans/2026-11-04-team-invites/` | A feature-tier spec, plan and tracker: one task `doing`, one `blocked` with its reason |
| `docs/agent/OPEN-QUESTIONS.md` | A question blocking a task, and an out-of-scope finding parked instead of fixed |
| `.agentkit.local/overrides.md` | A one-line local override |

A new chat in any tool would read `AGENTS.md`, STATUS and DECISIONS (about 6 KB), then the tracker, and continue T-03 without a word of explanation.
