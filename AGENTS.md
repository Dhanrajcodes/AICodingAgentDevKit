# AGENTS.md: working on the kit itself

This repo is the source of the AI Coding Agent Dev Kit. These instructions are for agents changing the kit, not for projects that use it.

## Read first

1. `docs/agent/STATUS.md`: where things stand.
2. `docs/agent/DECISIONS.md`: settled choices. Don't reopen them unless the owner asks.
3. The active plan's `tracker.md` if STATUS names one.

## Layout

- `kit/`: the payload. It mirrors exactly what lands in a user's workspace. Edit here, never in an installed copy.
- `install.sh`, `install.ps1`: installers. They must behave identically.
- `kit/.agentkit/doctor.sh`, `doctor.ps1`: health check. Same checks, same labels.
- `tests/`: `bash tests/run.sh` and `powershell -NoProfile -ExecutionPolicy Bypass -File tests/run.ps1`.
- `docs/`: public documentation. `docs/architecture.md` is the design spec.
- `examples/sample-workspace/`: a filled-in example.

## Rules for changing the kit

- The kit follows its own rules. Read `kit/.agentkit/rules/` before changing them.
- Keep the token budget: kit block of `kit/AGENTS.md` ≤ 70 lines, fresh-install ring 0 ≤ 8 KB, every rule and playbook ≤ 150 lines. Run the tests; they check this.
- A change to install or doctor behaviour lands in both the `.sh` and `.ps1` versions, with tests, in the same commit.
- `.ps1` files stay ASCII. `.sh` files stay LF.
- Never break the ownership rules in `docs/architecture.md`: updates replace `.agentkit/` and the marked block only.
- Bump `kit/.agentkit/VERSION` and `CHANGELOG.md` for any user-visible change.
- Same memory discipline as the kit: update STATUS, append to LOG, log decisions.
