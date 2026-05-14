# Architecture

## System context

```
┌─────────────────────────────────────────────────────────────┐
│ git (dotfiles repo)                                         │
│                                                             │
│  source/dot_copilot/copilot-instructions.md.tmpl  ──────┐  │
│  source/.chezmoi.toml.tmpl  (promptStringOnce vars)     │  │
└─────────────────────────────────────────────────────────│──┘
                                                          │ chezmoi apply
                                                          ▼
┌─────────────────────────────────────────────────────────────┐
│ machine-local (not tracked)                                 │
│                                                             │
│  ~/.config/chezmoi/chezmoi.toml  (stores prompted values)  │
│  ~/.copilot/copilot-instructions.md  (rendered output)  ◄──┘
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ git (agents repo)                                           │
│                                                             │
│  ~/.agents/AGENTS.md  (always-on project-agnostic rules)   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ shell environment                                           │
│                                                             │
│  COPILOT_CUSTOM_INSTRUCTIONS_DIRS=~/.agents                 │
│  (set in tracked shell config — location TBD)              │
└─────────────────────────────────────────────────────────────┘
```

## Template structure

`copilot-instructions.md.tmpl` renders to `~/.copilot/copilot-instructions.md`:

```
# User Instructions

[universal behaviour rules — hardcoded in template]

## Skill management

[universal skill conventions — hardcoded in template]

## File map

| Name | Path | Notes |
| ---- | ---- | ----- |
| ...static rows... |
| Obsidian vault | {{ .chezmoidata.obsidianVault }} | ... |
| Admit codebase  | {{ .chezmoidata.admitCodebase }}  | ... |
```

> **TBD** — full template content, open question 1 (other machine-specific vars)

## chezmoi data variables

> **TBD** — exact variable names and promptStringOnce syntax, pending task 2.1

## `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` placement

> **TBD** — open question 2 (where is it currently set, and where should it live)

## Loading sequence at session start

1. Copilot CLI reads `~/.copilot/copilot-instructions.md` (primary, always present)
2. Copilot CLI reads `AGENTS.md` files from `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` (secondary)
3. Project-level `AGENTS.md` loaded from CWD hierarchy (tertiary)

## Error handling / degraded states

> **TBD** — what happens if chezmoi apply hasn't been run on a new machine yet?
> Consider whether the template should have sensible defaults for optional path vars.
