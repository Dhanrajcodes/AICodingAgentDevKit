# Architecture

This document explains how the AI Coding Agent Dev Kit is put together and why. It is also the design spec the kit was built from.

## The problem

AI coding agents are good at writing code and bad at three things that matter on real projects:

1. **Remembering.** Context lives in the chat. Switch tools, start a new chat or hit a usage limit, and the agent forgets the plan, the decisions and where it stopped. You re-explain the project from scratch.
2. **Staying honest.** Agents claim work is done without running it, invent APIs and requirements, weaken tests to get green, and hide errors behind fallbacks.
3. **Spending context well.** Teams fix (1) and (2) by writing ever-longer instruction files. Those files get loaded every session, cost tokens on every turn and, past a few hundred lines, lower how well the agent follows them.

The kit fixes all three with plain markdown files that any agent can read, organised so that only what is needed gets loaded.

## Design goals

| Goal | How the kit meets it |
|---|---|
| AI-agnostic | Everything is plain markdown. `AGENTS.md` is the single entry point; tools that don't read it natively get a one-line stub that imports it. No tool-specific feature is required. |
| Stack-agnostic | Rules describe outcomes (validate input at the edge, every screen has an empty state), not frameworks. Project specifics live in the project's own section of `AGENTS.md`. |
| Token-lean | A small always-loaded set (target under 8 KB). Everything else is behind an index and read only when the task needs it. Memory files have size budgets, and old material is archived, not deleted. |
| No context loss | Project state lives in files with fixed names and fixed jobs. Any agent in a fresh chat can resume from the files alone. |
| Less hallucination and slop | Claims carry a label and a source. "Done" needs evidence. Banned-pattern lists for UI, copy and code. |
| Safe to customise | The kit's own files live in one folder the kit owns and replaces on update. User overrides and project memory live elsewhere and are never touched. |

### Non-goals

- Not a framework, CLI app or MCP server. There is nothing to run during normal work.
- Not a code generator or project scaffold.
- No dependency on any one AI vendor, editor or language runtime.

### Anti-goals (failure even if it "works")

- An always-loaded file that grows every week until it costs more than it saves.
- Ceremony on small tasks: a plan, tracker and review for a one-line fix.
- Updates that overwrite a user's edits.
- Rules that only work in one AI tool.

## What gets installed

The kit is installed at a **workspace root**: the folder you open in your editor. That folder may be a single git repo or may wrap several repos (for example a frontend and a backend).

```
<workspace>/
├── AGENTS.md                 entry point; kit block (managed) + project block (yours)
├── CLAUDE.md                 "@AGENTS.md"  (Claude Code)
├── GEMINI.md                 "@AGENTS.md"  (Gemini CLI, Antigravity)
├── .agentkit/                KIT-OWNED. Replaced on update. Don't edit.
│   ├── VERSION
│   ├── INDEX.md              what to read, when
│   ├── rules/                standards, loaded on demand
│   ├── playbooks/            step-by-step procedures, loaded on demand
│   ├── security/             RULEBOOK.md (non-negotiable) + checklists/
│   ├── templates/            shapes for memory files, plus the AGENTS.md
│   │                         template and tool stub the installer writes
│   ├── doctor.sh             health and token-budget check
│   └── doctor.ps1
├── .agentkit.local/          YOURS. Never touched by updates.
│   ├── README.md
│   ├── overrides.md          your rules; win over .agentkit/ on conflict
│   └── budgets.env           doctor size budgets (optional)
└── docs/agent/               YOURS. Project memory.
    ├── STATUS.md             current state; rewritten, never appended (≤ 40 lines)
    ├── LOG.md                append-only work log
    ├── log/                  archived log months (YYYY-MM.md)
    ├── DECISIONS.md          one-line index of decisions in force
    ├── decisions/            one file per decision with full reasoning
    ├── OPEN-QUESTIONS.md     waiting on a human
    ├── plans/<date-slug>/    spec.md, plan.md, tracker.md per feature or milestone
    └── research/             findings with sources
```

### Ownership rules

| Path | Owner | On install | On update |
|---|---|---|---|
| `.agentkit/` | kit | created | replaced entirely |
| `AGENTS.md` kit block (between `<!-- agentkit:start -->` and `<!-- agentkit:end -->`) | kit | written | replaced |
| `AGENTS.md` outside the markers | user | template written once | never touched |
| `CLAUDE.md`, `GEMINI.md` | user | created if missing | never touched |
| `.agentkit.local/` | user | seeded if missing | never touched |
| `docs/agent/` | user | seeded if missing | never touched |

If `AGENTS.md` exists without markers (a project with its own harness), the installer does not touch it and points the user to the **adopt** playbook, which merges by hand with the user's approval.

## The load model

Agents read files in three rings. Each ring is only opened when the one before it says to.

**Ring 0: always loaded (target ≤ 8 KB total)**
- `AGENTS.md`: what the project is, how to work, where things are.
- `docs/agent/STATUS.md`: where things stand and the next step.
- `docs/agent/DECISIONS.md`: one line per decision in force.

**Ring 1: on demand, by task**
- `.agentkit/INDEX.md` lists every rule and playbook with a one-line "read when". The agent opens only the ones that match the task. A CSS tweak loads the UI rules, not the backend rules.
- `.agentkit.local/overrides.md`, when it has content.
- The active plan's `tracker.md`.

**Ring 2: on demand, by need**
- A decision's full file, a plan's spec, research notes, archived logs, source code. Read the part needed, not the whole folder.

This mirrors progressive disclosure as used by Agent OS standards indexes and `llms.txt`, and follows the published guidance to keep always-loaded instruction files short (Anthropic recommends under 200 lines for `CLAUDE.md`; Codex truncates `AGENTS.md` chains past 32 KiB).

## Memory model

Each memory file has one job and one way it changes. Mixing these is what makes harnesses bloat and drift.

| File | Job | Changes by | Size control |
|---|---|---|---|
| `STATUS.md` | Now: phase, in progress, next step, blockers | Rewrite | ≤ 40 lines, enforced by doctor |
| `LOG.md` | History: what was done, files, how verified | Append only | Rotated to `log/YYYY-MM.md` by the compact playbook |
| `DECISIONS.md` | Index of decisions in force | Add a row; move replaced rows out | ≤ 80 lines |
| `decisions/D-NNNN-slug.md` | Full context, options, reasoning | Write once; supersede, never edit | Read on demand |
| `OPEN-QUESTIONS.md` | Waiting on a human | Add; delete when answered (answer becomes a decision) | Small by nature |
| `plans/<slug>/tracker.md` | Task status for one plan | Edit one status cell at a time | One-line cells; notes go to `LOG.md` |

**Truth order when files disagree:** the user's latest words, then the code and git history, then the memory files, then chat recall. When code and `STATUS.md` disagree, the agent fixes `STATUS.md` and says so.

## Work tiers

Process scales with the work. The agent picks a tier, states it in one line, and moves up a tier the moment the work grows.

| Tier | Example | What happens |
|---|---|---|
| Quick | typo, one-line fix, config value | Do it, verify it, one `LOG.md` line |
| Small | one behaviour, a few files | 3–6 line plan in chat, build, verify, log entry |
| Feature | a feature, milestone or anything spanning sessions | `plans/<slug>/`: spec, plan, tracker. Tasks with IDs, done criteria and a verify command. Decisions logged. Handoff at the end. |

The tracker keeps one task `doing` at a time, takes the next task in priority order, records blocked tasks with a reason, and never renumbers IDs. New work found mid-task becomes a new ID instead of scope creep.

## Session lifecycle

**Start (or "resume"):** read ring 0, check `STATUS.md` against the code and recent git log, open the active tracker if `STATUS.md` names one, then tell the user in two or three lines where things stand and what's next.

**During:** findings, decisions and open questions go into files when they happen, not at the end.

**Handoff:** triggered at the end of a task, before pausing, or when the chat grows long. Rewrite `STATUS.md`, append a `LOG.md` entry, log decisions, update the tracker. The test: a different AI tool in a fresh chat can continue from the files alone.

## Quality model

Rules are split by domain so only the relevant ones load:

- `working.md`: memory, scope, asking vs assuming, tiers.
- `context-economy.md`: how to spend tokens: read ranges not files, search before read, sub-agents for wide searches, no pasted logs.
- `truthfulness.md`: claim labels (verified / inferred / unverified), sources, evidence for "done", checking that APIs and packages exist.
- `research.md`: sources, dates, where findings go.
- `engineering.md`: honest code, tests, dependencies, shape of changes.
- `frontend-ui.md`: tokens, states, accessibility, responsive, banned AI-slop patterns.
- `backend.md`: validation, errors, idempotency, time, data access, API shape.
- `security-privacy.md`: the everyday security subset, pointing into the rulebook.
- `writing.md`: docs, commits, copy.

**Security** is separate and stricter. `security/RULEBOOK.md` holds 20 hard rules, the waiver process and the production release gate. Thirteen checklists cover classic web security and AI-era risks (prompt injection, tool poisoning, hallucinated packages, hidden-Unicode instruction attacks, the coding agent's own permissions). `.agentkit.local/overrides.md` can tighten the rulebook but never relax it; only a logged owner waiver can. See [security.md](security.md).

**Definition of done** is a playbook, not a rule: a checklist run before the word "done", needing evidence (command output, a screenshot path that exists on disk) for each line.

## Enforcement

Markdown rules are guidelines; agents sometimes skip them. The kit adds one optional check, `doctor`, that needs only a shell:

- Ring-0 size over budget, `STATUS.md` over 40 lines, `LOG.md` over its rotation size, `DECISIONS.md` over 80 lines.
- `STATUS.md` older than the newest `LOG.md` entry (forgotten handoff).
- More than one `doing` task in a tracker.
- Missing stubs or kit markers.
- Likely secrets in memory files (reported by file name, never the value).
- `.env` files inside a git repo that aren't git-ignored.
- Invisible Unicode (tag characters, zero-width, bidi controls) in agent instruction and memory files.

Doctor exits non-zero when it finds issues, so it can run in CI or a git hook if the user wants. Budgets are configurable in `.agentkit.local/budgets.env`.

## Installation and update

Two equivalent paths:

1. **Agent-run.** Point any agent at `INSTALL.md` in the kit repo. It follows the same steps the scripts do. No runtime needed.
2. **Script.** `install.sh` (macOS, Linux, Git Bash) or `install.ps1` (Windows PowerShell 5.1+). Both take a target path and `--dry-run`/`-DryRun`. Update is the same command; the ownership rules above make it safe to re-run.

## Tool support

| Tool | How it finds the rules |
|---|---|
| Codex, Cursor, GitHub Copilot, Windsurf, Cline, Kiro, Aider (configured), Zed, Jules, Amp | Reads `AGENTS.md` natively |
| Claude Code | `CLAUDE.md` contains `@AGENTS.md` |
| Gemini CLI, Antigravity | `GEMINI.md` contains `@AGENTS.md` |

Anything else: tell the agent "read AGENTS.md first".

## Decisions behind this design

| Decision | Reason |
|---|---|
| Plain markdown, no runtime | Works in every tool; nothing to install or break |
| `AGENTS.md` as the single source | Open standard read natively by most agents; one place to edit |
| Import stubs, not symlinks | Symlinks break on Windows and prompt for approval in some tools |
| Kit folder replaced whole on update; user files never touched | Users customise freely without fear of losing edits |
| Decisions as index + files | A single decisions table grew past 50 KB in real use and was loaded every session |
| Log rotation | Same reason for progress logs |
| Tiers instead of mandatory ceremony | Full process on a typo wastes more tokens than it saves |
| Optional doctor, no required hooks | Hooks are tool-specific; a shell script works everywhere |
| Security rulebook can't be relaxed by overrides | Agents are easily talked into "just make it work"; a waiver must be a deliberate, logged owner decision |
| Memory seeded from templates, not a second copy | Each file shape exists once, so there's nothing to drift |
