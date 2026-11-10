# Log

Append-only. Newest at the bottom. Never edit old entries. Older months move to `log/YYYY-MM.md` (see `.agentkit/playbooks/compact.md`).

Entry shape: `.agentkit/templates/log-entry.md`.

## 2026-11-03: kit installed, project section filled
- Changed: installed the dev kit; filled the project section of AGENTS.md with the owner.
- Files: AGENTS.md, docs/agent/*
- Evidence: `sh .agentkit/doctor.sh` → 0 warnings.
- Decisions: D-0001, D-0002.

## 2026-11-04: research on invoice number collisions
- Changed: measured concurrent invoice creation against the dev database; wrote `research/invoice-numbering.md`.
- Evidence: 200 parallel creates with `MAX(number)+1`: 37 duplicates. With a per-workspace sequence row locked in the transaction: 0 duplicates in 5 runs.
- Decisions: D-0004 (owner chose the locked sequence row).

## 2026-11-04: team invites spec and plan
- Changed: spec approved by the owner (D-0005); plan and tracker written.
- Files: plans/2026-11-04-team-invites/{spec,plan,tracker}.md
- Decisions: D-0005.

## 2026-11-05: T-01 invites table
- Changed: migration `0007_invites` (token hash, role, status, expires_at, unique pending invite per email and workspace).
- Files: api/drizzle/0007_invites.sql, api/src/db/schema/invites.ts
- Evidence: `pnpm --filter api test db` → 41 passed; migration ran forward on a fresh database.

## 2026-11-05: T-02 create-invite endpoint
- Changed: `POST /workspaces/:id/invites`, owner and admin only; token is 32 random bytes, stored as a SHA-256 hash; rate limit 20 per hour per workspace.
- Files: api/src/invites/create.ts, api/src/invites/create.test.ts
- Evidence: `pnpm --filter api test invites` → 9 passed (includes member role → 404, other workspace → 404, duplicate pending → 409). Security checklist `access-control.md` run: pass.

## 2026-11-06: T-03 in progress (handoff)
- Changed: accept endpoint written; one test red (token reuse). See STATUS for the exact next step.
- Files: api/src/invites/accept.ts, api/src/invites/accept.test.ts
- Evidence: `pnpm --filter api test invites` → 13 passed, 1 failed ("rejects a reused token").
- Side effects: none committed; work is on branch `feat/invites`.
