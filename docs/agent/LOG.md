# Log

Append-only. Newest at the bottom. Entry: `## YYYY-MM-DD: title`, then what was done, files, how it was verified.

## 2026-11-10: research and design
- Audited the owner's workspaces (D:\Wproject, D:\project) for existing agent harnesses, trackers and recurring instructions.
- Researched AGENTS.md support, Spec Kit, BMAD, Agent OS, superpowers, Memory Bank, Task Master, Kiro, ADR formats and instruction-file size guidance.
- Q&A with the owner: D-0001 to D-0010.
- Wrote `docs/architecture.md` (spec) and the v1 plan and tracker.

## 2026-11-10: T-01 to T-04
- Changed: repo foundation, AGENTS.md kit block and stubs, INDEX, 9 rules, 11 playbooks.
- Ruling: the AGENTS.md template and tool stub live in `kit/.agentkit/templates/` (not at `kit/` root), so every install carries them for adopt and agent-run installs. One source, no copy drift. Cost if wrong: the installer reads one extra path.
- Evidence: kit block 43 lines, 4022 bytes; all rules and playbooks under 70 lines (`wc -l`).

## 2026-11-10: T-05 templates and seeds
- Changed: 13 templates; `.agentkit.local/` seeds (README, overrides, budgets.env).
- Ruling: no `kit/docs/agent/` payload. The installer seeds `docs/agent/` from `.agentkit/templates/` (status, log, decisions-index, open-questions) so each memory shape exists once. Cost if wrong: a mapping table in both installers.
- Evidence: fresh ring 0 (templates AGENTS + status + decisions-index) = 4889 bytes (`wc -c`).
