# Decisions in force

Settled. Don't reopen without the owner. One short line each; full reasoning in `decisions/D-NNNN-slug.md` when linked. How to add or replace: `.agentkit/playbooks/log-decision.md`.

By: `owner` (the human said it), `doc` (written in project docs), `agent (proposed)` (not yet confirmed).

| ID | Decision | By |
|---|---|---|
| D-0001 | Single Postgres database; background jobs on pg-boss, no Redis at this scale | owner |
| D-0002 | Money stored as integer minor units plus ISO 4217 currency code | owner |
| D-0003 | Invoice PDFs rendered server-side and cached in private storage; served by signed URL (15 min) | agent (proposed) |
| D-0004 | Invoice numbers from a per-workspace sequence row locked in the create transaction ([detail](decisions/D-0004-invoice-numbering.md)) | owner |
| D-0005 | Team invites spec approved: owner/admin invite by email, roles admin and member, links expire in 72 h | owner |

## Replaced
