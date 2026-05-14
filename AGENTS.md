# Agent Instructions

## chezmoi: source vs. target

This repo is managed by [chezmoi](https://www.chezmoi.io/). Files exist in two locations:

- **Source** — tracked in git, at `~/.local/share/chezmoi/source/` (this repo)
- **Target** — the live filesystem, usually under `$HOME`

File names differ between locations. chezmoi translates source filenames using these rules:

| Source prefix/suffix | Target meaning |
|----------------------|----------------|
| `dot_` prefix | `.` (e.g., `dot_zshenv` → `.zshenv`) |
| `private_` prefix | file/dir is mode 600/700 in target |
| `.tmpl` suffix | Go template; suffix stripped in target |
| `symlink_` prefix | creates a symlink in target |
| `run_once_` prefix | script executed once only |
| `run_onchange_` prefix | script re-executed when content changes |
| `.chezmoiscripts/macOS/` | only applied on macOS |
| `.chezmoiscripts/linux/` | only applied on Linux |

To find the source path for a given target file, use:

```sh
chezmoi source-path ~/.config/some/file
```

## Editing files: which direction to work

| Situation | Approach |
|-----------|----------|
| File is templated (`.tmpl` in source) | `chezmoi edit $TARGET_PATH`, then `chezmoi apply` |
| Non-templated, one-shot change | `chezmoi edit $TARGET_PATH`, then `chezmoi apply` |
| Non-templated, iterative (many test cycles before committing) | Edit target directly, then `chezmoi re-add` |

**`chezmoi edit $TARGET_PATH`** is the preferred approach for most changes. It takes the
target path (e.g., `~/.zshrc`) and opens the corresponding *source* file — including the
raw template if the file is templated — so path translation is handled transparently.

Use `chezmoi edit --apply $TARGET_PATH` to apply immediately on editor close, or
`chezmoi edit --watch $TARGET_PATH` to apply on every save.

**`re-add` does not work with templated files.** For templated files, always edit source.

When both source and target have diverged, use `chezmoi merge $TARGET_PATH` to resolve.

## Key commands

```sh
chezmoi edit $FILE          # open source file for a target path
chezmoi edit --apply $FILE  # edit and apply on close
chezmoi edit --watch $FILE  # edit and apply on every save
chezmoi apply               # push source → target
chezmoi re-add              # pull target → source (non-templated only)
chezmoi diff                # preview what apply would change
chezmoi status              # show which managed files have diverged
chezmoi merge $FILE         # merge tool for source/target conflicts
chezmoi managed             # list all managed files
chezmoi unmanaged           # list files not managed by chezmoi
chezmoi source-path $FILE   # print source path for a target path
```

## Agent instructions: two-file convention

Agent instructions are split across two files:

| File | Purpose | Tracked? |
|------|---------|---------|
| `~/.agents/AGENTS.md` | Universal behaviour rules, skill conventions, file map | Yes — chezmoi (`source/dot_agents/AGENTS.md`) |
| `~/.copilot/copilot-instructions.md` | Machine-specific paths, local projects, local file map rows | No — intentionally local |

`~/.agents/AGENTS.md` is always-on: `COPILOT_CUSTOM_INSTRUCTIONS_DIRS=~/.agents` in
`~/.config/zsh/.zshrc_custom` makes Copilot load it in every session without manual setup.

`~/.copilot/copilot-instructions.md` must **not** be added to chezmoi — its content is
machine-specific.

## This file

`AGENTS.md` lives at the repo root and is **not** managed by chezmoi. Editing it
directly is all that's needed — no `apply` or `re-add` step required.

## Obsidian config

`~/.config/obsidian/` (chezmoi source: `source/private_dot_config/private_obsidian/`)
is a **template** for vault config, not a live Obsidian config. Obsidian reads from the
vault's `.obsidian/` directory, not from here. The vault path is in user-level copilot
instructions.

**Files tracked in dotfiles** (and expected in the vault):
- `appearance.json`, `hotkeys.json`, `community-plugins.json`, `core-plugins.json`
- `scripts/`, `snippets/`, `templates/`

**Files only in the vault** (not tracked in dotfiles):
- `plugins/*/data.json` — plugin settings
- `workspace.json`, `core-plugins-migration.json` — Obsidian-managed runtime state
- `app.json` — gitignored in this repo (see `.chezmoiignore`)

**Sync is manual and bidirectional.** After editing dotfiles, the user must copy
changed files into the vault's `.obsidian/`. After configuring something in Obsidian,
the vault's `.obsidian/` may need to be copied back into dotfiles to keep them in sync.
Remind the user to sync after making changes here.
