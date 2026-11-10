# Rule: writing

Docs, memory files, commit messages and product copy. Short, plain, human.

## Tone
- Plain words, short sentences, active voice. Write like a careful engineer, not a brochure.
- Lead with the point. Put the conclusion first, then the detail.
- No filler: "It's worth noting", "In order to", "Let's dive in", "As an AI".
- No hype: "seamless", "robust", "cutting-edge", "game-changer", "supercharge", "unlock", "elevate", "leverage".
- No emoji in docs, commits or product copy unless the project already uses them.

## Docs and memory files
- Write for the next reader who has no context: a new teammate or a different AI in a fresh chat.
- One topic per file. Headings that say what's under them.
- Prefer lists and tables over paragraphs for facts. Keep table cells to one line.
- Link to the file that owns a fact instead of copying it.
- Dates as `YYYY-MM-DD`. Name roles, not people.
- Mark guesses as guesses.
- Delete stale content instead of adding "update:" notes on top. History lives in LOG and git.

## Commit messages
- Conventional style: `type(scope): summary` with types `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `build`, `ci`.
- Summary in the imperative, ≤ 72 characters, says what changed ("fix: retry webhook on 429"), not "update files" or "save progress".
- Body when the why isn't obvious: what and why, not how. Reference the decision (`D-0012`) or task ID (`T-04`).
- One logical change per commit.

## Product copy
- Short labels, sentence case, verbs on buttons ("Save changes", not "Submit").
- Say what happened and what to do next. Error: "Couldn't save. Check your connection and try again."
- Same word for the same thing everywhere. Keep a glossary in the project section if terms matter.
- No exclamation marks in system messages. No jokes in errors.
- Numbers exact where they matter; never invent them.
- Write for the user's language and locale. If the product is multilingual, every string goes through the translation layer.

## Messages to the user (chat)
- Result first. Then what's left, what failed, what's unverified.
- Short. Link to files for detail instead of pasting them.
