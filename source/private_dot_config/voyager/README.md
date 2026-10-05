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
| `keymap.c` | Layers, combos, custom keys, LED colours |
| `config.h` | Timing and tap-hold behaviour |
| `rules.mk` | Enabled QMK features |
| `keymap.json` | QMK community modules (`zsa/defaults`) |

## Layers

| # | Layer | Reached by |
|---|---|---|
| 0 | Base: QWERTY with a number row | — |
| 1 | Symbols | Right thumb's inner key, or the `d`+`f` combo for one key |
| 2 | Navigation | Left thumb's inner key |
| 3 | Numpad | Top-left key |
| 4 | Select | The `f` key on Navigation toggles it |

The keys for Symbols, Navigation and Numpad are one-shots: tap for one key, double-tap to lock, tap again to unlock, or hold for momentary. Navigation and Select also return to base from the Esc position.

## Behaviour

**Mod-taps.** The bottom row's `x c v` and `m , .` give Ctrl, Alt and Cmd when held, mirrored on each hand. The key in the Caps Lock position is Esc on tap and Meh (Ctrl+Alt+Shift) on hold; holding it with `v` gives Hyper (Meh+Cmd). Chordal hold resolves a mod-tap as a tap when the next key is on the same hand, so a modifier chord needs the mod-tap on the opposite hand to the key it modifies.

**One-shot Cmd.** The left thumb's outer key applies Cmd to the next key, so left-hand Cmd shortcuts work one-handed without a hold. Like the one-shot layers, a double tap locks it, which makes Cmd+Tab a lock, Tabs, and a tap to release; held, it's an ordinary Cmd.

**Combos** (30 ms window):

| Keys | Output |
|---|---|
| `k`+`j` | Enter |
| `u`+`i` | Backspace |
| `d`+`f` | One-shot Symbols |

**One-shot layers.** The double tap that locks a layer must land within the tapping term (200 ms, QMK's default). A one-shot has no timeout, so a tapped layer waits for the next key. Turning a locked layer off any other way also clears its lock.

**Navigation.** Each right-hand key sends a whole macOS text motion: arrows on `hjkl`; word back/forward (Opt+←/→) on `u o`; line start/end (Cmd+←/→) on `y p`; document top/bottom (Cmd+↑/↓) on `n /`; Page Up/Down on `i ,`; Backspace and Delete on `m .`; Home and End in the outer column. The left hand has:
- Cmd+A on `a` and Cmd+Z/X/C/V on `z x c v`, so editing works one-handed while the other hand is on the mouse. Redo (Cmd+Shift+Z) is on `b`;
- browser back on `w` and forward on `t`, with previous/next tab between them on `e r`;
- one-shot Opt and Cmd on `s d`, for combinations without a dedicated key;
- Select on `f`.

The number row follows the Mac's function row: display brightness, Mission Control, Launchpad, the Voyager's lighting brightness, then previous/play/next, mute and volume.

**Select.** The same motions as Navigation, each extending the selection with Shift, like vim's visual mode. Cut, copy and paste stay on the left hand. `f` returns to plain movement. The keyboard shows its normal lighting rather than a layer colour while Select is on.

**Symbols.** The number row is F1–F12. The right hand switches between tabs (Ctrl+Shift+Tab / Ctrl+Tab on `h j`), cmux workspaces (Cmd+Ctrl+[ / ] on `n m`) and browser history (Cmd+[ / ] on `, .`), so these work one-handed while the left hand is on the mouse. Caps Word sits at the end of the top letter row.

**Numpad.** The right hand is a ten-key pad: 7-8-9 on `u i o`, 4-5-6 on `j k l`, 1-2-3 on `m , .`, and 0 and `.` on the right thumb, with operators, Enter and Backspace around it. Holding the top-left key with the left pinky while typing digits with the right hand works as well as locking it.

**Dictation.** The top-right key on base sends the consumer usage that macOS treats as dictation (`MAC_SIRI` in `keymap.c`).
