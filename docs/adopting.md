# Adopting an existing project

Many projects already have agent docs: a long `CLAUDE.md`, a `memory-bank/`, `PROGRESS.md`, handoff notes, phase plans, ADRs, `.cursorrules`. The kit doesn't overwrite any of them. It installs alongside, reports `adopt`, and leaves the merge to a guided playbook that asks before moving anything.

## Steps
1. **Install** as usual. Files you already have are reported as `adopt` or `kept`. Nothing of yours changes.
2. **Ask your agent:** "Run the adopt playbook." (`.agentkit/playbooks/adopt.md`)
3. The agent **inventories** every harness and memory file: path, size, last modified, what it holds. It reads huge files by structure, not whole.
4. It **proposes a mapping** in one table and asks you to approve it:

| Found | Becomes |
|---|---|
| Project facts in `CLAUDE.md` | Project section of `AGENTS.md` |
| Rules that differ from the kit | `.agentkit.local/overrides.md` or a nested `AGENTS.md` |
| Rules the kit already covers | Dropped, once you agree |
| Current-state notes | `docs/agent/STATUS.md` (≤ 40 lines) |
| Progress logs, handoff notes | `docs/agent/LOG.md` or `docs/agent/log/YYYY-MM.md` |
| Decision tables, ADRs | `DECISIONS.md` index plus `decisions/` files, keeping original IDs in the text |
| Phase plans and trackers | `docs/agent/plans/<slug>/`, keeping task IDs |
| Research notes | `docs/agent/research/` |
| Client or owner source docs | Left in place, marked read-only in `AGENTS.md` |

5. It flags **contradictions** for you to settle: two design-system versions, status written in five places, rules that disagree.
6. After your yes, it **backs up** the originals to `docs/agent/archive/adopt-YYYY-MM-DD/`, then moves, merges and summarises. It never deletes content without your explicit permission.
7. It replaces `CLAUDE.md` and `GEMINI.md` with the one-line stub once their content is merged, runs the doctor, and logs the adoption as a decision.

## Typical wins
- A 100 KB "read everything first" set of plans becomes a 5 KB ring 0, with the plans behind pointers.
- A single 50 KB decisions table becomes a one-line-per-decision index, with detail files loaded on demand.
- Three overlapping rule files collapse into the kit's rules plus a few lines of overrides.

## If you'd rather not migrate
Leave the old files where they are and add pointers in the project section of `AGENTS.md` ("Phase plans: `PHASE2_EXECUTION_PLAN.md`, read only the section you need"). The doctor's `kit-markers` and `stub-*` checks will keep warning until `AGENTS.md` has the kit block and the stubs import it.
