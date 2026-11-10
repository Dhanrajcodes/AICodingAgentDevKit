# Playbook: adopt an existing project

Use when the kit is installed into a workspace that already has agent docs: a `CLAUDE.md` or `AGENTS.md` with content, `GEMINI.md`, `.cursor/rules`, `.cursorrules`, `.windsurfrules`, `.clinerules`, `.github/copilot-instructions.md`, `memory-bank/`, or files like `PROGRESS.md`, `STATUS.md`, `DECISIONS.md`, `HANDOFF.md`, `TODO.md`, `ROADMAP.md`, execution plans or ADRs.

Goal: one entry point, one memory layout, nothing lost, nothing moved without the user saying yes.

## 1. Inventory (read only)
List every harness or memory file with path, size, last modified and a one-line summary of what it holds. Don't read huge files whole: read the head and skim the structure.

## 2. Classify each file
| Kind | Goes to |
|---|---|
| Project facts (what, stack, commands, layout) | Project section of `AGENTS.md` |
| Rules that differ from the kit | `.agentkit.local/overrides.md` (or a nested `AGENTS.md` if folder-specific) |
| Rules the kit already covers | Nowhere. Note the overlap; drop after the user agrees |
| Current state | `docs/agent/STATUS.md` (rewritten, ≤ 40 lines) |
| History, progress logs, handoff notes | `docs/agent/LOG.md` or `docs/agent/log/<YYYY-MM>.md` |
| Decisions, ADRs | Index rows in `DECISIONS.md`; long ones as `decisions/D-NNNN-*.md` (keep original IDs in the text) |
| Plans, trackers, specs | `docs/agent/plans/<date-slug>/` (keep task IDs) |
| Research and reference | `docs/agent/research/` |
| Client or owner source docs | Leave where they are. Mark read-only in `AGENTS.md` |
| Stale or contradictory | Ask: archive or delete |

Flag contradictions (two design systems, two status files that disagree) for the user to settle.

## 3. Propose
Show the user one table: file → destination → action (move, merge, summarise, leave, archive). Ask as multiple choice: apply all (Recommended), apply with changes, or leave as is.

## 4. Apply (only after yes)
- Back up first: copy originals to `docs/agent/archive/adopt-<YYYY-MM-DD>/`. Never delete user content without explicit permission.
- If `AGENTS.md` has no kit markers: move it to the archive, copy `.agentkit/templates/AGENTS.md` to `AGENTS.md`, then merge the old project content into the project section below the markers.
- Replace `CLAUDE.md` and `GEMINI.md` with `.agentkit/templates/stub.md` once their content is merged.
- Tool-specific rule files (`.cursor/rules`, `.clinerules`) that only repeat `AGENTS.md`: remove after the user agrees. Keep scoped ones that add value.
- Oversized files: summarise into the new layout, keep the original in the archive.

## 5. Verify
Run doctor. Fix warnings. Confirm a fresh session would start correctly: ring 0 is small and STATUS says the true next step.

## 6. Record
Log a decision ("Adopted the dev kit; memory moved to docs/agent/") and a LOG entry listing what moved where.
