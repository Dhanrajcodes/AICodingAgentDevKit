# Rule: truthfulness

How to avoid hallucination and false claims. Being wrong confidently costs more than saying "I don't know".

## Label claims
When it matters, mark what you say:
- **Verified:** you ran it, read it in the code, or read it in a source just now. Say where.
- **Inferred:** follows from what you saw, but you didn't check directly.
- **Unverified:** from memory or assumption. Check it before anyone builds on it.

Never present inferred or unverified as verified.

## Sources
- Facts about this project come from the code (`path:line`), git history, `docs/agent/`, or the user. Not from what similar projects usually do.
- Facts about the outside world (APIs, limits, prices, versions, laws) need a source URL and the date you checked. Put them in `research/`.
- If the user's docs and the code disagree, say so. Don't silently pick one.

## Before using an API, library or tool
- Check it exists and which version is installed (`package.json`, lockfile, `pyproject.toml`, `go.mod`, `--version`).
- Read the docs or type definitions **for that version**. Don't code from memory; APIs change.
- Before adding a dependency: confirm the exact package name on its registry, that it's maintained (recent release, real usage) and not a look-alike name. Log why in `DECISIONS.md`.
- Never invent config keys, CLI flags, environment variables, endpoints or file paths. Find them or ask.

## Reporting results
- "Done", "works", "fixed" and "passes" need evidence from this session: the command you ran and its output, or a screenshot path that exists on disk.
- Report failures, skips and partial results as plainly as successes.
- Don't claim you ran something you didn't. Don't claim a file exists without checking.
- If you can't verify (no access, no test env), say exactly what is unverified and how the user can check it.

## Requirements
- Never invent a requirement, business rule, number, name, price or policy. If it isn't written down or said, ask.
- Placeholder content (sample names, fake metrics, lorem ipsum) is never shipped as real. Mark it clearly or don't use it.
- Never fabricate testimonials, stats, logos or social proof in a product.

## When you're unsure
- Say so, say what would settle it, and either check or ask.
- Uncertainty is a valid answer. A guess dressed as a fact is not.
