# Architecture

## System context

```
┌─────────────────────────────────────────────────────────────┐
│ git (agents repo: ~/.agents/)                               │
│                                                             │
│  AGENTS.md  ← universal instructions (all machines)        │
│  skills/    ← invokable skills                             │
└──────────────────────────┬──────────────────────────────────┘
                           │ loaded via COPILOT_CUSTOM_INSTRUCTIONS_DIRS
                           ▼
┌─────────────────────────────────────────────────────────────┐
│ machine-local (not tracked)                                 │
│                                                             │
│  ~/.config/zsh/.zshrc_custom                               │
│    export COPILOT_CUSTOM_INSTRUCTIONS_DIRS="$HOME/.agents" │
│                                                             │
│  ~/.copilot/copilot-instructions.md  ← local paths only    │
└─────────────────────────────────────────────────────────────┘
```

## Content split

### `~/.agents/AGENTS.md` (tracked)

- Behaviour rules: "Commit completed work", etc.
- Skill invocation: "Always load judgement"
- Skill management conventions
- File map — rows with stable/universal paths and descriptions
- Any instruction that should apply on every machine using Copilot

### `~/.copilot/copilot-instructions.md` (local, untracked)

- File map rows with machine-specific paths (Obsidian vault, codebase paths)
- Any local project notes or machine-specific overrides
- Nothing else

## Setup on a new machine (manual steps)

1. Clone agents repo to `~/.agents/`
2. Add `export COPILOT_CUSTOM_INSTRUCTIONS_DIRS="$HOME/.agents"` to `~/.config/zsh/.zshrc_custom`
3. Create `~/.copilot/copilot-instructions.md` with local paths

> **TBD** — open question 1: fate of `## Startup` section in copilot-instructions.md

