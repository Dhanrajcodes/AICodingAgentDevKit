# Checklist: data and cryptography

Databases, storage, encryption, backups and retention. Rules: SR-02, SR-03. Sources: OWASP Top 10:2025 A04 (Cryptographic Failures); OWASP ASVS 5.0; OWASP Cryptographic Storage cheat sheet; NIST SP 800-52 Rev. 2 for TLS.

## Classify first
- [ ] Every stored field has a class: public, internal, personal, sensitive (health, financial, biometric, government ID, children's) or secret.
- [ ] A data map (what, where, who can read it, how long it's kept) lives in `docs/agent/security/` and changes with the schema.

## Encryption
- [ ] TLS 1.2 minimum (1.3 preferred) everywhere, including internal calls and database connections. Certificate checks never disabled.
- [ ] Encryption at rest for databases, backups and object storage (provider-managed keys at minimum).
- [ ] Field-level encryption for the most sensitive fields (health records, government IDs, bank details), with keys in a KMS, not app config.
- [ ] Standard algorithms through a maintained library: AES-GCM or ChaCha20-Poly1305; SHA-256 or better; Ed25519 or ECDSA P-256. Never ECB, MD5 or SHA-1 for security, never a homemade scheme.
- [ ] Tokens and IDs from a CSPRNG (`crypto.randomBytes`, Python `secrets`, Go `crypto/rand`), never `Math.random` or `random`.
- [ ] Keys can rotate without downtime, and the procedure is written down.

## Database
- [ ] The app's database user has only what it needs: no superuser, no schema changes at runtime.
- [ ] The database isn't reachable from the public internet. Admin access goes through a bastion, VPN or provider console with MFA.
- [ ] Tenant isolation enforced by row-level security or a repository layer.
- [ ] Destructive migrations reviewed for data loss and approved by the owner (SR-19).

## Backups and retention
- [ ] Automated, encrypted backups stored separately from production, with a defined retention.
- [ ] A restore was tested, and how long it took is recorded.
- [ ] Retention limits enforced: data deleted or anonymised once it's no longer needed.
- [ ] Deletion requests reach every store, or the exceptions are documented.

## Exposure
- [ ] Sensitive data never in URLs, logs, analytics, error trackers or client-side storage.
- [ ] Exports and bulk downloads require authorisation and are logged.
- [ ] Non-production environments use fake or properly anonymised data, never a raw copy of production.

## Verify
List each sensitive field and show where it's encrypted, who can read it and how it's deleted. Restore a backup into a scratch environment.
