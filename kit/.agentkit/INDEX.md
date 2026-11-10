# Kit index

Open only what the task needs. One line per file: what it is and when to read it.

## Rules (standards)
- `rules/working.md`: memory, scope, asking vs assuming, tiers. Read when unsure how to proceed or before a feature-tier task.
- `rules/context-economy.md`: how to spend tokens and context. Read at the start of any long or wide task.
- `rules/truthfulness.md`: claim labels, sources, evidence, checking APIs and packages exist. Read before stating facts, adding a dependency or reporting results.
- `rules/research.md`: how to research and record findings. Read before any research or comparison.
- `rules/engineering.md`: honest code, tests, dependencies, shape of changes. Read before writing or changing code.
- `rules/frontend-ui.md`: UI quality, states, accessibility, responsive, banned AI-slop patterns. Read before any UI, styling or user-facing copy work.
- `rules/backend.md`: validation, errors, data, jobs, time, API shape. Read before any API, database, job or integration work.
- `rules/security-privacy.md`: everyday security rules and pointers into the rulebook. Read before touching auth, user data, logs, config, dependencies or anything committed.
- `rules/writing.md`: docs, commits, messages, UI copy. Read before writing docs, commit messages or copy.

## Playbooks (procedures)
- `playbooks/session-start.md`: starting or resuming work, in any tool.
- `playbooks/handoff.md`: finishing a task, pausing, or when the chat grows long.
- `playbooks/plan-and-track.md`: choosing a tier; writing a spec, plan and tracker; working a tracker.
- `playbooks/log-decision.md`: any choice someone could later ask "why?" about.
- `playbooks/research.md`: researching a library, API, approach or competitor.
- `playbooks/definition-of-done.md`: before saying anything is done.
- `playbooks/edge-cases.md`: designing or building a feature, flow, job or form.
- `playbooks/bugfix.md`: fixing a bug or a failing test.
- `playbooks/review.md`: reviewing a change, yours or another agent's.
- `playbooks/adopt.md`: installing into a project that already has agent docs.
- `playbooks/compact.md`: memory files over budget, or doctor warns.
- `playbooks/security-review.md`: before any production release, after an incident, or when a feature touches auth, data, payments, uploads or AI tools.

## Security (non-negotiable)
- `security/RULEBOOK.md`: hard rules SR-01 to SR-20, waivers, the production release gate. Read before any production-bound work on a security surface.
- `security/checklists/auth-sessions.md`: sign-in, passwords, sessions, tokens, OAuth, MFA.
- `security/checklists/access-control.md`: roles, permissions, multi-tenancy, admin.
- `security/checklists/api-input.md`: endpoints, forms, webhooks, parsers, CORS, CSRF.
- `security/checklists/data-crypto.md`: databases, encryption, backups, retention.
- `security/checklists/secrets-config.md`: env vars, keys, config, CI secrets.
- `security/checklists/supply-chain.md`: adding or updating dependencies, CI/CD, containers.
- `security/checklists/infra-deploy.md`: hosting, TLS, headers, network, cloud IAM.
- `security/checklists/frontend-client.md`: XSS, CSP, client storage, third-party scripts.
- `security/checklists/files-uploads.md`: uploads, downloads, file parsing, SSRF.
- `security/checklists/ai-llm-agents.md`: LLM features, RAG, agents, tool calling, MCP, voice: prompt injection and friends.
- `security/checklists/ai-dev-workflow.md`: securing the coding agent itself: untrusted repo instructions, hidden Unicode, MCP and plugin trust, permissions.
- `security/checklists/logging-incident.md`: security logging, alerting, incident response.
- `security/checklists/privacy-compliance.md`: personal, health and financial data; GDPR, DPDP, HIPAA.

## Templates (shapes for memory files)
- `templates/status.md`, `templates/log.md`, `templates/log-entry.md`, `templates/decisions-index.md`, `templates/decision.md`, `templates/open-questions.md`
- `templates/spec.md`, `templates/plan.md`, `templates/tracker.md`, `templates/bugfix.md`, `templates/research-note.md`
- `templates/threat-model.md`, `templates/security-review.md`: used by `playbooks/security-review.md`
- `templates/AGENTS.md`, `templates/stub.md`: the entry file and tool stubs the installer writes (used by `playbooks/adopt.md`)

## Tools
- `doctor.sh` / `doctor.ps1`: checks memory sizes, stale status, stubs, secrets in memory files and unignored `.env` files. Run `sh .agentkit/doctor.sh` or `powershell -ExecutionPolicy Bypass -File .agentkit/doctor.ps1`.
- `VERSION`: installed kit version.
