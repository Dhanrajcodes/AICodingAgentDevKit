# FAQ

**Do I need Node, Python or anything else?**
No. The kit is markdown. The installers need `sh` (macOS, Linux, Git Bash) or PowerShell 5.1+, and you can skip them entirely by asking an agent to follow `INSTALL.md`.

**Does it slow agents down or cost more tokens?**
It costs about 5.5 KB at session start and saves far more by ending re-explanation, re-reading of whole folders and repeated mistakes. Everything else loads only when a task needs it. See [token-budget.md](token-budget.md).

**Can I use it on an existing project?**
Yes. Existing files are never overwritten; the adopt playbook migrates them with your approval. See [adopting.md](adopting.md).

**Multiple repos in one product?**
Install at the folder that wraps them, so there's one memory for the product. Repo-specific commands go in a nested `AGENTS.md` in each repo.

**Should I commit `docs/agent/`?**
Usually yes: it's how a teammate, or a different AI tool on another machine, picks up the work. Review it in diffs like code. Never put secrets or personal data in it; the doctor checks for common key formats.

**The rules are too strict for my project.**
Soften them in `.agentkit.local/overrides.md`, except security rules, which can only be tightened. See [customizing.md](customizing.md).

**Why can't overrides relax security rules?**
Because the most common way an AI agent ships a vulnerability is being asked, reasonably, to "just make it work". A waiver is still possible, but it has to be a deliberate owner decision with a scope, an end date and the accepted risk written down. See [security.md](security.md).

**Will updating lose my changes?**
No. Updates replace `.agentkit/` and the marked block in `AGENTS.md` only. See [updating.md](updating.md).

**What if two agents work at once?**
The working rules say one agent edits a given area at a time, and the tracker allows one `doing` task per plan. The doctor warns if a tracker has more than one.

**Is the doctor required?**
No. It's an optional check you can run by hand, from a git hook, or in CI.

**Can I share the kit or fork it publicly?**
You can use and modify it in your own projects and share repos that contain an installed copy, keeping the notice. You can't resell or republish the kit itself as your own product. See [LICENSE](../LICENSE).
