# Agent Instructions

- Before making any code changes, invoke the `git` skill. Commit at
  logical checkpoints while working — each verified state is a commit
  point. Never present completed work with uncommitted changes.
- Invoke `governing-principles` when a task needs shared principle guidance on
  necessity, framing, tone, or documentation accuracy.
- Invoke the project-level `testing` skill whenever you write, modify, or adapt tests of any kind.
- Before citing something as an established pattern or convention in this codebase, verify it exists in a stable canonical branch and has been there long enough to be considered conventional. A pattern introduced recently on the current feature branch is not an established convention. If you mean a framework or community convention, say so and cite that directly.

## Skill management

- User-level skills live in a dedicated git repo. All changes must be committed.
- To create a skill: invoke the `skill-template` skill.
- Skills must reference files by mapped name, not by hardcoded path.

## File map

| Name | Path | Notes |
| ---- | ---- | ----- |
| User agent instructions | `~/.agents/AGENTS.md` | This file; always-on via `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` |
| User skills | `~/.agents/skills/<name>/SKILL.md` | Invokable by name in any project; directory is a git repo |
