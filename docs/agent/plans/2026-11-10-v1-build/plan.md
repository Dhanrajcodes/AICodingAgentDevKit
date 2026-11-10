# Kit v1.0 build plan

> For agentic workers: execute task by task in ID order. Track status in `tracker.md` (same folder), one task `doing` at a time. Log each finished task in `docs/agent/LOG.md`.

**Goal:** Ship v1.0 of the AI Coding Agent Dev Kit: the installable payload, two installers, two doctor scripts, tests, CI and full public docs.

**Architecture:** see `docs/architecture.md` (the spec). The repo holds the payload in `kit/`, which mirrors exactly what lands in a workspace. Scripts at the repo root install it. Everything else is docs, examples and tests.

**Tech:** Markdown. POSIX `sh`/bash (Git Bash, macOS, Linux). Windows PowerShell 5.1+ (also pwsh 7). GitHub Actions.

**Spec:** `docs/architecture.md`

## Global constraints

- No runtime dependencies beyond a shell. No Node, Python or package managers.
- `.ps1` files are ASCII only (PowerShell 5.1 misreads BOM-less UTF-8). Markdown may use UTF-8.
- `.sh` files use LF line endings (enforced in `.gitattributes`).
- Ring-0 of a freshly installed workspace (AGENTS.md + STATUS.md + DECISIONS.md) ≤ 8192 bytes. Kit block of AGENTS.md ≤ 70 lines.
- Every rule and playbook file ≤ 150 lines. Each one starts with a one-line purpose.
- Doctor default budgets: `RING0_MAX_BYTES=8192`, `AGENTS_MAX_LINES=120`, `STATUS_MAX_LINES=40`, `DECISIONS_MAX_LINES=80`, `LOG_MAX_BYTES=24576`.
- Kit markers: `<!-- agentkit:start -->` and `<!-- agentkit:end -->`, each on its own line.
- License: custom personal-use license, "Copyright (c) 2026 Dhanraj Singh". Not MIT.
- No personal names other than the author's copyright line. No secrets.
- `install.sh` and `install.ps1` behave identically; `doctor.sh` and `doctor.ps1` produce the same checks with the same labels.

## Review focus

1. `.agentkit/` exists in the target but is not the kit's (no `VERSION`): installer must abort, never delete it.
2. Target path with spaces (`Whatsapp projects`): both installers and doctors must work.
3. Re-running install twice: second run changes nothing except `.agentkit/` and the marker block, and reports "kept" for user files.
4. Existing `AGENTS.md`/`CLAUDE.md` without kit markers: untouched, reported as `adopt`.
5. CRLF memory files (Windows editors): doctor line and date checks still work.

---

## File map

```
LICENSE  README.md  CHANGELOG.md  INSTALL.md  install.sh  install.ps1
.gitignore  .gitattributes  .github/workflows/ci.yml
AGENTS.md  CLAUDE.md                      (instructions for working ON the kit)
kit/
  AGENTS.md  CLAUDE.md  GEMINI.md
  .agentkit/  VERSION  INDEX.md  doctor.sh  doctor.ps1
    rules/       working  context-economy  truthfulness  research  engineering
                 frontend-ui  backend  security-privacy  writing
    playbooks/   session-start  handoff  plan-and-track  log-decision  research
                 definition-of-done  edge-cases  bugfix  review  adopt  compact
    templates/   status  log-entry  decisions-index  decision  open-questions
                 spec  plan  tracker  research-note  bugfix
  .agentkit.local/  README.md  overrides.md  budgets.env
  docs/agent/   STATUS.md  LOG.md  DECISIONS.md  OPEN-QUESTIONS.md
                decisions/.gitkeep  plans/.gitkeep  research/.gitkeep  log/.gitkeep
docs/  architecture.md  getting-started.md  customizing.md  updating.md
       adopting.md  token-budget.md  tool-support.md  faq.md
examples/sample-workspace/   a filled-in workspace after a few sessions
tests/  lib.sh  test_install.sh  test_doctor.sh  run.sh  run.ps1
```

## Tasks

### T-01 Repo foundation
Files: `LICENSE`, `.gitignore`, `.gitattributes`, `CHANGELOG.md`, root `AGENTS.md`, root `CLAUDE.md`, `docs/agent/*` for the kit's own memory.
- `.gitattributes`: `* text=auto eol=lf`, `*.ps1 text eol=crlf`.
- LICENSE grants: use, copy and modify for own projects (personal or commercial work products); must keep the copyright and license notice in `.agentkit/` copies; must not sell, sublicense or republish the kit (modified or not) as a standalone product or claim authorship. No warranty.
- Verify: `git status` shows the files; `cat .gitattributes`.

### T-02 Entry points and index
Files: `kit/AGENTS.md`, `kit/CLAUDE.md`, `kit/GEMINI.md`, `kit/.agentkit/VERSION` (`1.0.0`), `kit/.agentkit/INDEX.md`.
- `kit/AGENTS.md`: kit block (markers) covering ring-0 reading order, truth order, tiers, memory rules, the handoff trigger, and a pointer to INDEX.md; then a project block with fill-in headings (What this is, Repos and layout, Commands, Stack, Project rules).
- INDEX.md: llms.txt style. One line per rule/playbook/template: path, "read when".
- Verify: kit block line count ≤ 70 (`sed -n '/agentkit:start/,/agentkit:end/p' kit/AGENTS.md | wc -l`).

### T-03 Rules (9 files)
Content per `docs/architecture.md` Quality model, drawn from the author's proven project harnesses: ask-as-multiple-choice with a recommendation, files are memory, never invent facts, no weakened tests or silenced errors, evidence for done, scope fences, premium UI with no AI slop (banned-pattern list), all UI states, WCAG AA, 320 px mobile, backend validation, idempotency, UTC, pagination, response envelope, privacy and secrets.
- Verify: `wc -l kit/.agentkit/rules/*.md` all ≤ 150.

### T-04 Playbooks (11 files)
- `plan-and-track.md` owns the tier table and tracker protocol (one `doing`, priority order, blocked with reason, append-only IDs, superseded notes, completion note format: Changed | Files | Evidence | Side effects).
- `handoff.md` owns the STATUS rewrite shape and the fresh-chat test.
- `adopt.md`: inventory existing harness files, propose a mapping table, ask, then move/compact with backups; never delete user content.
- `compact.md`: rotate LOG months to `log/`, move replaced decisions out of the index, trim STATUS; run doctor after.
- Verify: line counts ≤ 150; every playbook referenced in INDEX.md exists (`grep -o 'playbooks/[a-z-]*\.md' kit/.agentkit/INDEX.md | sort -u` vs `ls`).

### T-05 Templates and seeds
Files: `kit/.agentkit/templates/*`, `kit/.agentkit.local/*`, `kit/docs/agent/*`.
- STATUS seed has `Last updated: YYYY-MM-DD` line format the doctor parses: `^Last updated: [0-9]{4}-[0-9]{2}-[0-9]{2}`.
- LOG entries use headings `## YYYY-MM-DD: title`; doctor parses `^## [0-9]{4}-[0-9]{2}-[0-9]{2}`.
- Tracker status words: `todo`, `doing`, `done`, `blocked`, `dropped`. Doctor counts rows matching `\| *doing *\|`.
- `budgets.env` lists the five defaults, commented out.
- Verify: ring-0 of seeds: `cat kit/AGENTS.md kit/docs/agent/STATUS.md kit/docs/agent/DECISIONS.md | wc -c` ≤ 8192.

### T-06 install.sh + tests
Interface: `install.sh [--dry-run] TARGET`. Payload dir = `$(dirname "$0")/kit`.
Behaviour:
1. TARGET missing or not a directory → exit 2 with usage.
2. `TARGET/.agentkit` exists without `VERSION` → exit 3, message, no changes.
3. Replace `TARGET/.agentkit` with payload copy → print `updated .agentkit/ (vX)` or `created .agentkit/ (vX)`.
4. `AGENTS.md`: missing → copy template (`created`); has both markers → replace block with payload block (`updated kit block in AGENTS.md`); else `adopt AGENTS.md (no kit markers; see .agentkit/playbooks/adopt.md)`.
5. `CLAUDE.md`, `GEMINI.md`: missing → create; contains `@AGENTS.md` → `kept`; else `adopt`.
6. Every file under payload `.agentkit.local/` and `docs/agent/`: create if missing, else `kept`.
7. `--dry-run`: same lines prefixed `would:`; filesystem unchanged.
Tests (`tests/test_install.sh`, sourcing `tests/lib.sh` with `assert_eq`, `assert_contains`, `assert_file`, `mktarget`): fresh install; re-run idempotent (user edit in STATUS.md and project block of AGENTS.md survive); marker block updated when payload changes; foreign `.agentkit` aborts with exit 3; existing unmarked AGENTS.md untouched + `adopt`; dry-run leaves dir empty; path with spaces.
- Verify: `bash tests/run.sh` → all pass.

### T-07 install.ps1 + tests
Interface: `install.ps1 [-DryRun] -Target <path>`. Same behaviour, same output lines, same exit codes. Tests in `tests/run.ps1` mirror T-06 cases.
- Verify: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/run.ps1` → all pass.

### T-08 doctor.sh + tests
Interface: `.agentkit/doctor.sh [TARGET]` (default `.`). Loads defaults, then `TARGET/.agentkit.local/budgets.env` (`KEY=VALUE`, `#` comments). Prints `ok   <check>` or `warn <check>: <detail>`, then `doctor: N warning(s)`. Exit 1 if N > 0 else 0.
Checks (labels fixed): `kit-installed`, `kit-markers`, `stub CLAUDE.md`, `stub GEMINI.md`, `ring0-size`, `agents-lines`, `status-lines`, `decisions-lines`, `log-size`, `status-fresh`, `tracker-single-doing`, `no-secrets`.
- `status-fresh`: warn when newest LOG heading date > STATUS `Last updated` date.
- `no-secrets` patterns over `docs/agent` and `.agentkit.local`: `sk-[A-Za-z0-9_-]{20,}`, `AKIA[0-9A-Z]{16}`, `ghp_[A-Za-z0-9]{36}`, `AIza[0-9A-Za-z_-]{35}`, `xox[baprs]-[A-Za-z0-9-]{10,}`, `-----BEGIN [A-Z ]*PRIVATE KEY-----`. Report file names only, never the match.
- Strip `\r` before line and date checks.
Tests: fresh install → exit 0; each check made to warn by a fixture; budgets.env override lowers a limit and triggers a warn; CRLF STATUS still parses.

### T-09 doctor.ps1 + tests
Same checks, labels, output and exit codes as T-08. Tests in `tests/run.ps1`.

### T-10 INSTALL.md (agent-run install)
Step list any agent can follow to do exactly what the scripts do, including update and adopt branches, ending with "run doctor if a shell is available, then fill the project block of AGENTS.md with the user".

### T-11 CI
`.github/workflows/ci.yml`: on push/PR; jobs `ubuntu-latest` (bash tests, shellcheck on `*.sh`) and `windows-latest` (PowerShell tests under both `powershell` and `pwsh`). Also a `budget` step: install into a temp dir and run doctor (must exit 0).

### T-12 Public docs
`README.md` (what, why, 60-second quick start, how it works diagram, token budget, tool table, docs links, license summary, author), plus `docs/getting-started.md`, `customizing.md`, `updating.md`, `adopting.md`, `token-budget.md`, `tool-support.md`, `faq.md`. Written for developers evaluating or adopting the kit.

### T-13 Example workspace
`examples/sample-workspace/`: the installed kit's memory filled in as if after three sessions on a small SaaS (STATUS, LOG, 3 decisions, one feature plan with tracker mid-flight, one research note). No `.agentkit/` copy (point to `kit/`). Doctor on it (with `.agentkit` installed to a temp copy) exits 0.

### T-14 Final verification and release
- Run both test suites; run installer into a scratch copy of a real multi-repo workspace layout; run doctor; record ring-0 bytes in LOG.
- Whole-repo review (fresh reviewer).
- Update CHANGELOG `1.0.0`, tag `v1.0.0`, push `main` and tag.

### T-15 Security rulebook (added 2026-11-10, owner request, D-0014)
Files: `kit/.agentkit/security/RULEBOOK.md` (non-negotiable rules + production gate), `kit/.agentkit/security/checklists/*.md` (auth-sessions, api-input, data-crypto, secrets-config, supply-chain, infra-deploy, frontend-client, files-uploads, ai-llm, logging-incident), `kit/.agentkit/playbooks/security-review.md`, `templates/threat-model.md`, `templates/security-review.md`; `rules/security-privacy.md` points to the rulebook; AGENTS.md kit block names the rulebook; INDEX entries; doctor check `env-ignored` (both shells, tests).
- Standards cited with versions verified by research on 2026-11-10 (OWASP Top 10, ASVS, API Top 10, LLM Top 10, CWE Top 25, NIST SSDF, SLSA).
- Overrides cannot relax a rulebook rule; only an owner waiver logged as a decision with the accepted risk.
- Verify: kit tests (line budgets, INDEX links) and doctor tests pass in both shells.
