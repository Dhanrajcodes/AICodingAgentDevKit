# Token budget

Every token an agent loads is paid for again on every later turn of the session, and long instruction files reduce how well agents follow them. Anthropic recommends keeping `CLAUDE.md` under about 200 lines, and Codex stops reading `AGENTS.md` chains past 32 KiB. The kit is built around a small always-loaded core.

## Measured (v1.0.0, fresh install)
| Ring | What | Size |
|---|---|---|
| 0: every session | `AGENTS.md` (67 lines; kit block 48), `STATUS.md`, `DECISIONS.md` | ~5.7 KB |
| 1: by task | The few rules or playbooks `INDEX.md` names for the task | typically 2-10 KB |
| 2: by need | One decision file, one spec section, one checklist, one source range | as needed |
| Never loaded at once | The whole kit: 9 rules, 12 playbooks, 13 security checklists, 15 templates | ~115 KB |

`tests/test_kit.sh` fails the build if ring 0 passes 8 KB, the kit block passes 70 lines, or any rule, playbook or checklist passes 150 lines.

## How the kit keeps it lean
- **An index instead of preloading.** `INDEX.md` gives one line per file with a "read when". A CSS change loads the UI rules, not the backend rules or the security checklists.
- **Memory split by how it changes.** `STATUS.md` is rewritten (≤ 40 lines), so it never accumulates history. History goes to `LOG.md`, which is append-only and rotated monthly into `log/`, and isn't loaded at session start.
- **Decisions as an index.** One line per decision in force; full reasoning in `decisions/D-NNNN-*.md`, read only when someone asks why.
- **One-line tracker cells.** Notes go to the log, so the tracker stays scannable.
- **Context-economy rules.** Search before reading, read ranges not files, keep long output out of the chat, delegate wide searches to sub-agents, and hand off when context degrades.
- **The doctor watches it.** `ring0-size`, `agents-lines`, `status-lines`, `decisions-lines` and `log-size` warn before memory becomes a tax. `playbooks/compact.md` fixes it without losing anything.

## Keeping your project lean
- Keep the project section of `AGENTS.md` to facts an agent can't get from the code in a minute.
- Don't put linter-enforceable style rules in `AGENTS.md`; configure the linter.
- Put folder-specific rules in a nested `AGENTS.md`, not at the root.
- Run `compact` at the end of every milestone.
