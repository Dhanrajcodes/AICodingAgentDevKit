# Security

Most code in a kit-managed project is written by AI agents. Agents are fast, helpful and easy to steer, including by an attacker. So the kit treats security as a rulebook that can't be negotiated away in a chat, not as a set of suggestions.

## What's in the kit

| File | Purpose |
|---|---|
| `.agentkit/security/RULEBOOK.md` | 20 hard rules (SR-01 to SR-20), the waiver process, "stop and ask" triggers and the production release gate |
| `.agentkit/security/checklists/` | 13 area checklists, each with a "verify" section of concrete tests to run |
| `.agentkit/playbooks/security-review.md` | Review procedure: scope, threat model, rules, checklists, scans, manual tests, findings, gate |
| `.agentkit/templates/threat-model.md` | STRIDE threat model |
| `.agentkit/templates/security-review.md` | Review report with findings and gate result |
| `.agentkit/rules/security-privacy.md` | The everyday subset, short enough to read on any task |

## Authority and waivers
- The rulebook wins over everything except an explicit owner waiver.
- `.agentkit.local/overrides.md` can make security rules **stricter**, never looser.
- A waiver covers one rule, one scope and one end date, with the accepted risk written down. It is logged in `docs/agent/DECISIONS.md`. Agents can't grant, assume or extend waivers, and "just make it work" isn't one.
- If a task can't be done without breaking a rule, the agent stops and asks.

## Coverage

**Classic application security**
- Authentication and sessions: argon2id parameters from the OWASP Password Storage cheat sheet, cookie flags, timeouts, JWT pitfalls, OAuth with PKCE, passkeys.
- Access control: object-, property- and function-level checks, multi-tenancy isolation, admin actions.
- APIs and input: schema validation, injection, resource limits, webhooks, CSRF, CORS.
- Data and cryptography: classification, encryption, keys, backups, retention.
- Secrets and configuration, including build-time prefixes that leak variables into browser bundles.
- Infrastructure: TLS, a strict CSP, the current header baseline, network isolation, cloud IAM.
- Frontend: XSS, Trusted Types, client storage, third-party scripts.
- Files and uploads, including SSRF.
- Logging, alerting and incident response.
- Privacy and compliance: GDPR, India's DPDP Act and Rules, HIPAA and payments.

**Modern and AI-specific risks**
- **Prompt injection, direct and indirect:** instructions hidden in documents, web pages, tool results, images or speech.
- **Excessive agency:** least-privilege tools, human confirmation for destructive actions, sandboxed execution, spend and step limits.
- **Model output as untrusted input,** with no data exfiltration through rendered markdown images.
- **RAG:** permission-aware retrieval and tenant-scoped vector stores, plus defences against memory poisoning.
- **MCP and plugins:** tool poisoning, token passthrough and audience checks, local server consent.
- **Hallucinated packages ("slopsquatting"):** every dependency is verified before install.
- **Supply chain:** dependency confusion, fresh-release malware, OIDC credentials in CI, SBOMs, SLSA provenance.
- **Securing the coding agent itself:** untrusted instructions in repos, hidden-Unicode "rules file backdoor" attacks, auto-approve modes, production credentials kept out of agent environments.
- **Voice and multimodal agents:** caller ID isn't authentication, voice-cloning risk, and transcripts handled as sensitive data.

## Standards baseline
Checked 2026-11-10:
- OWASP Top 10:2025
- OWASP ASVS 5.0 (Level 2 by default, Level 3 for health, finance and high-value data)
- OWASP API Security Top 10 2023
- OWASP Top 10 for LLM Applications 2025
- OWASP Top 10 for Agentic Applications 2026
- CWE Top 25 (2025)
- NIST SSDF SP 800-218 v1.1
- SLSA v1.2
- The OWASP Cheat Sheet Series
- MCP Security Best Practices
- NIST SP 800-52 Rev. 2 and Mozilla's TLS guidelines

The rulebook says to recheck these versions when the list is over a year old.

## Release gate
A production release is blocked until:
1. a security review from this release cycle exists;
2. no Critical or High findings are open, and Medium ones are fixed or waived;
3. secret, dependency and static scans ran;
4. the threat model covers new data flows;
5. headers, TLS, cookies and CORS are verified on the deployed environment;
6. backups restore, and incident response is written down.

## Doctor checks that support it
- `no-secrets`: common key formats in memory and local files. Reports the file name, never the match.
- `env-ignored`: `.env` files inside a git repo that aren't git-ignored.
- `no-hidden-unicode`: tag characters, zero-width characters and bidirectional controls in `AGENTS.md`, the stubs, `.agentkit.local/` and `docs/agent/`.

## Limits
The kit makes agents follow a security process and gives them the right checklists. It is not a scanner, a penetration test or legal advice. For high-risk products, add a human security review and qualified legal advice on compliance.
