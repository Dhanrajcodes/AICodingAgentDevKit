# AI Coding Agent Dev Kit

**A drop-in harness that makes any AI coding agent remember your project, work to a production standard, and spend tokens only where they matter.**

[![CI](https://github.com/Dhanrajcodes/AICodingAgentDevKit/actions/workflows/ci.yml/badge.svg)](https://github.com/Dhanrajcodes/AICodingAgentDevKit/actions/workflows/ci.yml)
![Version](https://img.shields.io/badge/version-1.0.0-2f6feb)
![License](https://img.shields.io/badge/license-personal%20use-555)
![Agents](https://img.shields.io/badge/works%20with-Claude%20Code%20%C2%B7%20Codex%20%C2%B7%20Gemini%20%C2%B7%20Cursor%20%C2%B7%20Copilot-555)

Plain markdown and two tiny scripts. No runtime, no server, no vendor lock-in. Install it once at a workspace root; from then on, Claude Code, Codex, Gemini CLI, Antigravity, Cursor, Copilot, Windsurf or Cline all read the same rules and the same project memory.

---

## The problem

AI coding agents write code quickly, but on real projects they fail in three predictable ways:

| Failure | What it looks like |
|---|---|
| **They forget** | Switch tools, open a new chat or hit a usage limit, and the plan, the decisions and where you stopped are gone. You explain the project again. |
| **They fake it** | "Done" without running anything. Invented APIs and packages. Tests weakened to get green. Errors hidden behind fallbacks. Generic, "AI-looking" UI. |
| **They waste context** | Teams respond with ever-longer instruction files that load every session, cost tokens on every turn, and past a few hundred lines make agents *less* reliable. |

## What the kit does

- **Memory in files, not chat.** A small, fixed set of files holds the current state, an append-only log, settled decisions, open questions and resumable plans. Any agent in a fresh chat continues from them. Say "resume", not three paragraphs of context.
- **Token budget by design.** A new session reads about **5.5 KB** (entry file, status, decisions index). The rest of the kit, about **110 KB** of rules, playbooks, checklists and templates, sits behind an index and is read only when a task needs it. A doctor script warns when memory files grow past budget.
- **Process that scales with the task.** A typo gets "do it, verify it, log a line". A feature gets a spec, a plan and a tracker that survives a switch to another AI tool mid-task. Agents pick the tier and say it.
- **Proof, not claims.** Claims are labelled verified, inferred or unverified. "Done" needs command output or a screenshot path that exists on disk. Packages and APIs are checked against the installed version before use.
- **Production quality bars.** Engineering, backend, frontend and UI rules aimed at the defects AI agents actually introduce, including a banned list of AI-slop UI and copy patterns.
- **A security rulebook that can't be talked out of.** Twenty hard rules, a production release gate and thirteen checklists from OWASP Top 10:2025, ASVS 5.0, the API, LLM and Agentic Top 10s, CWE Top 25 and NIST SSDF. They cover classic web security and modern AI risks: prompt injection, tool poisoning, hallucinated packages and hidden-Unicode instruction attacks. Local overrides can tighten it, never relax it.
- **Safe to customise.** The kit owns one folder and one marked block. Your rules and your project memory live elsewhere, and updates never touch them.

## Quick start

**Option 1: let your AI agent install it** (no scripts needed)

```text
Clone https://github.com/Dhanrajcodes/AICodingAgentDevKit somewhere, then
follow its INSTALL.md to install the kit into this workspace.
```

**Option 2: script** (macOS, Linux, Git Bash)

```sh
git clone https://github.com/Dhanrajcodes/AICodingAgentDevKit.git
sh AICodingAgentDevKit/install.sh /path/to/your/workspace
```

**Option 3: script** (Windows PowerShell)

```powershell
git clone https://github.com/Dhanrajcodes/AICodingAgentDevKit.git
powershell -ExecutionPolicy Bypass -File AICodingAgentDevKit\install.ps1 -Target C:\path\to\workspace
```

Then open the workspace in your AI tool and say **"start a session"**. The agent reads the kit, sees that memory is empty, and offers to fill in the project section with you.

To update, run the same command again. It refreshes the kit and keeps everything you wrote. Add `--dry-run` / `-DryRun` to preview.

## How it works

```
your-workspace/
├── AGENTS.md            ← entry point. Kit block (managed) + your project section
├── CLAUDE.md            ← "@AGENTS.md"   (Claude Code)
├── GEMINI.md            ← "@AGENTS.md"   (Gemini CLI, Antigravity)
├── .agentkit/           ← KIT-OWNED, replaced on update
│   ├── INDEX.md            what to read for which task
│   ├── rules/              9 standards: working, context economy, truthfulness,
│   │                       research, engineering, frontend/UI, backend, security, writing
│   ├── playbooks/          12 procedures: session start, handoff, plan & track,
│   │                       decisions, definition of done, bugfix, review, security review…
│   ├── security/           RULEBOOK.md + 13 checklists
│   ├── templates/          status, log, decisions, spec, plan, tracker, threat model…
│   └── doctor.sh / .ps1    health and token-budget check
├── .agentkit.local/     ← YOURS: overrides.md, budgets.env
└── docs/agent/          ← YOURS: project memory
    ├── STATUS.md           now (rewritten, ≤ 40 lines)
    ├── LOG.md              history (append-only, rotated monthly)
    ├── DECISIONS.md        one line per decision in force
    ├── decisions/          full reasoning, when it matters
    ├── OPEN-QUESTIONS.md   waiting on a human
    ├── plans/<slug>/       spec.md · plan.md · tracker.md
    └── research/           findings with sources and dates
```

**Three rings of context.** Ring 0 (`AGENTS.md`, `STATUS.md`, `DECISIONS.md`) loads every session. Ring 1 (the rules and playbooks `INDEX.md` points to for this task, plus the active tracker) loads by task. Ring 2 (a decision's full file, a spec section, a source range) loads only when needed. A CSS tweak never pays for the backend rules.

**A day with the kit**

1. *Morning, Claude Code:* "start a session". It reads STATUS, sees task T-04 of the billing plan is next, says so in two lines, and starts.
2. *Usage limit at lunch:* it runs the handoff playbook. STATUS records exactly which file and step it stopped at, and the tracker row stays `doing`.
3. *Afternoon, Codex:* "resume". Codex reads the same files and continues T-04 without a word of re-explaining.
4. *Before release:* "run a security review". The agent threat-models the new flows, works through the checklists, runs the scanners and writes a report. The release gate blocks on any open Critical or High finding.

Full design: [docs/architecture.md](docs/architecture.md).

## Doctor

```text
$ sh .agentkit/doctor.sh
ok   kit-installed
ok   kit-markers
ok   stub-claude
ok   stub-gemini
ok   ring0-size
ok   agents-lines
ok   status-lines
ok   decisions-lines
ok   log-size
warn status-fresh: STATUS.md last updated 2026-11-08, but LOG.md has an entry from 2026-11-10; run .agentkit/playbooks/handoff.md
ok   tracker-single-doing
ok   no-secrets
ok   env-ignored
ok   no-hidden-unicode
doctor: 1 warning(s)
```

It checks token budgets, forgotten handoffs, more than one task in progress, secrets in memory files, `.env` files that aren't git-ignored, and invisible Unicode that could hide instructions in agent files. It exits non-zero on warnings, so you can run it in CI or a git hook. Budgets are adjustable in `.agentkit.local/budgets.env`.

## Tool support

| Tool | How it picks up the kit |
|---|---|
| Codex, Cursor, GitHub Copilot, Windsurf, Cline, Kiro, Zed, Jules, Amp | Read `AGENTS.md` natively |
| Claude Code | `CLAUDE.md` → `@AGENTS.md` |
| Gemini CLI, Antigravity | `GEMINI.md` → `@AGENTS.md` |
| Anything else | Tell it to read `AGENTS.md` first |

Details and caveats: [docs/tool-support.md](docs/tool-support.md).

## Documentation

| Doc | For |
|---|---|
| [Getting started](docs/getting-started.md) | Install, first session, what to commit |
| [Architecture](docs/architecture.md) | Design goals, load model, memory model, ownership rules |
| [Security](docs/security.md) | The rulebook, waivers, the release gate, what's covered |
| [Customizing](docs/customizing.md) | Overrides, budgets, nested rules, project section |
| [Updating](docs/updating.md) | What an update changes and what it never touches |
| [Adopting an existing project](docs/adopting.md) | Migrating CLAUDE.md, memory banks, old trackers |
| [Token budget](docs/token-budget.md) | Where the tokens go and how to keep it lean |
| [Tool support](docs/tool-support.md) | Per-tool setup notes |
| [FAQ](docs/faq.md) | Common questions |
| [Example workspace](examples/sample-workspace/) | Memory files after a few real sessions |

## This repository

```
kit/                  the payload, exactly what lands in a workspace
install.sh            POSIX installer
install.ps1           PowerShell installer (5.1 and 7)
INSTALL.md            the same install, as steps any agent can follow
tests/                bash and PowerShell suites: installers, doctors, kit budgets
docs/                 public documentation
docs/agent/           this repo's own memory. The kit was built using itself.
examples/             a filled-in sample workspace
```

Quality gates run in CI on Ubuntu, macOS and Windows (PowerShell 5.1 and 7). They cover:
- Installer and doctor behaviour, including paths with spaces, CRLF files and re-install safety.
- ShellCheck on the shell scripts.
- Token budgets for every kit file.
- A scan that keeps hidden Unicode out of the kit itself.

The kit was built under its own rules: [`docs/agent/`](docs/agent/) holds the real status, decision log and build tracker from its development.

## License

Personal-use license. Copyright (c) 2026 Dhanraj Singh. You may install, use and modify the kit in your own projects, personal or commercial, and what you build with it is yours. You may not resell or republish the kit as your own product. See [LICENSE](LICENSE).

## Author

Built by **Dhanraj Singh** ([@Dhanrajcodes](https://github.com/Dhanrajcodes)).
