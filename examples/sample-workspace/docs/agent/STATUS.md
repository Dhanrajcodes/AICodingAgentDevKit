# Status

Last updated: 2026-11-06

## Phase
MVP build. Invoices, clients and PDF export done. Now: team invites.

## Active plan
`docs/agent/plans/2026-11-04-team-invites/` (tracker there).

## In progress
- T-03 accept-invite endpoint. `api/src/invites/accept.ts` written; tests in `api/src/invites/accept.test.ts` cover the happy path and expired token. Still red: "token reused after acceptance" (the status check runs after the insert; must move into the same transaction as the membership insert).

## Next step
- Make `acceptInvite` update the invite with `WHERE status = 'pending'` inside the transaction, rerun `pnpm --filter api test invites`, then T-04 (invite email).

## Blocked on
- Q1 in OPEN-QUESTIONS (can members see invoice totals?) blocks T-06, not T-03 to T-05.
