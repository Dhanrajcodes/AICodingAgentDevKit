# Checklist: infrastructure and deployment

Hosting, TLS, HTTP headers, CORS, network and cloud permissions. Rules: SR-03, SR-08, SR-19. Sources: OWASP HTTP Headers and CSP cheat sheets; MDN; Mozilla TLS guidelines v6; NIST SP 800-52 Rev. 2; OWASP Top 10:2025 A02.

## TLS
- [ ] HTTPS only; HTTP redirects to HTTPS. TLS 1.2 minimum, TLS 1.3 preferred; TLS 1.0 and 1.1 off (Mozilla "intermediate" profile or stricter).
- [ ] Certificates auto-renewed and expiry monitored.

## Security headers (verify on the deployed site)
- [ ] `Strict-Transport-Security: max-age=63072000; includeSubDomains` (add `preload` once every subdomain is HTTPS).
- [ ] `Content-Security-Policy` that is strict: nonce- or hash-based `script-src` with `'strict-dynamic'`, `object-src 'none'`, `base-uri 'none'`, and `frame-ancestors 'none'` (or the allowed parents). Nonces unique per response. Start in report-only mode if needed, then enforce.
- [ ] `X-Content-Type-Options: nosniff`
- [ ] `Referrer-Policy: strict-origin-when-cross-origin` (or stricter).
- [ ] `Permissions-Policy` turning off features the app doesn't use (camera, microphone, geolocation...).
- [ ] `Cross-Origin-Opener-Policy: same-origin`; `Cross-Origin-Resource-Policy` set; `Cross-Origin-Embedder-Policy` where compatible.
- [ ] `X-Powered-By` removed and `Server` minimal. Don't use the deprecated `X-XSS-Protection` (set it to `0` or omit it), `Expect-CT` or `Public-Key-Pins`.
- [ ] Sensitive responses send `Cache-Control: no-store`.

## CORS
- [ ] Exact-origin allow-list per environment. Never `*` with credentials; never reflect the request's `Origin`.

## Network and hosting
- [ ] Only the web entry point is public. Databases, caches, queues and admin tools sit on private networks.
- [ ] Firewall or security groups deny by default.
- [ ] SSH and admin access by key or SSO with MFA; no shared accounts; no password SSH.
- [ ] A WAF or edge rate limiting for public apps where the host offers it. DDoS protection from the provider.
- [ ] Containers run as non-root, read-only filesystem where possible, no privileged mode, resource limits set.

## Cloud permissions
- [ ] IAM least privilege for every service and human. No root or owner credentials used day to day; MFA on all console accounts.
- [ ] Storage buckets private by default; public access blocked at the account level unless deliberately needed.
- [ ] Cloud metadata endpoints protected (IMDSv2 on AWS) against SSRF.
- [ ] Audit logging (CloudTrail or equivalent) on.

## Environments and deploys
- [ ] Separate dev, staging and production, with separate credentials and data.
- [ ] Production deploys happen from CI after checks pass, never by hand from a laptop. Deploys need the owner's go-ahead (SR-19).
- [ ] Rollback path tested.
- [ ] Infrastructure as code reviewed like application code and scanned.

## Verify
Run the deployed URL through a header check (securityheaders.com, Mozilla HTTP Observatory) and a TLS check (SSL Labs). Show the results. Try the database port from outside: it must be closed.
