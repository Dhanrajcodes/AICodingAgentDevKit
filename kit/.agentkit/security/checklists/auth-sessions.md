# Checklist: authentication and sessions

Sign-in, sign-up, passwords, sessions, tokens, OAuth and MFA. Rules: SR-07 to SR-11. Sources: OWASP ASVS 5.0; OWASP Authentication, Password Storage, Session Management and JWT cheat sheets; RFC 9700.

## Passwords
- [ ] Hashed with argon2id: m=19456 KiB, t=2, p=1, or m=47104 KiB, t=1, p=1 (or another OWASP-equivalent pair). Legacy: bcrypt cost ≥ 10 with a 72-byte input limit. Never MD5, plain SHA, or reversible encryption.
- [ ] Minimum length 8 with MFA, 15 without. Allow at least 64 characters, any characters. No composition rules; check against breached-password lists.
- [ ] Same response and similar timing for "wrong password" and "no such user". No account enumeration on sign-in, sign-up or reset.
- [ ] Reset tokens: random, single-use, short-lived (≤ 1 hour), stored hashed, invalidated on use and on password change.

## Sessions (cookies)
- [ ] Session ID from a CSPRNG, ≥ 64 bits of entropy, never in URLs.
- [ ] Cookie flags: `Secure`, `HttpOnly`, `SameSite=Lax` or `Strict`, the `__Host-` prefix where possible, no broad `Domain`.
- [ ] New session ID at sign-in and on any privilege change (prevents fixation).
- [ ] Server-side idle timeout (15-30 min for normal apps, shorter for high-value ones) and an absolute timeout (about 4-8 hours).
- [ ] Sign-out and password change invalidate the session on the server, and other sessions when the user asks.

## Tokens (JWT and similar)
- [ ] Allowed algorithms hard-coded when verifying. Reject `alg: none`. Never accept both HMAC and public-key algorithms for the same key.
- [ ] Verify signature, `exp`, `nbf`, `iss` and `aud` every time. Access tokens live minutes, not days.
- [ ] Refresh tokens rotate on every use with reuse detection, or are sender-constrained (RFC 9700). Revocation keyed by `jti`.
- [ ] Browser apps keep tokens in `HttpOnly` cookies, not `localStorage` (where XSS can read them).
- [ ] No sensitive data in token payloads; anyone can decode them.

## OAuth / OpenID Connect
- [ ] Authorization Code flow with PKCE. No implicit flow.
- [ ] `state` and `nonce` checked. Exact redirect URI matching; no wildcards.
- [ ] ID token signature, issuer, audience and expiry verified, using the provider's SDK.
- [ ] Accounts linked only by a verified email, never an unverified claim.

## MFA and abuse
- [ ] MFA offered to all users and required for admins. Passkeys (WebAuthn) first, then TOTP; SMS only as a fallback, since SIM swaps and phishing kits defeat it.
- [ ] Phishing-resistant sign-in (passkeys or security keys) required for admin and support accounts.
- [ ] Rate limits and growing delays on sign-in, OTP, reset and sign-up, per account and per IP, designed so an attacker can't lock real users out at will.
- [ ] Bot protection on sign-up if abuse is likely.

## Verify
Try: wrong password vs unknown user (same response?), a reused reset link, an expired token, a token with `alg: none`, a token signed with the wrong key, the session cookie after sign-out, and 50 rapid sign-in attempts.
