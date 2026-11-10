# Rule: how to work

How agents behave on every task: memory, scope, asking, tiers.

## Memory lives in files
- The chat is not memory. Sessions end, tools change, context gets compacted. Write down anything another agent would need, when it happens, not at the end.
- `STATUS.md` is the present, `LOG.md` is the past, `DECISIONS.md` is what's settled, `OPEN-QUESTIONS.md` is what's waiting on a human.
- If a file and your recall disagree, the file wins. Re-read it.
- When you resume, trust the files and git history over anything you think you remember.

## Pick a tier
| Tier | Signs | You do |
|---|---|---|
| Quick | One obvious change, no design choice | Do it, verify it, one LOG line |
| Small | One behaviour, a few files, finishes this session | 3-6 line plan in chat, build, verify, LOG entry |
| Feature | New capability, several parts, needs decisions, or spans sessions | `plans/<date-slug>/` with spec, plan, tracker (see `playbooks/plan-and-track.md`) |

State the tier in one line before starting. If a quick task turns into a design question, stop and move up a tier. Never run feature-tier ceremony on a quick task.

## Ask, don't assume
- Scope comes from the user, the project docs and `DECISIONS.md`. Nothing else.
- One clear question beats a page of guesses. Ask before building, not after.
- Ask as multiple choice: 2-4 concrete options, your recommendation first, marked "(Recommended)", each with its trade-off in one line. Use the tool's question UI if it has one.
- Batch related questions. Don't ask what you can find in the code.
- If you must make a call to keep moving, log it in `DECISIONS.md` as `agent (proposed)` and say so in your reply. Never record your call as the user's.
- Never reopen a logged decision on your own. Raise it as a question.

## Stay inside the task
- Change only what the task needs. No drive-by refactors, renames or reformatting.
- Found something else wrong? Add it to `OPEN-QUESTIONS.md` or as a new tracker ID. Don't fix it on the side.
- Before creating a file, component, helper or endpoint, search for an existing one.
- Follow existing patterns. If a pattern is wrong, raise it rather than start a second one.

## Small, verified steps
- Work in steps that can each be checked. Verify each before the next.
- Prefer one finished thing over three half-done things.
- If a step fails, stop and understand why before trying something else. Two failed attempts at the same thing means step back and re-read the problem.

## Talking to the user
- Lead with the result or the question. Keep updates short.
- Say plainly what failed, what was skipped and what is unverified.
- Don't narrate what you're about to do at length; do it.

## Multiple agents and sessions
- One agent edits a given area at a time. If two sessions might overlap, say so.
- Before resuming someone else's work, read their last LOG entry and the tracker row; don't redo finished tasks.
- When you take over a plan, keep its IDs and format.
