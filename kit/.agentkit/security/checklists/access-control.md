# Checklist: access control

Roles, permissions, multi-tenancy and admin features. Broken access control is the top risk in OWASP Top 10:2025 (A01) and in the API Security Top 10 2023 (API1, API3, API5). Missing authorisation (CWE-862) ranks #4 in the CWE Top 25 (2025). Rules: SR-07, SR-08.

## Every request
- [ ] Authorisation checked on the server for every endpoint, action, query and file, through one central mechanism (middleware, policy layer, guards), not ad-hoc checks.
- [ ] Deny by default. New routes are private until explicitly made public. Public routes are listed in one place.
- [ ] Object level: every read, update and delete by ID confirms the caller may access that object (no IDOR/BOLA).
- [ ] Property level: callers can't read or write fields they shouldn't (role, ownerId, price, isAdmin, tenantId). Writable fields are an explicit allow-list; no mass assignment.
- [ ] Function level: admin and internal actions check the role on the server, never rely on a hidden URL.
- [ ] Resources outside the caller's scope return 404 where revealing that they exist matters.

## Multi-tenancy
- [ ] Every tenant-owned row has a tenant ID, and every query filters by it, enforced in one layer (repository or row-level security) rather than remembered per query.
- [ ] The tenant ID comes from the authenticated session, never from the request body or query string.
- [ ] Caches, search indexes, file storage paths, queues and background jobs are tenant-scoped too.
- [ ] Tests prove a user in tenant 1 can't see or change anything in tenant 2.

## Roles and admin
- [ ] Roles defined in one place, with a permission matrix in the docs.
- [ ] Least privilege per role. Super-admin separate from tenant admin.
- [ ] Admin actions logged (who, what, target, when). Sensitive ones require re-authentication.
- [ ] Impersonation, if any, is logged, visible to the affected user and time-limited.

## Business flows (API6)
- [ ] Sensitive flows (checkout, invites, transfers, coupons, voting) protected against automation and replay: rate limits, idempotency keys, one-time tokens.
- [ ] State transitions checked on the server (can't approve something already rejected, can't refund twice).

## Verify
For each role, call every endpoint with another user's object IDs, with a lower role, signed out, and with forbidden fields in the body. All must fail. Keep these as automated tests.
