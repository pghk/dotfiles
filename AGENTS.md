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

## This file

`AGENTS.md` lives at the repo root and is **not** managed by chezmoi. Editing it
directly is all that's needed — no `apply` or `re-add` step required.
