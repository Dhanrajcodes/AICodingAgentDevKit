# Rule: context economy

How to spend tokens and context. Every token loaded is paid for on every later turn, and long context lowers quality. Spend only where the project needs it.

## Load in rings
1. **Always:** `AGENTS.md`, `docs/agent/STATUS.md`, `docs/agent/DECISIONS.md`.
2. **By task:** the rules and playbooks `INDEX.md` points to for this task; the active tracker.
3. **By need:** one decision file, one spec section, one source file range.

Never "read everything first". Never load a whole folder.

## Reading
- Search before you read: find the file and line, then read that range.
- Read the part you need. A 40-line function doesn't need its 900-line file.
- Don't re-read a file you just read unless it changed or you lost it to compaction.
- Prefer the project's own docs and types over guessing, but read only the relevant section.
- Large generated files (lockfiles, builds, logs, snapshots, minified code) are never read whole.

## Writing to the chat
- No pasted file dumps, full logs or long command output. Quote the lines that matter; summarise the rest.
- Redirect long command output to a file and read its tail or grep it.
- Conclusions in the chat, evidence in files (`research/`, `LOG.md`, a screenshot path).
- Don't restate the plan, the rules or earlier messages back to the user.

## Delegating
- If the tool has sub-agents, use them for wide searches, research and audits that would flood your context. Give a narrow brief; take back only the conclusion.
- Don't delegate a lookup you can do in one or two calls.

## Writing memory files
- Memory files are loaded by every future session. Every line must earn its place.
- One fact once. Link to the file that owns it instead of copying it.
- `STATUS.md` ≤ 40 lines. `DECISIONS.md` index ≤ 80 lines. Detail goes in `decisions/` or the plan.
- Tracker cells are one line. Notes go in `LOG.md`.
- Use `file:line` references instead of pasting code into docs.
- When doctor warns or a file feels long, run `playbooks/compact.md`.

## Long sessions
- Signs context is degrading: repeating yourself, forgetting a decision, re-reading the same file, contradicting earlier work.
- When you see them: run `playbooks/handoff.md` and suggest a fresh session. The files carry everything forward.

## Instructions themselves
- Don't add rules to `AGENTS.md` that a linter, formatter, type checker or test can enforce. Configure the tool instead.
- Rules that only apply to one folder belong in a short nested `AGENTS.md` in that folder, not at the root.
