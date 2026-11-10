# Changelog

All notable changes to the kit. Versions follow [Semantic Versioning](https://semver.org): a major bump means an update may need manual steps (see `docs/updating.md`).

## [1.0.0] - 2026-11-10

First release.

- **Entry and memory:** `AGENTS.md` with a managed kit block plus a project section; `CLAUDE.md` and `GEMINI.md` import stubs; project memory in `docs/agent/` (STATUS, append-only LOG, decisions index plus records, open questions, plans with trackers, research).
- **Rules:** working, context economy, truthfulness, research, engineering, frontend/UI, backend, security and privacy, writing.
- **Playbooks:** session start, handoff, plan and track (quick, small and feature tiers), log a decision, research, definition of done, edge cases, bugfix, review, adopt, compact, security review.
- **Security rulebook:** hard rules SR-01 to SR-20, owner-only waivers, a production release gate, and 13 checklists covering classic web security and AI-era risks.
- **Installers:** `install.sh` (POSIX) and `install.ps1` (PowerShell 5.1 and 7) with identical behaviour, plus `INSTALL.md` for agent-run installs. Re-running is the update.
- **Doctor** (`doctor.sh`, `doctor.ps1`): token budgets, stale status, tracker discipline, stubs and markers, secrets, unignored `.env` files, hidden Unicode.
- **Docs:** README, architecture, getting started, security, customizing, updating, adopting, token budget, tool support, FAQ, sample workspace.
- **CI:** bash on Ubuntu and macOS, ShellCheck, PowerShell 5.1 and 7 on Windows, fresh-install doctor gate.
