# Local overrides

## File map

| Name | Path | Notes |
| ---- | ---- | ----- |
| User copilot instructions | `~/.copilot/copilot-instructions.md` | This file; loaded from `$HOME/.copilot/` |
| User agent instructions | `~/.agents/AGENTS.md` | Universal rules; intended always-on via `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` but see note below |
| User skills | `~/.agents/skills/<name>/SKILL.md` | Invokable by name in any project |
| Admit codebase | `/Users/paul.hendrick/local/admit/main` | Separate app sharing Hub's DB; Hub migrations are local/test only — Admit's Phinx migrations govern production schema |
| Obsidian vault | `~/Library/CloudStorage/OneDrive-VenturEdSolutions/Notes` | Git repo (`local/dev`), synced via OneDrive; `.obsidian/` is the live config |

> **Note:** `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` does not reliably inject `~/.agents/AGENTS.md` as
> universal instructions (known CLI bug). The rules below are inlined here as a workaround and
> must be kept in sync with `~/.agents/AGENTS.md`.

## Universal agent rules

These rules apply to every task in every project:

- Before making any code changes, invoke the `git` skill. Commit at logical checkpoints while
  working — each verified state is a commit point. **Never present completed work with
  uncommitted changes.**
- Always load the `judgement` skill.
- Invoke the project-level `testing` skill whenever you write, modify, or adapt tests of any kind.
- Before citing something as an established pattern or convention, verify it exists in a stable
  canonical branch. A pattern on the current feature branch is not an established convention.

## Skill management

- User-level skills live in `~/.agents/skills/` (a git repo). All changes must be committed.
- To create a skill: invoke the `skill-template` skill.

## Local projects

Projects in `~/local/hub`, `~/local/admit`, and `~/local/enroll` use git worktrees. New worktrees may be missing a `.env` file. If any code or tooling complains about a missing env file, copy one from the sibling `../dev` worktree before proceeding:

```sh
cp ../dev/.env .env
```

