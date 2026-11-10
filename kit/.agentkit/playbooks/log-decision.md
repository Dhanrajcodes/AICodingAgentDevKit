# Playbook: log a decision

Use whenever a choice is made that someone could later ask "why is it like this?" about: scope, behaviour, a rule, a library, a data model, a trade-off, a design direction.

## Small decision (most of them)
Add one row to `docs/agent/DECISIONS.md`:

`| D-0042 | <the decision in one sentence> | <by> |`

- Next ID: one more than the highest ID anywhere in DECISIONS.md or `decisions/`. Four digits.
- If the reason isn't obvious from the sentence, add `(why: ...)` in a few words, or write a full file.

## Big decision (architecture, irreversible, contested, or with real alternatives)
1. Write `docs/agent/decisions/D-0042-<slug>.md` with `templates/decision.md`: context, options considered, decision, consequences, date, by.
2. Add the index row with a link: `| D-0042 | Use Postgres for jobs ([detail](decisions/D-0042-postgres-jobs.md)) | owner |`

## "By" must be honest
- `owner` or `user`: the human said it in so many words.
- `doc`: it's written in the project's requirement docs.
- `agent (proposed)`: you chose it. It stays `proposed` until the human confirms. Then change it to `owner (confirmed)`.

Never record your call as the human's. Never write "the team agreed" unless they did.

## Changing a decision
Decisions are never edited or deleted.
1. Add a new row that replaces it: `| D-0057 | ... (replaces D-0042) | owner |`.
2. Move the old row to the `## Replaced` section at the bottom, ending with `→ D-0057`.
3. If it had a file, add `Status: replaced by D-0057` at the top of that file.

## Keep the index small
The index is loaded every session. If it passes about 80 lines, run `playbooks/compact.md`: move detail into files and keep one short line per decision.

## Code links
If a decision changes the code, mention its ID in the commit message (`feat(jobs): move to pg-boss (D-0042)`).
