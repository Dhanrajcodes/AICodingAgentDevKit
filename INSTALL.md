# Install the kit (instructions for an AI agent)

You are an AI coding agent asked to install or update the AI Coding Agent Dev Kit into a workspace. Follow these steps exactly. They do the same thing as `install.sh` and `install.ps1`. If you can run a shell, prefer running the script; these steps are for tools that can only edit files, or when the user asks you to do it by hand.

**Terms:**
- `KIT` is the `kit/` folder of this repository (wherever the user downloaded or cloned it).
- `TARGET` is the workspace folder: the folder the user opens in their editor. It may contain several repos. Ask the user if it isn't obvious.

Report each step's outcome using the same words the scripts use: `created`, `updated`, `kept`, or `adopt`.

## 1. Guard
If `TARGET/.agentkit/` exists and has no `VERSION` file, **stop**. It isn't a kit install. Tell the user, and change nothing.

## 2. Kit core (kit-owned)
Replace `TARGET/.agentkit/` with a full copy of `KIT/.agentkit/`. Delete the old folder first so removed files don't linger. Report `created .agentkit/ (vX)` or `updated .agentkit/ (vX)`, where X is the content of `KIT/.agentkit/VERSION`.

## 3. AGENTS.md
The template is `KIT/.agentkit/templates/AGENTS.md`. Its kit block is everything from the line `<!-- agentkit:start -->` to the line `<!-- agentkit:end -->`, both included.

- **`TARGET/AGENTS.md` doesn't exist:** copy the template. Report `created AGENTS.md`.
- **It exists and has exactly one start marker before one end marker:** replace the lines from the start marker to the end marker (inclusive) with the template's kit block. Don't change a single character outside the markers, and keep the file's existing line endings. Report `updated kit block in AGENTS.md`.
- **It exists without both markers:** don't touch it. Report `adopt AGENTS.md` and tell the user you can run `.agentkit/playbooks/adopt.md` to merge it.

## 4. Tool stubs
For `CLAUDE.md` and `GEMINI.md` in `TARGET`:
- **Missing:** copy `KIT/.agentkit/templates/stub.md` there. Report `created`.
- **Contains `@AGENTS.md`:** leave it. Report `kept`.
- **Has other content:** leave it. Report `adopt` (the adopt playbook merges it).

## 5. User-owned seeds (create only if missing; never overwrite)
| Create in TARGET | From |
|---|---|
| `.agentkit.local/README.md` | `KIT/.agentkit.local/README.md` |
| `.agentkit.local/overrides.md` | `KIT/.agentkit.local/overrides.md` |
| `.agentkit.local/budgets.env` | `KIT/.agentkit.local/budgets.env` |
| `docs/agent/STATUS.md` | `KIT/.agentkit/templates/status.md` |
| `docs/agent/LOG.md` | `KIT/.agentkit/templates/log.md` |
| `docs/agent/DECISIONS.md` | `KIT/.agentkit/templates/decisions-index.md` |
| `docs/agent/OPEN-QUESTIONS.md` | `KIT/.agentkit/templates/open-questions.md` |
| `docs/agent/decisions/.gitkeep`, `plans/.gitkeep`, `research/.gitkeep`, `log/.gitkeep` | empty files |

Report `created <path>` or `kept <path>` for each.

## 6. Check
If a shell is available, run the doctor and show the user its output:
- macOS, Linux, Git Bash: `sh .agentkit/doctor.sh`
- Windows PowerShell: `powershell -ExecutionPolicy Bypass -File .agentkit\doctor.ps1`

On a fresh install every check should be `ok`.

## 7. First session
1. If anything was reported as `adopt`, offer to run `.agentkit/playbooks/adopt.md` now.
2. Otherwise follow `.agentkit/playbooks/session-start.md`. Since memory is empty, offer to fill the project section of `AGENTS.md` (what this is, layout, commands, stack, project rules) with the user. Ask; don't guess.
3. Suggest the user commit `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.agentkit/`, `.agentkit.local/` and `docs/agent/`.

## Updating later
Same steps. Steps 2 and 3 refresh the kit; everything the user owns is kept.
