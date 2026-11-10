# Playbook: research

Use when researching a library, API, approach, limit, price, law or competitor. Rules: `rules/research.md`.

1. **Check first:** search `docs/agent/research/` and `DECISIONS.md`. If it's answered and fresh, use it.
2. **Frame it:** one sentence for the question, one for the decision it feeds, and the criteria that matter for this project.
3. **Scope it:** decide what's enough. A quick fact needs one official source; a stack choice needs a comparison.
4. **Delegate if wide:** if the tool has sub-agents and the search is broad, send one with a narrow brief and take back only the conclusion and sources.
5. **Gather:** official docs for the version in use first, then source code and issues, then dated write-ups. Note the URL and date for each fact.
6. **Validate:** cross-check important claims or test them directly with a small experiment.
7. **Write it up:** `docs/agent/research/<topic>.md` using `templates/research-note.md`: question, findings with sources and confidence, options compared, recommendation, what's still unknown.
8. **Report:** in chat, give the recommendation, the key reason and the file path. Don't paste the research.
9. **Decide:** if the user picks an option, log it with `playbooks/log-decision.md` and link the note.
