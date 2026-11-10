# Decisions in force

One line each. Full reasoning in `decisions/` when a file is linked. Replaced decisions move to the bottom section.

| ID | Decision | By |
|---|---|---|
| D-0001 | Kit is installed by copy plus a tiny installer; re-running is the update | owner |
| D-0002 | Kit lives at the workspace root, which may wrap several repos | owner |
| D-0003 | The author's working style ships as the default; users soften it in `.agentkit.local/overrides.md` | owner |
| D-0004 | Process scales by tier (quick, small, feature); token use only where the project needs it | owner |
| D-0005 | Install is agent-run via INSTALL.md, plus `install.sh` and `install.ps1` | owner |
| D-0006 | Out-of-box support: Claude Code, Codex, Gemini CLI/Antigravity, Cursor, Copilot, Windsurf, Cline | owner |
| D-0007 | Existing harnesses are migrated by a guided adopt playbook that asks before moving anything | owner |
| D-0008 | Enforcement is markdown plus an optional doctor script; no required hooks | owner |
| D-0009 | Repo ships a full README and docs, presentable as a portfolio project | owner |
| D-0010 | Custom personal-use license, not MIT: use and modify freely, keep notice, no resale or republishing | owner |
| D-0011 | Folder names: `.agentkit/` (kit-owned), `.agentkit.local/` (user), `docs/agent/` (memory) | agent (proposed) |
| D-0012 | Decisions stored as a one-line index plus per-decision files; LOG rotates monthly into `log/` | agent (proposed) |
| D-0013 | Fresh-install ring 0 (AGENTS.md + STATUS.md + DECISIONS.md) budget is 8 KB | agent (proposed) |

## Replaced

None yet.
