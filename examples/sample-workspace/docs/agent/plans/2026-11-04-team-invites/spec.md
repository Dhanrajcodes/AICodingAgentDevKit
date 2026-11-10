# Spec: team invites

- Date: 2026-11-04
- Status: approved (D-0005)

## Why
Studios with more than one person share a single login today. The owner wants each person to have their own account in the studio's workspace.

## Goals
- An owner or admin invites someone by email to a workspace with a role.
- The invitee accepts with a link and joins the workspace, creating an account if needed.

## Non-goals
- SSO or SCIM. Custom roles. Transferring ownership.

## Anti-goals
- An invite link that works twice, works after it expires, or lets someone join a workspace they weren't invited to.
- Leaking whether an email already has an account.

## Requirements
| # | Requirement | Source |
|---|---|---|
| R1 | Owner and admin can invite; members can't | owner |
| R2 | Roles: admin, member | owner |
| R3 | Invite links expire after 72 hours and are single-use | owner |
| R4 | Pending invites can be revoked | owner |
| R5 | One pending invite per email per workspace | agent (proposed), confirmed in D-0005 |

## Constraints
- Tokens: 32 random bytes, stored hashed (security rulebook SR-01, `checklists/auth-sessions.md`).
- Rate limit invite creation (SR-11).

## Edge cases
- Handled: expired link (clear message, ask for a new invite); reused link (rejected); invitee already a member (no duplicate membership); email case differences (normalised); invite revoked while the email is in flight (rejected).
- Not handled: inviting to multiple workspaces in one action (not needed for MVP).

## Open questions
- Q1 (member visibility) affects T-06 only.
