# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## What This Is

A [chezmoi](https://www.chezmoi.io/)-managed dotfiles repo for macOS (with Linux support). The chezmoi root is the `source/` directory (set via `.chezmoiroot`). Everything in `source/` maps to `~/` on the target machine.

## Key Commands

```sh
# Apply dotfiles to the current machine
dot apply           # 'dot' is an alias for 'chezmoi'

# Preview changes without applying
dot diff

# Edit a managed file (opens in editor, auto-applies on save)
dot edit ~/.zshrc

# Run tests (requires bats-core)
bats scripts/test.bats

# Capture macOS defaults before/after UI changes (for codifying them)
scripts/dump_macos_settings.sh

# Set machine hostname
scripts/set_machine_name.sh

# Rebuild macOS dock layout
scripts/setup_dock.sh
```

## Source Directory Naming Conventions

Chezmoi uses filename prefixes to determine how files are deployed. Prefixes must appear in the order listed below when combined.

**Files** — valid prefix order: `encrypted_`, `private_`, `readonly_`, `empty_`, `executable_`, `dot_`

**Directories** — valid prefix order: `remove_`, `external_`, `exact_`, `private_`, `readonly_`, `dot_`

**Scripts** — prefix order: `run_`, then optionally `once_` or `onchange_`, then optionally `before_` or `after_`

**Symlinks** — prefix order: `symlink_`, `dot_`

| Prefix / Suffix | Meaning |
|-----------------|---------|
| `dot_` | Renames to `.<name>` on the target (e.g. `dot_zshrc` → `~/.zshrc`) |
| `private_` | Deploys with mode 0600 (files) or 0700 (dirs) |
| `exact_` | Removes any target directory entries not present in the source |
| `executable_` | Deploys with executable bit set |
| `readonly_` | Deploys with write bit cleared |
| `empty_` | Creates the file even if the source is empty (chezmoi skips empty files by default) |
| `create_` | Only creates the target if it doesn't already exist (never overwrites) |
| `modify_` | Script that receives the current file on stdin and writes the new content to stdout |
| `remove_` | Removes the corresponding target entry |
| `symlink_` | Creates a symlink; file contents are the link target |
| `encrypted_` | File is encrypted (decrypted at apply time) |
| `.tmpl` suffix | Processed as a Go template before being written |
| `run_once_` | Script runs only once (keyed on script name) |
| `run_onchange_` | Script runs when its contents change |
| `before_` / `after_` | Script runs before or after file targets are applied |

## Template Variables

Templates (`.tmpl` files) have access to these data variables set during `chezmoi init`:

- `.email` - User's email address
- `.profile` - Install profile: `Shell`, `Personal`, or `Work`
- `.opVault` - 1Password vault name (optional)
- `.chezmoi.os` - `darwin` or `linux`
- `.chezmoi.arch` - e.g., `arm64`

CI mode is detected via the `CI` environment variable, which suppresses interactive prompts and skips 1Password/SSH/git config.

## Brewfile Structure

Packages are split into profiles and combined via `dot_Brewfile.tmpl`:

- `01.Brewfile` — Base tools (always installed)
- `02.Brewfile` — Extended tools (Personal + Work)
- `Home.Brewfile` — Mac App Store personal apps
- `Work.Brewfile` — Work-specific tools

After modifying any Brewfile, `brew bundle --global` is triggered automatically by the `run_onchange_after_install-packages.sh.tmpl` script on next `dot apply`.

## Architecture Notes

### Chezmoi Lifecycle Scripts (`source/.chezmoiscripts/`)
Scripts are split into `macOS/` and `linux/` subdirectories and conditionally excluded via `.chezmoiignore` based on OS. Run order is controlled by numeric prefixes in filenames.

### Hammerspoon (`source/dot_hammerspoon/`)
Custom macOS desktop automation in Lua. Key files:
- `init.lua` — Entry point; loads spoons and initializes grid + tiling managers
- `hotkeys/binding.lua` — JSON-based hotkey registry with modal mode support
- `services/window/grid.lua` — Aspect-ratio-aware grid snapping (notch-aware for 16"/14" MBPs)
- `services/window/tiling.lua` — Window focus/swap with golden-ratio mouse positioning

### CI (Codemagic)
Defined in `codemagic.yaml`. Triggers on PRs to `macos-*` branches. Runs on Mac Mini M1: wipes Homebrew, runs `scripts/install.sh` with `Shell` profile, then `bats scripts/test.bats`.

### Branch Strategy
- `develop` — Primary development branch
- `macos-14`, `macos-13`, etc. — OS-specific stable branches (PRs merge here for CI)
- `linux` — Linux variant

### plist Files
The chezmoi config registers a `plutil` textconv for `*.plist` files so diffs are human-readable XML instead of binary.
