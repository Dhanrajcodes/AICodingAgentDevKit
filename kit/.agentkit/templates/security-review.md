# Security review: <scope>

- Date: YYYY-MM-DD
- Reviewer: <fresh session, tool, or role>
- Scope: <release, branch, feature; entry points; data; third parties>
- Gate: PASS | BLOCKED (<reason>)

## Hard rules
| Rule | Result | Evidence |
|---|---|---|
| SR-01 | pass / fail / n/a (why) | |

## Checklists run
<!-- Which files in security/checklists/ and anything not applicable. -->

## Automated scans
| Check | Command | Result |
|---|---|---|
| Secrets | | |
| Dependencies | | |
| Static analysis | | |
| Containers / IaC | | |
| Running app | | |

Not run (and why):

## Manual tests
| Entry point | Test | Result |
|---|---|---|

## Findings
| ID | Severity | Location | Issue | Fix | Status |
|---|---|---|---|---|---|

Status: `open`, `fixed (commit, test)`, `waived (D-NNNN)`.

## Release gate
- [ ] Report from this release cycle
- [ ] No open Critical or High; Medium fixed or waived
- [ ] Secret, dependency and static scans ran
- [ ] Threat model current
- [ ] Headers, TLS, cookies and CORS verified on the deployed environment
- [ ] Backups restorable; incident response written down
