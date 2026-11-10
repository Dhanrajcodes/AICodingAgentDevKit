# Getting started

## 1. Pick the workspace root
Install at the folder you open in your editor. If your product is several repos inside one folder (for example `my-product/frontend` and `my-product/backend`), install at `my-product/`. One memory then covers the whole product. Repo-specific commands go in a short nested `AGENTS.md` inside each repo.

## 2. Install
Choose one:

| How | Command |
|---|---|
| Ask your agent | "Follow INSTALL.md in the AICodingAgentDevKit folder to install the kit into this workspace." |
| macOS, Linux, Git Bash | `sh AICodingAgentDevKit/install.sh /path/to/workspace` |
| Windows PowerShell | `powershell -ExecutionPolicy Bypass -File AICodingAgentDevKit\install.ps1 -Target C:\path\to\workspace` |

Add `--dry-run` or `-DryRun` first to see what would change. The installer prints one line per file:

- `created`: the file didn't exist and was written.
- `updated`: a kit-owned file or block was refreshed.
- `kept`: your file exists and was left alone.
- `adopt`: you already have an `AGENTS.md` or `CLAUDE.md` with your own content. Nothing was changed; see [adopting.md](adopting.md).

## 3. Check
```sh
sh .agentkit/doctor.sh                                      # macOS, Linux, Git Bash
powershell -ExecutionPolicy Bypass -File .agentkit\doctor.ps1   # Windows
```
Every line should say `ok`.

## 4. First session
Open the workspace in your AI tool and say **"start a session"**. The agent:
1. reads `AGENTS.md`, `docs/agent/STATUS.md` and `docs/agent/DECISIONS.md`;
2. notices memory is empty and offers to fill the **Project** section of `AGENTS.md` with you: what it is, layout, commands, stack, project rules.

Answer its questions. Keep the project section short: facts an agent can't get from the code in a minute.

## 5. Work normally
- Ask for things as usual. The agent states a tier (quick, small, feature) and follows it.
- For a feature, it creates `docs/agent/plans/<date-slug>/` with a spec for you to approve, a plan, and a tracker.
- When you stop, or the chat gets long, say **"hand off"**. When you come back, in any tool, say **"resume"**.
- Before shipping to production, say **"run a security review"**.

## 6. Commit
Commit these so every tool and every teammate shares them:
```
AGENTS.md  CLAUDE.md  GEMINI.md  .agentkit/  .agentkit.local/  docs/agent/
```
Memory files are plain markdown, so review them in diffs like code. They steer every future session.

## Useful phrases
| Say | The agent runs |
|---|---|
| "start a session" / "resume" | `playbooks/session-start.md` |
| "hand off" | `playbooks/handoff.md` |
| "plan this" | `playbooks/plan-and-track.md` |
| "log that decision" | `playbooks/log-decision.md` |
| "research X" | `playbooks/research.md` |
| "review this" | `playbooks/review.md` |
| "run a security review" | `playbooks/security-review.md` |
| "compact memory" | `playbooks/compact.md` |
