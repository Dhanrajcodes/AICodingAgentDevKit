# Playbook: edge cases

Use when designing or building any feature, flow, job, form or integration. Walk the list, keep what applies, and turn each kept item into a test or an explicit "won't handle (why)" line in the spec.

## Input
- Empty, missing, null, whitespace-only, very long, unicode and emoji, right-to-left text.
- Wrong type, wrong format, out of range, negative, zero, huge numbers, decimals where integers are expected.
- Duplicates, near-duplicates, different casing.
- Malicious input: script tags, SQL fragments, path traversal, oversized payloads.

## Users and access
- Signed out, session expired mid-action, wrong role, someone else's resource.
- Two users editing the same thing. The same user in two tabs or devices.
- First-ever user (nothing exists yet) and a power user (thousands of items).
- Account archived, deleted or suspended while active.

## Timing and order
- Double clicks and double submits. Retries after a timeout that actually succeeded.
- Events arriving twice, late or out of order.
- Midnight, month end, leap day, daylight saving changes, time zones where the date differs from UTC.
- Long-running work interrupted halfway (deploy, crash, closed tab).

## Network and dependencies
- Slow, offline, flaky connection. Request times out.
- Third-party service down, rate limited (429), returns an unexpected shape, or changes its API.
- Partial failure: step 2 of 3 fails. What state is left, and who finds out?

## Data volume and shape
- Zero, one, many, and far more than expected items. Pagination boundaries.
- Optional fields missing. Old records created before a schema change.
- Large files, unsupported file types, corrupt uploads.

## UI
- Loading, empty, error, partial and content states.
- Long names and labels, translations that are 30% longer, small screens, zoom at 200%.
- Keyboard only, screen reader, reduced motion.
- Browser back, refresh mid-flow, deep link straight into a step.

## Operations
- Feature flag off. Config value missing. Migration not yet run.
- Running the job twice. Running it after a missed day.
- What does someone see when it fails, and how do they fix it?

## Record
In the spec or plan, list each case you'll handle with its expected behaviour, and each you won't, with why. Handled cases get tests.
