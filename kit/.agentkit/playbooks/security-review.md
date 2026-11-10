# Playbook: security review

Use before any production release (required by SR-20), when a feature touches auth, access, personal data, payments, uploads, AI tools or a new public endpoint, after a security incident, and when adopting a project that has never had one. Authority: `.agentkit/security/RULEBOOK.md`.

A fresh session or a different agent reviews better than the author. For release reviews, use one if you can.

## 1. Scope
Write down what is in scope: the release, branch or feature; its entry points (routes, webhooks, jobs, UI); data it touches; third parties it calls. Save the report as `docs/agent/security/YYYY-MM-DD-<scope>-review.md` using `templates/security-review.md`.

## 2. Threat model
Update `docs/agent/security/threat-model.md` (`templates/threat-model.md`) for every new data flow or trust boundary. For each, ask STRIDE: who could Spoof identity, Tamper with data, Repudiate actions, Disclose information, Deny service, or Elevate privilege? List assets, entry points, threats and the control for each. Untreated threats become findings.

## 3. Hard rules
Walk SR-01 to SR-20 in the rulebook against the change. Each is pass, fail (finding) or not applicable with a reason.

## 4. Checklists
Run every checklist in `security/checklists/` the scope touches. Tick with evidence (`file:line`, command output), not from memory.

## 5. Automated scans
Run what fits the stack and record each command and its result:
| Check | Tools (pick what fits) |
|---|---|
| Secrets in code and history | gitleaks, TruffleHog |
| Dependencies | `npm audit` / `pnpm audit`, `pip-audit`, `osv-scanner`, `govulncheck`, `cargo audit` |
| Static analysis | CodeQL, Semgrep or Opengrep, the language's security linter (Bandit, eslint-plugin-security, gosec) |
| Containers and IaC | Trivy, Checkov |
| Running app (staging) | ZAP baseline scan; header check (Mozilla HTTP Observatory); TLS check (SSL Labs) |

If a tool isn't installed, say so and either install it (with the owner's agreement) or record the gap. Never report a scan you didn't run.

## 6. Manual tests
For each entry point in scope, actually try: another user's object IDs, a lower role, no session, extra fields, injection strings, oversized input, duplicate requests, and (for AI features) prompt injection. Record what happened.

## 7. Findings
For each: ID (`SEC-NNN`), severity, `file:line` or URL, what's wrong, how it would be exploited, the fix, and the rule or checklist item it breaks.
- **Critical:** exploitable now for data breach, account takeover, remote code execution or payment fraud.
- **High:** serious and plausible: broken access control, injection, auth bypass under conditions, secrets exposed.
- **Medium:** needs other weaknesses to exploit, or limited impact: missing headers, weak rate limits, verbose errors.
- **Low:** hardening and hygiene.

No findings is a valid result. Don't invent findings to look thorough, and don't downgrade to pass a gate.

## 8. Fix and re-check
Fix Critical and High before release. Each fix gets a test that reproduces the issue and fails first. Re-run the scans. Medium: fix, or the owner waives it as a logged decision with the accepted risk.

## 9. Gate
Check the release gate in the rulebook. Record pass or blocked in the report with the reason. Only the owner can ship with a blocked gate, through a logged waiver.

## 10. Record
LOG entry with the report path and gate result. New decisions logged. Recurring issues become a project rule in the project section of `AGENTS.md` or in `.agentkit.local/overrides.md` (which may tighten rules, never loosen them).
