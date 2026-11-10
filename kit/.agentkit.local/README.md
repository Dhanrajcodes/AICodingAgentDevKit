# .agentkit.local

Your folder. Kit updates never touch it.

- `overrides.md`: your own rules. Agents read it after the kit's rules, and it wins on conflict. Use it to soften, tighten or add to anything in `.agentkit/`, except the security rulebook, which it can only tighten.
- `budgets.env`: size limits for `.agentkit/doctor.sh` and `doctor.ps1`. Uncomment a line to change a limit.

Don't edit `.agentkit/` directly. Your changes there would be lost on the next update.
