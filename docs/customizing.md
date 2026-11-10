# Customizing

The kit is opinionated by default: strict verification, multiple-choice questions with a recommendation, premium UI with no AI slop, no hacks. Change any of it without touching the kit's own files.

## Where changes go

| You want to | Put it in |
|---|---|
| Describe your project (what, layout, commands, stack) | The **Project** section of `AGENTS.md`, below the `agentkit:end` marker |
| Change or add a rule for the whole workspace | `.agentkit.local/overrides.md` |
| Add rules for one folder or repo | A short nested `AGENTS.md` in that folder (most tools read the nearest one) |
| Change doctor limits | `.agentkit.local/budgets.env` |
| Record a project-specific standard that came from a decision | `docs/agent/DECISIONS.md`, then reference it from the project section |

**Never edit `.agentkit/`** or the text between the `agentkit` markers in `AGENTS.md`. Updates replace both.

## Overrides
`.agentkit.local/overrides.md` is read after the kit's rules and wins on conflict. Keep it short; agents read all of it whenever it has content.

```markdown
# Overrides
- Ask open questions instead of multiple choice.
- UI: this product uses Material 3. Its elevation shadows are allowed.
- Skip the browser check for internal admin screens; an API test is enough.
- Python: use pytest with the `integration` marker for database tests.
```

**Exception: security.** Overrides can make `.agentkit/security/RULEBOOK.md` stricter, never looser. To relax one security rule, the owner logs a waiver decision with its scope, end date and accepted risk. See [security.md](security.md).

## Budgets
Uncomment and change any line in `.agentkit.local/budgets.env`:

```sh
RING0_MAX_BYTES=8192      # AGENTS.md + STATUS.md + DECISIONS.md
AGENTS_MAX_LINES=120
STATUS_MAX_LINES=40
DECISIONS_MAX_LINES=80
LOG_MAX_BYTES=24576       # rotate LOG.md past this
```

The doctor reads only these keys with digit values; it never executes the file.

## Tone of the defaults
The kit ships its author's working style as the default because a strong default beats a blank page. Common softenings:
- Fewer questions: "For small tasks, decide and log the call as `agent (proposed)` instead of asking."
- Lighter UI bar for internal tools: "Internal admin screens: functional over polished; states and accessibility still required."
- Different commit style: "Commit messages follow <your convention>."

## Your own playbooks
Add a file such as `.agentkit.local/playbooks/release.md` and list it in `overrides.md` with a "read when" line, the same way `INDEX.md` does. It survives updates.
