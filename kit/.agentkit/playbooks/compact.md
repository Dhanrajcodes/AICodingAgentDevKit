# Playbook: compact memory

Use when doctor warns about size, when STATUS or DECISIONS feels long, or at the end of a milestone. Goal: keep ring 0 small without losing anything.

## STATUS.md (limit 40 lines)
- Keep only: phase, active plan, in progress, next step, blocked on.
- "Done recently" items older than the current milestone go away; they're already in LOG.
- Long paragraphs become bullets with links to the plan or LOG entry.

## LOG.md (rotate past about 24 KB)
- Move every entry from earlier months to `docs/agent/log/<YYYY-MM>.md`, one file per month, in order. Moving, not rewriting: entries stay byte-for-byte.
- Leave the current month in `LOG.md` with a line at the top: `Older entries: docs/agent/log/`.

## DECISIONS.md (limit about 80 lines)
- Each row one short line. Move long reasons into `decisions/D-NNNN-<slug>.md` and link it.
- Move rows marked replaced into the `## Replaced` section, or into `decisions/replaced.md` if that section itself grows long.
- Never change an ID or the meaning of a decision while compacting.

## Trackers
- Finished plans stay where they are; they aren't loaded unless STATUS points to them.
- Long notes in tracker cells move to LOG.

## Research
- Notes older than a few months that are still relied on: add "recheck before use" or refresh them.

## After
Run doctor until it's clean. Append a LOG entry: `docs(agent): compact memory`, with what moved where.
