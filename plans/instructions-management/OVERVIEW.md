# Instructions Management

**Status:** in-progress  
**Last updated:** 2026-05-14

## What this is

Copilot instructions are currently split across multiple files with inconsistent
tracking. Universal instructions (behaviour rules, skill invocation) sit in
`~/.copilot/copilot-instructions.md` — an untracked, Copilot-specific file — instead
of in `~/.agents/AGENTS.md`, which is tracked. The goal is to move all universal,
non-machine-specific content into the tracked agents repo, and leave
`~/.copilot/copilot-instructions.md` as a purely local file containing only
system-specific paths and file map entries.

## Goals

- All universal instructions tracked in git (agents repo)
- `~/.copilot/copilot-instructions.md` contains only system-specific content (paths)
- No duplication between the two files
- Clear, documented convention for which file gets what

## Out of scope

- Changes to `~/.agents/skills/` or the skills system itself
- Project-level `AGENTS.md` files in individual repos
- Tracking `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` — accepted as a manual setup step per machine
- Changes to how the Copilot CLI loads instructions (external bug #1433)
- Chezmoi templating of `~/.copilot/copilot-instructions.md` — using Copilot is itself
  a system-specific choice, so the file stays fully local and untracked

## Constraints

- `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` is set in `~/.config/zsh/.zshrc_custom` (untracked).
  Accepted as a manual setup step — not tracked in dotfiles.
- `~/.copilot/copilot-instructions.md` is not tracked by chezmoi. It is a local file,
  set up manually per machine.
- `~/.agents/AGENTS.md` is tracked in the agents git repo. This is the right home for
  all universal, shareable instructions.

## Content split

| Content | Home | Rationale |
|---------|------|-----------|
| Behaviour rules ("Commit completed work", etc.) | `~/.agents/AGENTS.md` | Universal; should apply on any machine using Copilot |
| Skill invocation rules ("Always load judgement") | `~/.agents/AGENTS.md` | Universal |
| Skill management conventions | `~/.agents/AGENTS.md` | Universal |
| File map — static rows | `~/.agents/AGENTS.md` | Universal paths/repos |
| File map — local paths (vault, codebase paths) | `~/.copilot/copilot-instructions.md` | Machine-specific |
| Local project notes | `~/.copilot/copilot-instructions.md` | Machine-specific |

## Open questions

1. Should the `## Startup` section in copilot-instructions.md (which documents how
   AGENTS.md loading works) move to AGENTS.md, be removed, or stay where it is?
2. Are there static file map rows (non-path entries) worth moving to AGENTS.md?

## Links

- [TODOS.md](TODOS.md)
- [DECISIONS.md](DECISIONS.md)
- [ARCHITECTURE.md](ARCHITECTURE.md)

