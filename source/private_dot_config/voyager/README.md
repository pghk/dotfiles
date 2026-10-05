# Voyager layout

QMK source for my ZSA Voyager. This directory is the layout's source of truth: Oryx can't import QMK source, so changes are made here, not in Oryx.

The directory is deployed by chezmoi. Edit it in the chezmoi source and commit there.

## Build and flash

1. Start Docker. The build runs in QMK's CLI container.
2. Run `./build.sh`. It fetches ZSA's QMK fork into `~/.cache/voyager` on first use, compiles this keymap, and prints the path of the firmware.
3. Run `zapp flash <firmware path>`, then press the Voyager's reset button.

The fork is pinned by commit in `build.sh`. To move to a newer ZSA firmware, change the hash, then build, flash and test before committing.

## Files

| File | Contents |
|---|---|
| `keymap.c` | Layers, combos, custom keys, per-key tapping terms, LED colours |
| `config.h` | Timing and tap-hold behaviour |
| `rules.mk` | Enabled QMK features |
| `keymap.json` | QMK community modules (`zsa/defaults`) |

## Layers

| # | Layer | Reached by |
|---|---|---|
| 0 | Base: QWERTY with a number row | — |
| 1 | Symbols | Right thumb's inner key: tap for one key, double-tap to lock, hold for momentary. The `d`+`f` combo also gives one key |
| 2 | Navigation | Left thumb's inner key: tap for one key, double-tap to lock, hold for momentary |
| 3 | Numpad | Top-left key: hold for momentary, tap repeatedly to lock |
| 4 | Function keys | Hold the top-right key; the layer stays on after release |
| 5 | Media and lighting | The `8`+`7` combo toggles it |

Every layer except Symbols has a top-corner key back to base; on Function keys it's the top-right key, held. Symbols and Navigation also unlock with their own key.

## Behaviour

**Mod-taps.** The bottom row's `x c v` and `m , .` give Ctrl, Alt and Cmd when held, mirrored on each hand. The key in the Caps Lock position is Esc on tap and Meh (Ctrl+Alt+Shift) on hold. Chordal hold resolves a mod-tap as a tap when the next key is on the same hand, so a modifier chord needs the mod-tap on the opposite hand to the key it modifies.

**Combos** (30 ms window):

| Keys | Output |
|---|---|
| `k`+`j` | Enter |
| `u`+`i` | Backspace |
| `d`+`f` | One-shot Symbols |
| `8`+`7` | Toggle Media and lighting |
| Esc/Meh + left-thumb Cmd | Hyper (Ctrl+Alt+Shift+Cmd) |
| Play + Next | Back to base |

**One-shot layers.** A second tap within the tapping term (200 ms, QMK's default) locks the layer, and another tap unlocks it. A one-shot has no timeout, so a tapped layer waits for the next key.

**Navigation.** Arrows sit on `hjkl`, with paging, Home/End, Backspace, Delete and browser back/forward around them. The left hand has Cmd+A on `a` and Cmd+Z/X/C/V on `z x c v`, so editing works one-handed while the other hand is on the mouse.

**Symbols.** The number row is F1–F12. The right hand switches between tabs (Ctrl+Shift+Tab / Ctrl+Tab on `h j`), cmux workspaces (Cmd+Ctrl+[ / ] on `n m`) and browser history (Cmd+[ / ] on `, .`), so these work one-handed while the left hand is on the mouse. Caps Word sits at the end of the top letter row.

**Custom keys.**
- **Dictation** (`MAC_SIRI`) sends the consumer usage that macOS treats as dictation. It's on the Navigation layer.
- **Top-right on base:** Cmd+Ctrl+F (full screen) on tap; holding it moves to the Function keys layer.
- **Top-right on Function keys:** F12 on tap; holding it returns to base.
