# Updating

Run the installer again against the same workspace:

```sh
git -C AICodingAgentDevKit pull
sh AICodingAgentDevKit/install.sh /path/to/workspace --dry-run   # preview
sh AICodingAgentDevKit/install.sh /path/to/workspace
```

On Windows use `install.ps1 -Target <path>` (add `-DryRun` to preview). An agent can do the same by following `INSTALL.md`.

## What an update changes
| Path | On update |
|---|---|
| `.agentkit/` | Deleted and replaced with the new version. Files removed from the kit disappear. |
| `AGENTS.md`, between `<!-- agentkit:start -->` and `<!-- agentkit:end -->` | Replaced with the new kit block. Line endings are preserved. |

## What an update never touches
- Everything in `AGENTS.md` outside the markers (your project section).
- `CLAUDE.md`, `GEMINI.md` (recreated only if missing).
- `.agentkit.local/` (overrides, budgets, your own playbooks).
- `docs/agent/` (all project memory). Missing seed files are recreated; existing ones are kept.

## Safety guards
- If `.agentkit/` exists but has no `VERSION` file, it isn't a kit install. The installer stops with exit code 3 and changes nothing.
- If `AGENTS.md` has no markers, or a damaged set of them, it's left alone and reported as `adopt`.

## Versions
`.agentkit/VERSION` holds the installed version. The kit follows semantic versioning: a major version bump may need a manual step, which `CHANGELOG.md` describes. After updating, run the doctor.
