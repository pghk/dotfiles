---
name: vim
description: >
  Vim keymap architecture across all editors: vimrc.shared as canonical source,
  propagation model, environment capability matrix, and Neovim config structure.
  Use when adding or modifying vim keymaps, working on the Neovim config, or
  reasoning about vim consistency across Vim, Neovim, IdeaVim, Obsidian, and Zed.
---

## Canonical source: vimrc.shared

`~/.config/vim/vimrc.shared` is the single source of truth for portable vim
keymaps. Changes to shared bindings go here first.

```
vimrc.shared
  ↑ sourced by:  vimrc (Vim)  ·  ideavimrc (IdeaVim)  ·  nvim/init.lua (Neovim)
  mirrored in:   ~/.config/vim/obsidian.vimrc  (standalone — see constraints)
                 ~/.config/zed/empty_keymap.json
```

Neovim and IdeaVim source `vimrc.shared` directly — no Lua or IDE mirror is
needed for shared bindings.

---

## Current keymaps (vimrc.shared)

| Keymap | Mode | Action |
|---|---|---|
| `J` | visual | Move highlighted lines down (`:m '>+1`) |
| `K` | visual | Move highlighted lines up (`:m '<-2`) |
| `<leader>d` | normal + visual | Delete to void register (no yank) |
| `<leader>p` | visual | Replace selection without yanking |
| `<S-l>` | normal | Next tab (`:tabnext`) |
| `<S-h>` | normal | Previous tab (`:tabprev`) |
| `<CR>` | normal | Clear search highlight (`:noh`) |

Leader key: `<space>`

---

## Environment capability matrix

| Feature | Vim | Neovim | IdeaVim | Obsidian | Zed |
|---|---|---|---|---|---|
| Sources vimrc.shared | ✅ direct | ✅ direct | ✅ direct | — standalone mirror | — JSON mirror |
| Line movement (J/K visual) | ✅ | ✅ | ✅ | ⚠️ single-line only | ✅ |
| Tab nav (S-l/S-h) | ✅ | ✅ | ✅ | ✅ via exmap | ✅ |
| `<leader>` bindings | ✅ | ✅ | ✅ | ✅ | ❌ no leader concept |
| Void register (`"_`) | ✅ | ✅ | ✅ | ✅ | ❌ |
| Surround (ys/ds/cs) | ✅ vim-plug | ✅ nvim-surround | ✅ built-in | ❌ | ❌ |
| Commentary (gc) | — | — | ✅ built-in | ❌ | ❌ |
| Plugin system | vim-plug | lazy.nvim | Plug (limited) | ❌ | ❌ |

---

## Propagation checklist: adding a new vim keymap

When adding a new binding, work through this list. Skip environments where
the feature isn't supported (see capability matrix).

1. **Add to `vimrc.shared`** — vimscript, portable subset only
2. **Mirror in `obsidian.vimrc`** — use `exmap` if it needs an Obsidian command; omit if not supported
3. **Mirror in `zed/empty_keymap.json`** — JSON with context condition (`vim_mode == normal/visual`); omit `<leader>` and void register bindings (unsupported)
4. **Commit** — single commit covering all affected files

IdeaVim and Neovim pick up shared bindings automatically (they source
`vimrc.shared`). Only add to `ideavimrc` for IDE-specific actions, and only
add to `nvim/lua/core/keymaps.lua` for Neovim-specific bindings that have no
Vimscript equivalent.

---

## IdeaVim-specific bindings

Source: `~/.config/ideavim/ideavimrc` (`has('ide')` block)

| Keymap | Action |
|---|---|
| `<leader>rn/rm/rv/rf/rs/rr` | Refactoring actions (Rename, Extract Method, etc.) |
| `<leader>gd/gy/gi/gu/gt` | Go to Definition / Type / Implementation / Usages / Test |

---

## Obsidian constraints

- `source` command is **vault-relative** — `obsidian.vimrc` is standalone, not sourcing `vimrc.shared`
- CodeMirror-vim has no `:m` command → J/K use `exmap editor:swap-line-down/up` (normal mode only, single line)
- No plugin system → no surround, no commentary
- Tab nav uses `exmap workspace:next-tab / workspace:prev-tab`

---

## Zed specifics

Zed has no `<leader>` variable. Space-prefixed bindings are written manually:

```json
{ "context": "vim_mode == normal", "bindings": { "space d": "some::Action" } }
```

Zed context strings: `vim_mode == normal`, `vim_mode == insert`,
`vim_mode == visual`, `VimControl && !menu`.

Void register (`"_`) has no Zed equivalent — omit `<leader>d` / `<leader>p`.

---

## Neovim config architecture

Source: `~/.config/nvim/` (chezmoi: `source/private_dot_config/nvim/`)

### Directory structure

```
init.lua                    sequencing only — no config of its own
lua/
  core/
    options.lua             Neovim-only settings (fold display, listchars)
    keymaps.lua             Neovim-specific keymaps extending vimrc.shared (stub by default)
    autocmds.lua            Neovim-specific events (markdown wrap, git commit, chezmoi filetypes)
  plugins/
    appearance.lua          color, statusline, indent guides, status column, dashboard
    editing.lua             surround, formatting, indent detection, undo tree
    navigation.lua          file tree, fuzzy finding, session persistence
    code.lua                treesitter, LSP, completion, folding
    vcs.lua                 git signs, hunk operations, fugitive
```

### core/ vs plugins/ split

**Rule:** does this require a plugin to exist?

- `core/` — pure Neovim config, works with zero plugins installed
- `plugins/` — anything that requires a plugin; plugin keymaps and autocmds live inside the plugin's `config` function, not in `core/`

**Tiebreaker:** if removing the plugin would make the keymap meaningless, it belongs in the plugin file.

### Plugin file conventions

Each `plugins/` file opens with a header documenting what it affords and what
keymaps it owns:

```lua
-- navigation.lua
-- Affordances: file tree (neo-tree), fuzzy finding (telescope)
-- Keymaps:
--   <leader>e   file tree
--   <leader>ff  find files
--   <leader>fg  live grep
```

This header is the contract. Auditing all keymaps means reading five headers.

### Extensibility

- Add a capability → create `plugins/<affordance>.lua`, return a lazy spec table; auto-discovered
- Add a plugin to an existing domain → add spec to the relevant file, update header
- Remove a capability → delete the file; its keymaps leave with it
- Never put plugin-dependent keymaps in `core/keymaps.lua` — that couples core to plugins

### Testing Neovim config changes

Before syncing to chezmoi source and committing, verify the config starts
cleanly:

```bash
nvim --headless -c "qa" 2>&1
echo "EXIT:$?"
```

Must produce no output and exit 0. Any output indicates an error or warning
that needs fixing first.

### init.lua

`init.lua` does exactly three things in order: source `vimrc.shared`, load
`core/` modules, bootstrap lazy.nvim and import `plugins/`. No configuration
of its own.

The lazy spec **must** follow this order:

```lua
spec = {
  { "LazyVim/LazyVim", import = "lazyvim.plugins" },  -- first
  { import = "lazyvim.plugins.extras...." },            -- any extras
  { import = "plugins" },                               -- custom plugins last
}
```

Wrong order leaves Snacks uninitialized at startup, causing keymaps and
colorscheme loading to fail.

### lua_ls context

`dot_luarc.json` in the nvim config root provides the `vim` and `MiniIcons`
globals to lua_ls without requiring neoconf.nvim.

---

## File paths: where to edit

| What you want to change | Edit this file |
|---|---|
| Add/change a portable keymap | `~/.config/vim/vimrc.shared` |
| Vim-specific settings (colorscheme, airline, etc.) | `~/.config/vim/vimrc` |
| IdeaVim IDE actions (refactor, goto, etc.) | `~/.config/ideavim/ideavimrc` |
| Neovim options or autocmds | `~/.config/nvim/lua/core/` |
| Neovim plugin configuration | `~/.config/nvim/lua/plugins/<affordance>.lua` |
| Obsidian vim bindings | `~/.config/vim/obsidian.vimrc` |
| Zed vim bindings | `~/.config/zed/empty_keymap.json` (deploys as `keymap.json`) |

All managed by chezmoi at `~/.local/share/chezmoi/source/`.
