# Checklist: APIs and input handling

Any endpoint, form, webhook, queue consumer or parser. Rules: SR-12, SR-13, SR-15, SR-16. Sources: OWASP API Security Top 10 2023; OWASP Top 10:2025 A05 (Injection); CWE Top 25 (2025), where XSS (CWE-79) and SQL injection rank at the top.

## Validation
- [ ] Every input validated on the server with a schema: body, params, query, headers, cookies, webhooks, queue messages, file contents, LLM output.
- [ ] Types, lengths, formats, ranges and enums enforced. Unknown fields rejected or stripped.
- [ ] Limits on body size, array length, nesting depth, page size and string length.
- [ ] Input canonicalised (unicode, path, URL encoding) before it is validated.

## Injection
- [ ] SQL and NoSQL: parameterised queries or query builders only. Identifiers that can't be parameters (sort column, direction) come from an allow-list.
- [ ] No user input in shell commands. If unavoidable, pass an argument array, never a shell string.
- [ ] File paths built from input are normalised and checked to stay inside the allowed folder.
- [ ] Templates auto-escape. No raw rendering of input.
- [ ] No `eval`, dynamic imports from input, or deserialising untrusted data with unsafe formats (pickle, Java serialisation, unsafe YAML load).
- [ ] Regexes run on input can't backtrack catastrophically (ReDoS).

## Resource limits (API4)
- [ ] Rate limits per user and per IP, stricter on expensive and auth endpoints.
- [ ] Timeouts on request handling and on every outbound call.
- [ ] No unbounded queries, exports or fan-outs.
- [ ] Spend caps per user and per day on paid third-party calls (SMS, email, LLM).

## Webhooks
- [ ] Signature verified over the raw body with a constant-time compare, plus a timestamp check against replay.
- [ ] Duplicate deliveries handled (dedupe on the event ID).
- [ ] Respond fast; do the work in a background job.

## CSRF and CORS
- [ ] Cookie-authenticated state changes protected by `SameSite` cookies plus a CSRF token or an origin check.
- [ ] CORS is an allow-list of exact origins. Never `*` with credentials, never a reflected `Origin`.

## Responses and errors
- [ ] One error format with a stable code. No stack traces, SQL, file paths or library versions in responses.
- [ ] Responses carry only the fields the client needs: no whole database rows, password hashes or internal flags.
- [ ] Auth failures don't reveal which part failed.

## Inventory (API9, API10)
- [ ] Every endpoint documented (OpenAPI or equivalent). Old versions and debug or test endpoints removed from production.
- [ ] Data from third-party APIs validated like user input.

## Verify
Send each endpoint wrong types, huge payloads, injection strings, no auth, extra fields and duplicate requests. Show the responses.
