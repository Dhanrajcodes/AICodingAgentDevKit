# Log

Append-only. Newest at the bottom. Entry: `## YYYY-MM-DD: title`, then what was done, files, how it was verified.

## 2026-11-10: research and design
- Audited the owner's workspaces (D:\Wproject, D:\project) for existing agent harnesses, trackers and recurring instructions.
- Researched AGENTS.md support, Spec Kit, BMAD, Agent OS, superpowers, Memory Bank, Task Master, Kiro, ADR formats and instruction-file size guidance.
- Q&A with the owner: D-0001 to D-0010.
- Wrote `docs/architecture.md` (spec) and the v1 plan and tracker.

## 2026-11-10: T-01 to T-04
- Changed: repo foundation, AGENTS.md kit block and stubs, INDEX, 9 rules, 11 playbooks.
- Ruling: the AGENTS.md template and tool stub live in `kit/.agentkit/templates/` (not at `kit/` root), so every install carries them for adopt and agent-run installs. One source, no copy drift. Cost if wrong: the installer reads one extra path.
- Evidence: kit block 43 lines, 4022 bytes; all rules and playbooks under 70 lines (`wc -l`).

## 2026-11-10: T-05 templates and seeds
- Changed: 13 templates; `.agentkit.local/` seeds (README, overrides, budgets.env).
- Ruling: no `kit/docs/agent/` payload. The installer seeds `docs/agent/` from `.agentkit/templates/` (status, log, decisions-index, open-questions) so each memory shape exists once. Cost if wrong: a mapping table in both installers.
- Evidence: fresh ring 0 (templates AGENTS + status + decisions-index) = 4889 bytes (`wc -c`).

## 2026-11-10: T-06 install.sh
- Changed: POSIX `install.sh`; `tests/lib.sh`, `tests/test_install.sh`, `tests/test_kit.sh`, `tests/run.sh`.
- Evidence: `bash tests/run.sh` → kit 99/99, install.sh 52/52 (failed 42/53 before the script existed).
- Ruling: added `test_kit.sh` (budgets, INDEX links, cross-refs, LICENSE copy) beyond the plan, so CI enforces the token budget. Cost if wrong: none.

## 2026-11-10: T-07 install.ps1
- Changed: `install.ps1`, `tests/lib.ps1`, `tests/test_install.ps1`, `tests/run.ps1`.
- Evidence: `powershell -File tests/run.ps1` → install.ps1 52/52 under Windows PowerShell 5.1 (failed before the script existed). Parity: fresh-install output and resulting tree identical to install.sh (`diff`, `diff -r`). `.ps1` files 0 non-ASCII bytes. pwsh 7 not installed locally; CI covers it (T-11).

## 2026-11-10: T-08 doctor.sh
- Changed: `kit/.agentkit/doctor.sh`, `tests/test_doctor.sh`.
- Evidence: `bash tests/run.sh` → kit 99/99, install 52/52, doctor 35/35 (doctor 1/35 before the script existed). Covers each check warning, budgets override, CRLF STATUS, paths with spaces, and secrets reported by file name only.
- Ruling: check labels have no spaces (`stub-claude`, `stub-gemini` instead of `stub CLAUDE.md`) so output is easy to grep. Cost if wrong: label rename.
- Ruling: default workspace is the folder holding `.agentkit/` (script's parent), not the cwd, so doctor works from any directory. Cost if wrong: none; an explicit path still wins.
- Ruling: budgets.env is parsed (known keys, digits only), never sourced, so a user file can't run code.

## 2026-11-10: T-09 doctor.ps1
- Changed: `kit/.agentkit/doctor.ps1`, `tests/test_doctor.ps1`; fix in `install.ps1`; new `update-recreates-stub` case in both install suites.
- Evidence: `tests/run.ps1` → install.ps1 55/55, doctor.ps1 35/35 (34/35 failed with the script hidden). `tests/run.sh` → kit 99/99, install.sh 55/55, doctor.sh 35/35.
- Bug found and fixed: PowerShell variables are case-insensitive. `$m` overwrote `$M` in doctor.ps1, and `$tpl` overwrote `$Tpl` in install.ps1, which crashed an update that had to recreate a missing stub. Regression test failed first, then passed. Scanned all `.ps1` files for other case collisions: none.
