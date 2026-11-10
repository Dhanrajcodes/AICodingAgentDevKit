# Tool support

The kit's single source of truth is `AGENTS.md`, the open standard stewarded by the Agentic AI Foundation (agents.md). Tools that don't read it natively get a one-line stub that imports it. Behaviour below was checked in November 2026; tools change quickly, so check your tool's docs if something looks off.

| Tool | Setup | Notes |
|---|---|---|
| **Claude Code** | `CLAUDE.md` containing `@AGENTS.md` (installed) | Claude Code reads `CLAUDE.md`; the import pulls in `AGENTS.md`. Don't put rules in `CLAUDE.md` itself. |
| **Codex (OpenAI)** | None | Reads `AGENTS.md` natively and merges nested ones from the root down. Combined size is capped at 32 KiB; the kit's ring 0 is about 5.7 KB. |
| **Gemini CLI** | `GEMINI.md` containing `@AGENTS.md` (installed) | Doesn't read `AGENTS.md` by default. Alternatively set `"context": {"fileName": ["AGENTS.md", "GEMINI.md"]}` in its settings. |
| **Antigravity** | `GEMINI.md` stub (installed) | Native `AGENTS.md` support wasn't confirmed when this was written; the stub covers it. |
| **Cursor** | None | Reads `AGENTS.md`, including nested files. `.cursor/rules/*.mdc` stays available for glob-scoped rules. |
| **GitHub Copilot** | None | Reads `AGENTS.md`; the nearest file wins. |
| **Windsurf** | None | Reads `AGENTS.md` up to the git root. |
| **Cline** | None | Reads `AGENTS.md`. |
| **Kiro, Zed, Jules, Amp, Aider** | None, or point the tool at `AGENTS.md` | Aider: add `read: AGENTS.md` to `.aider.conf.yml`. |
| **Anything else** | Tell it "read AGENTS.md first" | Everything is plain markdown. |

## Why stubs and not symlinks
Symlinks break on Windows without developer mode, and some tools ask for approval when a link points elsewhere. A one-line import works everywhere.

## Tool-specific features
The kit doesn't depend on any of them, but they help where they exist:
- **Question UIs** (multiple-choice prompts): the working rules tell agents to use them when available.
- **Sub-agents:** the context-economy rules send wide searches and research to them.
- **Hooks:** to enforce a rule mechanically, run `.agentkit/doctor.sh` from a git pre-commit hook or a CI step. It works with every tool.
