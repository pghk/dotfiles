# User Instructions

## Startup

The user agent instructions (AGENTS.md) are auto-loaded at session start via `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` — no manual read is needed per request. If a relevant skill applies to the first message, invoke it immediately per the skill system requirements; reading AGENTS.md and invoking the skill can happen in the same parallel call.

## Skill management

- User-level skills live in a dedicated git repo. All changes must be committed.
- To create a skill: invoke the `skill-template` skill.
- Skills must reference files by mapped name, not by hardcoded path.

## File map

| Name | Path | Notes |
| ---- | ---- | ----- |
| User agent instructions | `~/.agents/AGENTS.md` | Always-on; loaded via `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` |
| User copilot instructions | `~/.copilot/copilot-instructions.md` | This file; loaded from `$HOME/.copilot/` |
| User skills | `~/.agents/skills/<name>/SKILL.md` | Invokable by name in any project; directory is a git repo |
| Admit codebase | `/Users/paul.hendrick/local/admit/main` | Separate app sharing Hub's DB; Hub migrations are local/test only — Admit's Phinx migrations govern production schema |
