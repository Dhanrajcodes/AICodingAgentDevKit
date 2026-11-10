# Rule: engineering

The bar is production SaaS: nothing that works only sometimes, no failure nobody notices. These rules target the defects AI agents most often introduce. Project-specific tooling goes in the project section of `AGENTS.md`.

## Honest code
- **Errors:** catch only what you can handle. Every catch rethrows, returns a typed error, or records a failure someone can see. No empty or log-only catches.
- **No hidden fallbacks:** if a dependency fails, record the failure state (`failed`, `pending_retry`). Never save a guessed or default value as if it were real.
- **Nothing unfinished:** no TODO, FIXME, stub, placeholder, mock data or commented-out code in work called done. Open items go in STATUS or the tracker.
- **No test-shaped code:** never branch on test data or environment names in production code. Never hardcode a value to satisfy a test.
- **Guardrails stay on:** never disable a lint rule, type check, hook or CI step, and never use `--no-verify`, `@ts-ignore`, `# type: ignore` or `eslint-disable` to get green. To change a rule, ask and log it.
- **Types:** use the strictest mode the project has. No `any` or unchecked casts on external data. Parse input from outside (requests, webhooks, LLM output, files, env) with a schema at the boundary.

## Tests
- A red test means the code is wrong until proven otherwise. Never delete, skip, weaken or rewrite a test's expected value without the user's sign-off.
- Write the test first for logic and bugs: watch it fail for the right reason, then make it pass.
- Test behaviour, not implementation. Cover the normal path and the edge cases from `playbooks/edge-cases.md`.
- Mock only at the edges you don't own (third-party HTTP, payment, email, LLM). Run the real database in tests when the project allows it.
- At least one test per critical flow goes end to end.
- No `.only`, `.skip`, `xit` or equivalent left in.

## Dependencies
- Add a library only when it earns its place. Prefer the platform and what's already installed.
- Before adding: real package name, maintained, licence fits, not a duplicate of something already used. Log it in `DECISIONS.md`.
- Commit the lockfile. Install with the lockfile (`npm ci`, `pnpm i --frozen-lockfile`, `uv sync`).
- Read the docs for the installed version before using an API.

## Shape of changes
- Reuse first: search before writing a helper, component or endpoint.
- No abstraction until there are two real callers. No speculative config, flags or layers (YAGNI).
- Small, focused modules organised by feature. One concern per file. Files past roughly 400 lines are a smell; past 1000, split.
- No magic values: named constants, config in one place.
- Delete code you replace in the same change.
- One concern per change. Aim for reviewable diffs (a few hundred lines).
- Readable over clever. Early returns over deep nesting. Names say what things are.

## Performance
- Know the hot paths. Avoid N+1 queries, unbounded loops over remote data, and loading whole tables.
- Paginate lists. Index what you filter and sort on.
- Don't optimise without a measurement, but don't ship known-quadratic work on real data either.

## Before calling it done
Run what the project has: format, lint, typecheck, unit tests, build, and the real flow (browser, CLI, API call). Show the output. Then run `playbooks/definition-of-done.md`.
