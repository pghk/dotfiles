---
name: voyager-layout
description: >
  How to read, change, build and flash the ZSA Voyager layout, which is QMK
  source in the dotfiles. Use when working out the current layout, mod-tap
  keys, combos and custom behaviours, or when changing them. Re-read the
  source files each time — don't rely on a cached layout summary.
---

## Where the layout lives

The layout is QMK source in `~/.config/voyager/`, managed by chezmoi. Edit it
at `~/.local/share/chezmoi/source/private_dot_config/voyager/` and commit there.
Oryx can't import QMK source, so layout changes are made here, not in Oryx.
Always read the current source rather than a previous summary.

`~/.config/voyager/README.md` covers building, flashing, the layers, one-shot
behaviour and the lighting scheme. Read it before changing the layout.

- **Overview:** `~/.config/voyager/cheatsheet.py` prints every layer and
  combo as Markdown tables, read from `keymap.c`.
- **Verify a change:** build, then have the user flash and try it. A clean
  build only shows the keymap compiles; behaviour needs the board.

---

## Source files

| File | What it contains |
|---|---|
| `keymap.c` | Layer definitions, combos, custom keycodes, key lighting — **primary source** |
| `config.h` | Timing settings (tapping term, combo term), feature flags |
| `rules.mk` | QMK feature enablement |
| `keymap.json` | QMK community modules the keymap uses (`zsa/defaults`) |

Read `keymap.c` and `config.h` first.

---

## ZSA Voyager physical layout

The `LAYOUT_voyager()` macro takes 52 arguments in this order:

```
Row 1:  L1  L2  L3  L4  L5  L6    R1  R2  R3  R4  R5  R6
Row 2:  L1  L2  L3  L4  L5  L6    R1  R2  R3  R4  R5  R6
Row 3:  L1  L2  L3  L4  L5  L6    R1  R2  R3  R4  R5  R6
Row 4:  L1  L2  L3  L4  L5  L6    R1  R2  R3  R4  R5  R6
Thumbs: LT1 LT2                   RT1 RT2
```

Row 1 is the number row (top). Row 4 is the bottom row. Thumbs are the 2-key
clusters closest to the center on each half.

---

## Keycode syntax reference

### Standard keys
- `KC_A` … `KC_Z`, `KC_1` … `KC_0` — literal keys
- `KC_TRANSPARENT` — pass through to the layer below (often written `___`)
- `KC_NO` — blocked, sends nothing

### Layer switching
| Keycode | Behaviour |
|---|---|
| `MO(n)` | Momentary: layer active while held |
| `TG(n)` | Toggle: alternate on/off each press |
| `TO(n)` | Move: switch to layer, stay there |
| `TT(n)` | Tap-toggle: momentary on hold, toggle on double-tap |
| `OSL(n)` | One-shot: next keypress uses layer n, then returns |
| `QK_LLCK` | Layer lock: lock current layer on until pressed again |

### Modifiers and shortcuts
| Keycode | Behaviour |
|---|---|
| `OSM(MOD_*)` | One-shot modifier: applies to the next key on tap, locks on double tap, plain modifier when held |
| `G(kc)`, `C(kc)`, `S(kc)`, `A(kc)` | Sends `kc` with Cmd, Ctrl, Shift or Opt; nest them for several (`S(G(KC_LEFT))`) |
| `CW_TOGG` | Caps Word: capitalises the next word |

### Dual-role keys
| Keycode | Behaviour |
|---|---|
| `MT(MOD_*, KC_*)` | Mod-tap: hold = modifier, tap = key |
| `LT(n, KC_*)` | Layer-tap: hold = momentary layer n, tap = key |
| `MEH_T(KC_*)` | Meh-tap: hold = Ctrl+Shift+Alt, tap = key |

Common mod flags: `MOD_LCTL`, `MOD_LALT`, `MOD_LGUI`, `MOD_RCTL`, `MOD_RALT`,
`MOD_RGUI`, `MOD_LSFT`, `MOD_RSFT`.

### Custom keycodes and `process_record_user`
If `keymap.c` defines custom keycodes (via `enum custom_keycodes`) and
`process_record_user()`, read that function carefully — it overrides the
declared keycode behaviour. A key declared as `LT(n, KC_X)` may actually
send something completely different on tap/hold if handled in
`process_record_user`. Look for the `record->tap.count > 0` branch (tap) vs
the else branch (hold).

### Combos
Defined as arrays + a `key_combos[]` table:

```c
const uint16_t PROGMEM comboN[] = { KC_A, KC_B, COMBO_END };
COMBO(comboN, output_keycode)
```

`COMBO_TERM` in `config.h` is the window in milliseconds: a combo fires only
when all its keys go down within it, so typing the keys one after another
doesn't trigger it. `COMBO_COUNT` in `config.h` must match the number of
entries in `key_combos[]`.

### Lighting
Key colours come from each key's keycode on the active layer, in
`key_color()` in `keymap.c`. A new key takes its colour automatically. A kind
of keycode `key_color()` doesn't recognise stays dark, so give it a case
there, and a label in `cheatsheet.py`, which prints unknown keycodes raw.

The legacy `RGB_*` lighting keycodes control underglow strips, which the
Voyager doesn't have, so they do nothing. Its key lighting uses the `RM_*`
keycodes (`RM_VALU`, `RM_TOGG` and so on).

---

## What to extract and report

When asked to describe the layout, produce:

1. **Layer summary table** — name/purpose of each layer and how it's accessed
2. **Visual grid per layer** — run `cheatsheet.py` rather than drawing grids
   by hand
3. **Mod-tap inventory** — all keys with hold≠tap behaviour, in one list. These
   affect editor behaviour: holding these keys in vim or any editor triggers the
   modifier, not the letter.
4. **Combo table** — keys, output, and timing. Flag any combos whose component
   keys are common vim motion keys (h/j/k/l/d/f/i/u/w/b/e etc.) as potential
   editor conflicts.
5. **Custom keycode behaviour** — anything handled in `process_record_user`
   with non-obvious tap/hold semantics.
6. **Config settings** — `TAPPING_TERM`, `COMBO_TERM`, `PERMISSIVE_HOLD`,
   `CHORDAL_HOLD` from `config.h`. These affect timing behaviour across all
   dual-role keys.

---

## Vim/editor conflict flags

After parsing, highlight anything that could surprise vim users:

- **Combos on motion keys** — e.g. `K+J → Enter` means `kj` typed within
  combo-term fires Enter in any editor, not cursor movement
- **Mod-tap on common keys** — holding `d`, `f`, `v` etc. produces a modifier
  rather than repeating the letter; auto-repeat won't work for those keys
- **`PERMISSIVE_HOLD`** — makes mod-tap keys trigger the hold action more
  aggressively on rolls; can cause unintended modifier fires during fast typing
