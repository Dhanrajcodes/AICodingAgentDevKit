# Rule: research

How to research, validate and record findings so they survive the session and nobody repeats the work.

## Before researching
- Check `docs/agent/research/` and `DECISIONS.md` first. It may already be answered.
- Write the question in one sentence and what decision it feeds. Research without a decision to make is usually waste.

## Sources, in order of trust
1. The project's own code and data. Measure real data before building on a claim about it.
2. Official docs, specs, changelogs and API references for the version in use.
3. Source code and issue trackers of the library itself.
4. Reputable engineering write-ups with dates.
5. Forums and blogs: leads only, confirm elsewhere.

Prefer recent sources. Note the date for anything that changes (pricing, limits, versions, policies).

## Validate
- Cross-check important claims in two independent sources, or test them directly.
- Prefer a small experiment over a long read when it's cheap: run the call, check the limit, time the query.
- Note what you could not confirm.

## Record
- One file per topic: `docs/agent/research/<topic>.md`, using `templates/research-note.md`.
- Each finding: the claim, the source URL or `path:line`, the date checked, confidence.
- End with a recommendation and the options you rejected, with one-line reasons.
- Bring back only the conclusion to the chat, with a link to the file.
- If the research led to a choice, log it with `playbooks/log-decision.md` and link the note.

## Comparisons
- Compare on the criteria that matter to this project, stated up front.
- A table: option, fit, cost, risk, maturity, notes. Recommend one and say why.
- Include "do nothing" or "build it ourselves" when they're real options.

## Keep it fresh
- Research notes carry a "checked" date. Recheck anything older than a few months before relying on it for a new decision.
