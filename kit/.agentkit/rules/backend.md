# Rule: backend

APIs, data, jobs and integrations that hold up under real traffic, retries and bad input.

## Structure
- Layers: transport (route, handler) → service (business logic) → data access. No business logic in handlers; no HTTP concepts in services.
- One module per domain concern. Shared infrastructure (config, logging, time, http client, errors) in one place each.
- Config from environment, validated at startup; fail fast on missing values. One config module, no `process.env` scattered around.

## Input and output
- Validate every external input at the boundary with a schema: body, params, query, headers, webhooks, queue messages, LLM output, file contents.
- Reject unknown or invalid input with a clear 4xx. Never trust client-provided IDs, roles, prices or totals.
- One response shape across the API (for example `{ data, error, meta }`), one error shape with a stable code and a human message.
- Paginate every list (default 20, max 100, cursor-based for large or changing sets). Never return unbounded collections.
- Version public APIs. Don't break existing clients without a plan.

## Errors and failure
- Typed errors mapped to status codes in one place. No stack traces or internals in responses.
- Log with context (request id, user id or role, operation), at the right level. No secrets or personal data in logs.
- Every failure that needs a human is visible somewhere a human looks, not only in logs.
- Timeouts on every outbound call. Retries only for safe operations, capped, with exponential backoff and jitter. Respect `429` and `Retry-After`. Don't retry other 4xx.
- Dead-letter or `failed` state for work that gives up, with a way to replay it.

## Data
- Schema changes through migrations only, forward and reversible where possible. Never edit an applied migration.
- Constraints in the database (not null, unique, foreign keys, checks) as the last line of defence.
- Index what you filter, join and sort on. Check the query plan for hot queries.
- Multi-step state changes in one transaction. Guard concurrent updates (row locks or `UPDATE ... WHERE status = expected`).
- Soft-delete or archive where history matters. Never lose audit-relevant data.
- Avoid N+1: batch or join.

## Idempotency and jobs
- Webhooks and messages can arrive twice and out of order. Dedupe on a natural or provider id with a unique constraint. Only move state forward.
- Handlers for webhooks: verify the signature on the raw body, store, enqueue, return 2xx fast. Work happens in the job.
- Every job is safe to re-run. Key scheduled work by the business date it covers so missed runs catch up once.
- Side effects (email, SMS, payment, notification) recorded under a key in the same transaction as the state change.

## Time and money
- Store timestamps in UTC (`timestamptz` or equivalent). Convert to the user's or business time zone in one time module, explicitly. Never rely on server local time.
- Money as integer minor units or a decimal type, never floats. Store the currency.

## Auth and access
- Authenticate every route except those deliberately public, and list the public ones.
- Authorise every read and write against the caller's role and ownership, server side. Return 404 for resources outside the caller's scope.
- Rate-limit auth and expensive endpoints. See `rules/security-privacy.md`.

## Integrations and LLMs
- Wrap each third-party API in one client module: typed, with timeouts, retries and error mapping.
- Pin API versions in config. Read the provider's docs for limits, quotas and error codes before building.
- LLM calls: structured output parsed with a schema, a timeout, a fallback state (not a fake answer), cost and latency logged. Never let model output run code, SQL or shell unchecked.

## Verify
Hit the real endpoint (curl, test client, end-to-end test) with valid, invalid, unauthorised and duplicate requests. Show the responses.
