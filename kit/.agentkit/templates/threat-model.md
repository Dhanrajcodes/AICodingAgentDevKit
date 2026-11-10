# Threat model: <system or feature>

- Updated: YYYY-MM-DD
- Scope: <what this covers>

## Assets
<!-- What an attacker wants: accounts, personal data, money, admin access, compute, reputation. -->
| Asset | Class (personal, sensitive, secret...) | Where it lives |
|---|---|---|

## Actors
<!-- Anonymous visitor, signed-in user, other tenant, admin, internal service, third party, AI agent or tool. -->

## Entry points and trust boundaries
<!-- Routes, webhooks, jobs, uploads, AI tools, admin panels. Where untrusted data crosses into trusted code. -->
| Entry point | Who can reach it | Auth | Data in / out |
|---|---|---|---|

## Data flows
<!-- One line per flow: source → processing → storage → recipients. Include third parties and LLM providers. -->

## Threats (STRIDE)
| # | Threat | S/T/R/I/D/E | Affected asset | Control in place | Status |
|---|---|---|---|---|---|

Status: `mitigated (control)`, `accepted (D-NNNN)`, or `open → SEC-NNN`.

## Assumptions
<!-- What this model takes for granted (for example "the host's network isolation works"). -->
