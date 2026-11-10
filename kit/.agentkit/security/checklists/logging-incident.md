# Checklist: logging, monitoring and incident response

Rules: SR-16, SR-17. Sources: OWASP Top 10:2025 A09 (Security Logging and Alerting Failures) and A10 (Mishandling of Exceptional Conditions); OWASP Logging cheat sheet.

## What to log
- [ ] Security events: sign-in success and failure, MFA changes, password resets, permission denials, role changes, admin actions, data exports, API key creation, rate-limit hits, webhook signature failures.
- [ ] Each event has: timestamp (UTC), actor (user ID or service), action, target, outcome, request ID, source IP.
- [ ] Logs are structured (JSON) and centralised, not only on one server's disk.

## What never to log
- [ ] Passwords, tokens, session IDs, API keys, full card numbers, secrets.
- [ ] Health data, government IDs or other sensitive personal data. Mask or hash identifiers where they're needed for correlation.
- [ ] Full request or response bodies by default.
- [ ] User input written to logs is encoded so it can't forge log lines (log injection).

## Integrity and retention
- [ ] Logs are append-only for the app; only a few people can read them, and fewer can delete them.
- [ ] Retention set to what compliance needs and no longer.
- [ ] Clocks synced (NTP) so events line up.

## Errors and exceptional conditions
- [ ] Unexpected errors fail closed: deny access, roll back transactions, never continue in a half-checked state.
- [ ] Every caught error is either handled, rethrown, or recorded where a human will see it. No empty catch blocks.
- [ ] Errors shown to users are generic, with a reference ID that maps to the detailed log.

## Monitoring and alerting
- [ ] Alerts for: bursts of failed sign-ins, many permission denials from one account, unusual export volume, new admin accounts, errors spiking, spend spiking on paid APIs.
- [ ] Alerts go to someone who will act on them, through a channel they watch.
- [ ] Uptime and certificate-expiry monitoring.

## Incident response (write it before you need it)
- [ ] `docs/agent/security/incident-response.md` lists: who to contact, how to revoke and rotate keys, how to disable a feature or put the app in maintenance mode, how to preserve logs, and who notifies users and regulators.
- [ ] Breach notice deadlines known for the laws that apply (see `privacy-compliance.md`). For example GDPR: the supervisory authority within 72 hours.
- [ ] After an incident: a short written post-mortem (timeline, cause, fix, prevention) and new tests or checks so it can't recur silently.

## Verify
Trigger a failed sign-in, a permission denial and an admin action, then find each in the logs. Search the logs for a test password and a test token: they must not appear.
