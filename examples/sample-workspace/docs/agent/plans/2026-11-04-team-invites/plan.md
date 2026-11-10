# Plan: team invites

Spec: `spec.md`. Tracker: `tracker.md`. Work one task at a time (`.agentkit/playbooks/plan-and-track.md`).

## Approach
Invites are rows with a hashed token. Creating one sends an email job. Accepting runs in one transaction: lock the invite, check it's pending and unexpired, create or reuse the user, insert the membership, and mark the invite accepted.

## File map
- `api/drizzle/0007_invites.sql`, `api/src/db/schema/invites.ts`: table.
- `api/src/invites/create.ts`, `accept.ts`, `revoke.ts`: endpoints, each with a test file.
- `api/src/jobs/send-invite-email.ts`: email job.
- `web/src/app/settings/team/`: team page.

## Tasks

### T-01 Invites table (P0)
- Done when: migration runs forward; unique pending invite per (workspace, lower(email)).
- Verify: `pnpm --filter api test db`

### T-02 Create invite (P0)
- Uses: `requireRole(['owner','admin'])`. Produces: `createInvite(workspaceId, email, role) -> { inviteId }`.
- Done when: member → 404, other workspace → 404, duplicate pending → 409, rate limit 20/h.
- Verify: `pnpm --filter api test invites`

### T-03 Accept invite (P0)
- Produces: `acceptInvite(token, userId?) -> { workspaceId }`.
- Done when: expired, revoked and reused tokens rejected; existing member gets no duplicate; all in one transaction.
- Verify: `pnpm --filter api test invites`

### T-04 Invite email (P0)
- Done when: job sends once per invite (idempotent on invite ID); link contains only the raw token.
- Verify: `pnpm --filter api test jobs`

### T-05 Revoke invite (P1)
- Verify: `pnpm --filter api test invites`

### T-06 Team settings page (P1)
- Done when: list members and pending invites; invite form; revoke; all four UI states; keyboard and 320 px checked; screenshots saved.
- Verify: `pnpm --filter web e2e team`
