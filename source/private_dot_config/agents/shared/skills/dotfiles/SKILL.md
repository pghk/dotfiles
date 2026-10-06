---
name: dotfiles
description: >
  How to work with this user's chezmoi-managed dotfiles repo. Use when asked
  to modify dotfiles, config files, or shell setup from any project context —
  not just when already inside the chezmoi repo.
---

## Repo location

```
~/.local/share/chezmoi/
```

The chezmoi root is `source/` (set via `.chezmoiroot`). Files in `source/`
map to `~/` on the target machine using chezmoi's naming conventions.

## Edit workflow

Source files live in `source/` under chezmoi naming (`dot_`, `private_`,
`.tmpl`). Default: `chezmoi edit $TARGET_PATH`, then `chezmoi apply`. For
iterative testing of non-templated files, edit the live file, then
`chezmoi re-add`. `re-add` does not work on templated files.
`AGENTS.md` (below) has the full rules.

Commit from the chezmoi repo, not from the live config location.

## Repo conventions

The chezmoi repo has its own `AGENTS.md` at `~/.local/share/chezmoi/AGENTS.md` covering
source/target file naming, editing workflow, and agent instruction file conventions
(including which files must not be tracked). Read it before making changes.

## Key commands

```sh
dot apply        # apply dotfiles to current machine ('dot' aliases 'chezmoi')
dot diff         # preview changes without applying
dot edit ~/.zshrc  # edit a managed file (auto-applies on save)
```
