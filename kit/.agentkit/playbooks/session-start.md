# Playbook: session start

Use when starting or resuming work: a fresh chat, a different AI tool, or after context was compacted. Also what "resume" or "continue" means.

1. Read `AGENTS.md` (already loaded in most tools).
2. Read `docs/agent/STATUS.md`: phase, in progress, next step, blockers.
3. Read `docs/agent/DECISIONS.md`. Treat every row as settled.
4. If STATUS names an active plan, read its `tracker.md`. Find the `doing` row, or the first `todo` in priority order.
5. Read the last one or two entries of `docs/agent/LOG.md` only if STATUS doesn't say exactly where work stopped.
6. Check reality: `git status`, `git log --oneline -10`, and the files STATUS says are in progress. If STATUS and the code disagree, the code wins: fix STATUS and mention it.
7. If `.agentkit.local/overrides.md` has content, read it.
8. Tell the user in 2-3 lines: where things stand, what you'll do next, and the tier. For a large step or a change of direction, wait for a go-ahead.
9. Before the work itself, open only the rules and playbooks `INDEX.md` lists for this kind of task, and only the source files the next step needs.

## Fresh install or empty memory
If `STATUS.md` is still the template:
- Read the project section of `AGENTS.md`, the README and the repo layout (top level only).
- Offer to fill the project section of `AGENTS.md` and a first `STATUS.md` with the user. Ask, don't guess, about scope and quality bar.

## If something is missing
- No `docs/agent/`: the kit isn't installed here. Follow the kit's `INSTALL.md`, or ask the user.
- Existing agent docs in other places (`CLAUDE.md` with content, `PROGRESS.md`, `memory-bank/`): run `playbooks/adopt.md`.
