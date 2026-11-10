<!-- agentkit:start -->
# AGENTS.md

Read this first. It applies to every AI agent in this workspace (Claude, Codex, Gemini, Cursor, Copilot or any other). The section between the agentkit markers is managed by the AI Coding Agent Dev Kit; edit the project section below it instead.

## Start of every session
1. Read `docs/agent/STATUS.md` (where things stand) and `docs/agent/DECISIONS.md` (owner and doc rows are settled; don't reopen them. `agent (proposed)` rows await confirmation).
2. If STATUS names an active plan, read that plan's `tracker.md`.
3. Check STATUS against the code and recent git log. If they disagree, the code wins: fix STATUS and say so.
4. Tell the user in 2-3 lines where things stand and what you'll do next.
5. Load nothing else until the task needs it. `.agentkit/INDEX.md` says which rule or playbook to read for which task.
6. If `.agentkit.local/overrides.md` has content, read it. It wins over `.agentkit/`, except the security rulebook, which it can only make stricter.

## How to work
- **Files are the memory, not the chat.** Anything another agent would need goes into `docs/agent/` when it happens.
- **Pick a tier and say it:** quick (do, verify, one log line), small (short plan in chat, build, verify, log), feature (plan folder with spec, plan, tracker). Move up a tier the moment the work grows. Details: `.agentkit/playbooks/plan-and-track.md`.
- **Never assume a requirement.** If it isn't in the code, the docs or DECISIONS, ask. Ask as multiple choice with your recommended option first, marked "(Recommended)". Use the tool's question UI if it has one.
- **Never invent facts, APIs, packages, versions or results.** Check the installed version and its docs before using an API. Label claims verified, inferred or unverified.
- **Proof before "done".** Run it, test it, show the output. Follow `.agentkit/playbooks/definition-of-done.md`. If something wasn't verified, say so plainly.
- **No hacks.** Fix causes, not symptoms. Never weaken, skip or delete a test, silence an error or disable a check to get green.
- **Stay inside the task.** Note unrelated problems in `docs/agent/OPEN-QUESTIONS.md` instead of fixing them on the side.
- **Spend tokens only where the project needs them.** Read the part of a file you need, search before reading, keep long output out of the chat. See `.agentkit/rules/context-economy.md`.

## Truth order
The user's latest words, then the code and git history, then `docs/agent/` files, then your memory of the chat. Re-read a file instead of trusting recall.

## Memory files (`docs/agent/`)
| File | Job | How it changes |
|---|---|---|
| `STATUS.md` | Now: phase, in progress, next step, blocked | Rewrite. Max 40 lines |
| `LOG.md` | What was done, files, how verified | Append only |
| `DECISIONS.md` | One line per decision in force | Add rows; full reasoning in `decisions/` |
| `OPEN-QUESTIONS.md` | Waiting on a human | Add; delete when answered |
| `plans/<date-slug>/` | spec, plan, tracker for one feature | Tracker: one task `doing` at a time |
| `research/` | Findings with sources and dates | One file per topic |
| `security/` | Threat model, review reports, incident plan | Created by `.agentkit/playbooks/security-review.md` |

## End of every task, or when the chat grows long
Run `.agentkit/playbooks/handoff.md`: rewrite STATUS, append to LOG, log decisions, update the tracker. The test: a different AI tool in a fresh chat can continue from the files alone. If context is long or you notice drift, hand off and suggest a fresh session.

## Security is non-negotiable
`.agentkit/security/RULEBOOK.md` holds hard rules SR-01 to SR-20 and the production release gate. Read it before production-bound work on auth, access, data, secrets, dependencies, infrastructure, uploads, payments or AI features. Overrides can't relax it; only an explicit owner waiver logged in DECISIONS can. If a task needs a rule broken, stop and ask.

## Never
- Write secrets, tokens, keys or real personal data into any file that gets committed.
- Install a package you haven't verified exists under that exact name, or run a script from outside you haven't read.
- Edit `.agentkit/`. It is replaced on update. Put changes in `.agentkit.local/overrides.md`.
<!-- agentkit:end -->

# Project

## What this is
Invoicer (sample): invoicing for freelancers and small studios. Web app plus a public invoice page. Bar: production SaaS, calm and minimal UI. Users' financial data is sensitive (ASVS Level 2).

## Layout
- `web/`: Next.js app (dashboard and public invoice pages).
- `api/`: Fastify API and background worker.
- `docs/client/`: requirement notes from the owner. Read only.

## Commands
- Install: `pnpm install --frozen-lockfile`
- Dev: `pnpm dev` (web on :3000, api on :4000; needs `docker compose up db`)
- Test: `pnpm test` · Typecheck: `pnpm typecheck` · Lint: `pnpm lint` · E2E: `pnpm --filter web e2e`

## Stack
TypeScript strict, Next.js, Fastify, PostgreSQL with Drizzle, pg-boss jobs, Tailwind with tokens in `web/src/styles/tokens.css`.

## Project rules
- Money is integer minor units plus an ISO currency code (D-0002).
- Invoice numbers are per-workspace sequences, assigned in the same transaction as the invoice (D-0004).
