---
name: keyboard-config
description: >
  OS and hardware layer keyboard configuration: modifier hierarchy, window
  management (Hammerspoon, Yabai), Obsidian app hotkeys, Karabiner physical
  remapping, and ZSA Voyager layout. Use when working on window management
  bindings, app-level shortcuts, or physical key config. For vim keymaps
  across editors, use the `vim` skill instead.
---

## How to use this skill

Read all sections before answering. For any new binding, check the conflict
zones before choosing a key combination.

---

## System overview

This is a fully keyboard-driven macOS setup. The layers from lowest to
highest specificity:

1. **Karabiner-Elements** — physical key remapping (Caps Lock → Meh/Esc)
2. **Hammerspoon + Yabai** — OS-level window management
3. **macOS** — system shortcuts (spaces, screenshots, etc.)
4. **App-level** — Obsidian hotkeys.json, Zed, JetBrains
5. **Modal vim** — leader-prefixed and mode-specific bindings inside editors

These layers are designed to be conflict-free because they use distinct
modifier combinations (see Modifier Hierarchy below).

---

## Modifier key hierarchy

**Physical remapping (Karabiner):**
- Caps Lock **held** → `meh` (⇧⌃⌥ — shift+ctrl+alt)
- Caps Lock **tapped alone** → `Escape`
- This makes Caps Lock the gateway to the entire window management layer

**Named modifier sets:**
| Name | Keys | Source |
|---|---|---|
| `meh` | shift+ctrl+alt (⇧⌃⌥) | Caps Lock held |
| `hyper` | shift+ctrl+alt+cmd (⇧⌃⌥⌘) | Caps Lock + Cmd |
| `alt+shift` | alt+shift | Mode cycling |

**Design principle:** Editor bindings use `<leader>` (space) or plain modal
keys. App/OS bindings use `alt+` combos. Window management uses `meh`/`hyper`.
These three zones never collide.

---

## Window management bindings (Hammerspoon + Yabai)

Source: `~/.hammerspoon/hotkeys/registry.json`

### Global (always active)

| Keys | Action |
|---|---|
| `alt+shift+space` | Cycle between move/focus modal modes |
| `meh+i` | Center window |
| `meh+h/j/k/l` | Focus window west/south/north/east |
| `hyper+u/i/o/p` | Shrink / Maximize / Grow / Rotate window |
| `hyper+h/j/k/l` | Push to other screen / Pull / Swap / Move mouse to next screen |
| `meh+u` | *(reserved)* Move left a macOS space |
| `meh+o` | *(reserved)* Move right a macOS space |

### Move modal (cycle to with `alt+shift+space`)

| Keys | Action |
|---|---|
| `meh+h/j/k/l` | Move window left/down/up/right |
| `hyper+h/j/k/l` | Make window thinner/taller/shorter/wider |

---

## Obsidian app-level hotkeys

Source: `~/.config/obsidian/hotkeys.json`

| Keys | Action |
|---|---|
| `alt+[` or `alt+X` | Toggle left sidebar |
| `alt+]` or `alt+C` | Toggle right sidebar |
| `alt+ctrl+→` or `cmd+shift+L` | Next tab |
| `alt+ctrl+←` or `cmd+shift+H` | Previous tab |
| `alt+cmd+E` | Insert Templater template |
| `alt+F` | Next daily note |
| `alt+S` | Previous daily note |

Note: `cmd+shift+L/H` mirrors the vim `<S-l>/<S-h>` intent but at the
app level for when not in vim mode.

---

## File paths: where to edit

| What you want to change | Edit this file |
|---|---|
| Obsidian app-level hotkeys | `~/.config/obsidian/hotkeys.json` |
| Window management bindings | `~/.hammerspoon/hotkeys/registry.json` |
| Physical key remapping | `~/.config/karabiner/karabiner.json` |
| Voyager keyboard layout | `~/.config/voyager/` (see `voyager-layout`) |
| cmux shortcuts (tabs, workspaces) | `~/.config/cmux/cmux.json` |

All managed by chezmoi at `~/.local/share/chezmoi/source/`.

For vim keymaps across all editors, see the `vim` skill.

---

## Conflict zones: what to avoid

**Already claimed — do not reuse:**
- `meh+*` and `hyper+*` → window management (Hammerspoon)
- `alt+[`, `alt+]`, `alt+X`, `alt+C` → Obsidian sidebar
- `alt+F`, `alt+S` → Obsidian daily notes
- `alt+cmd+E` → Obsidian Templater
- `meh+u`, `meh+o` → macOS space navigation
- `ctrl+tab`, `ctrl+shift+tab` → next/previous tab in every app; apps that
  default to something else are rebound to these
- `cmd+ctrl+[`, `cmd+ctrl+]` → previous/next cmux workspace

**Safe zones for new bindings:**
- `<leader>+*` inside editors (space is vim leader, doesn't reach OS layer)
- `hyper+*` letters not yet in registry (a–g, m–t, v–z)
- `meh+*` letters not yet in registry (a–g, m–n, p–t, v–z) — check registry first

---

## ZSA Voyager keyboard

Source: `~/.config/voyager/` (QMK source, managed by chezmoi)

Use the `voyager-layout` skill to read, change, build or flash the layout. The
summary below covers only what's relevant to editor/vim config decisions.
Re-read the source if the layout may have changed.

### Mod-tap keys on Layer 0 (hold ≠ tap)

| Key | Tap | Hold |
|---|---|---|
| `X` | x | Left Ctrl |
| `C` | c | Left Alt |
| `V` | v | Left Cmd |
| `M` | m | Right Cmd |
| `,` | , | Right Alt |
| `.` | . | Right Ctrl |
| `MEH/ESC` (row 3 col 1) | Escape | Meh ⇧⌃⌥; with `V` held, Hyper ⇧⌃⌥⌘ |

These keys do not auto-repeat and cannot be held for letter repetition.

**Chordal hold:** a mod-tap held under the same hand as the next key resolves
as a tap. So `V` held + `C` types "vc", not Cmd+C. A shortcut on left-hand
letters needs the right-hand mod-tap (`M` for Cmd), the left thumb's one-shot
Cmd, or the Nav layer's dedicated keys. Check this when choosing a new
shortcut that the Voyager has to type.

### Thumbs and layers

| Key | Tap | Hold |
|---|---|---|
| Left thumb, outer | One-shot Cmd (double tap locks) | Cmd |
| Left thumb, inner | One-shot Nav layer (double tap locks) | Nav while held |
| Right thumb, inner | One-shot Sym layer (double tap locks) | Sym while held |
| Right thumb, outer | Space | Space |

The top-left key is the same kind of one-shot key for the Num layer. See
`~/.config/voyager/README.md` for what each layer holds.

### Combos (30ms window)

| Keys | Output | Editor impact |
|---|---|---|
| `K` + `J` | Enter | ⚠️ A fast `kj` roll in vim normal mode can fire Enter |
| `D` + `F` | One-shot Sym layer | ⚠️ A fast `df` roll can open Sym instead of typing `df` |
| `I` + `U` | Backspace | ⚠️ A fast `iu` roll can fire Backspace |

A combo fires only when both keys go down within 30ms, so typing `df`, `kj`
or `iu` one key after the other doesn't trigger it. Pressing them together
does, which is how the combos are used.
