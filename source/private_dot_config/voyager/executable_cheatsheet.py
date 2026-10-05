#!/usr/bin/env python3
"""Prints a Markdown cheat sheet of the layers and combos in keymap.c."""
import re
from pathlib import Path

KEYMAP = Path(__file__).resolve().parent / "keymap.c"

MOD_SYMBOLS = {"C": "⌃", "A": "⌥", "S": "⇧", "G": "⌘",
               "LCTL": "⌃", "LALT": "⌥", "LSFT": "⇧", "LGUI": "⌘"}
MOD_ORDER = "⌃⌥⇧⌘"
MOD_FLAGS = {"MOD_LCTL": "⌃", "MOD_RCTL": "⌃", "MOD_LALT": "⌥", "MOD_RALT": "⌥",
             "MOD_LSFT": "⇧", "MOD_RSFT": "⇧", "MOD_LGUI": "⌘", "MOD_RGUI": "⌘",
             "MOD_MEH": "⌃⌥⇧", "MOD_HYPR": "⌃⌥⇧⌘"}

NAMES = {
    "KC_TRANSPARENT": "", "KC_NO": "",
    "KC_SPACE": "Space", "KC_TAB": "⇥", "KC_ENTER": "⏎", "KC_KP_ENTER": "⏎",
    "KC_ESCAPE": "Esc", "KC_BSPC": "⌫", "KC_DEL": "⌦",
    "KC_LEFT": "←", "KC_RIGHT": "→", "KC_UP": "↑", "KC_DOWN": "↓",
    "KC_PGUP": "PgUp", "KC_PGDN": "PgDn", "KC_HOME": "Home", "KC_END": "End",
    "KC_LEFT_SHIFT": "⇧", "KC_RIGHT_SHIFT": "⇧", "KC_LEFT_GUI": "⌘",
    "KC_BRID": "Bright−", "KC_BRIU": "Bright+", "KC_MCTL": "Mission Ctl",
    "KC_LPAD": "Launchpad", "RM_VALD": "Light−", "RM_VALU": "Light+",
    "KC_MPRV": "⏮", "KC_MPLY": "⏯", "KC_MNXT": "⏭",
    "KC_MUTE": "Mute", "KC_VOLD": "Vol−", "KC_VOLU": "Vol+",
    "MAC_SIRI": "Dictation", "CW_TOGG": "Caps Word",
    "KC_MINUS": "-", "KC_EQUAL": "=", "KC_LBRC": "[", "KC_RBRC": "]",
    "KC_BSLS": "\\", "KC_SCLN": ";", "KC_QUOTE": "'", "KC_GRAVE": "`",
    "KC_COMMA": ",", "KC_DOT": ".", "KC_SLASH": "/",
    "KC_EXLM": "!", "KC_AT": "@", "KC_HASH": "#", "KC_DLR": "$", "KC_PERC": "%",
    "KC_CIRC": "^", "KC_AMPR": "&", "KC_ASTR": "*", "KC_LPRN": "(", "KC_RPRN": ")",
    "KC_UNDS": "_", "KC_PLUS": "+", "KC_LCBR": "{", "KC_RCBR": "}", "KC_PIPE": "|",
    "KC_TILD": "~", "KC_LABK": "<", "KC_RABK": ">",
    "KC_KP_EQUAL": "=", "KC_KP_SLASH": "/", "KC_KP_ASTERISK": "*",
    "KC_KP_MINUS": "−", "KC_KP_PLUS": "+", "KC_KP_DOT": ".",
}

# Characters Markdown would otherwise read as formatting or HTML.
ESCAPES = {"\\": "\\\\", "|": "\\|", "`": "\\`", "*": "\\*", "_": "\\_",
           "~": "\\~", "<": "&lt;", ">": "&gt;"}


def split_args(text):
    args, depth, current = [], 0, ""
    for char in text:
        if char == "," and depth == 0:
            args.append(current.strip())
            current = ""
            continue
        depth += char == "("
        depth -= char == ")"
        current += char
    if current.strip():
        args.append(current.strip())
    return args


def mod_flags(text):
    return "".join(MOD_FLAGS[flag.strip()] for flag in text.split("|"))


def ordered(mods):
    return "".join(m for m in MOD_ORDER if m in mods)


def label(keycode, layer_names):
    if keycode in NAMES:
        return NAMES[keycode]
    if match := re.fullmatch(r"KC_([A-Z])", keycode):
        return match.group(1)
    if match := re.fullmatch(r"KC_(?:KP_)?(\d)", keycode):
        return match.group(1)
    if match := re.fullmatch(r"KC_(F\d+)", keycode):
        return match.group(1)
    if match := re.fullmatch(r"(OSL|TG|TO)\((\w+)\)", keycode):
        kind, layer = match.groups()
        name = layer_names.get(layer, layer).title()
        return {"OSL": name, "TG": f"⇄ {name}", "TO": f"→ {name}"}[kind]
    if match := re.fullmatch(r"OSM\((.+)\)", keycode):
        return f"OS {ordered(mod_flags(match.group(1)))}"
    if match := re.fullmatch(r"MT\((.+?),\s*(\w+)\)", keycode):
        return f"{label(match.group(2), layer_names)} / {ordered(mod_flags(match.group(1)))}"
    if match := re.fullmatch(r"MEH_T\((\w+)\)", keycode):
        return f"{label(match.group(1), layer_names)} / Meh"
    mods = ""
    while match := re.fullmatch(r"(C|A|S|G|LCTL|LALT|LSFT|LGUI)\((.+)\)", keycode):
        mods += MOD_SYMBOLS[match.group(1)]
        keycode = match.group(2)
    if mods:
        return ordered(mods) + label(keycode, layer_names)
    return keycode.removeprefix("KC_")


def cell(text):
    return "".join(ESCAPES.get(char, char) for char in text)


def layer_table(keys, layer_names):
    labels = [cell(label(key, layer_names)) for key in keys]
    header = "| " + " | ".join([""] * 6 + ["│"] + [""] * 6) + " |"
    rule = "|" + "---|" * 13
    rows = [header, rule]
    for row in range(4):
        left = labels[row * 12:row * 12 + 6]
        right = labels[row * 12 + 6:row * 12 + 12]
        rows.append("| " + " | ".join(left + ["│"] + right) + " |")
    thumbs = labels[48:52]
    rows.append("| " + " | ".join([""] * 4 + thumbs[:2] + ["│"] + thumbs[2:] + [""] * 4) + " |")
    return "\n".join(rows)


def main():
    source = KEYMAP.read_text()
    layer_order = re.findall(r"^\s*(\w+),$", re.search(r"enum layers \{(.*?)\};", source, re.S).group(1), re.M)
    layer_names = {name: name for name in layer_order}
    layers = {name: split_args(body)
              for name, body in re.findall(r"\[(\w+)\] = LAYOUT_voyager\((.*?)\n  \)", source, re.S)}
    combo_keys = {name: [k.strip() for k in keys.split(",") if k.strip() != "COMBO_END"]
                  for name, keys in re.findall(r"(combo\d+)\[\] = \{(.*?)\};", source)}
    combos = re.findall(r"COMBO\((combo\d+),\s*(.+?)\),", source)

    print("# Voyager cheat sheet\n")
    print("Modifiers: ⌃ Ctrl, ⌥ Opt, ⇧ Shift, ⌘ Cmd. `X / ⌃` taps X and holds Ctrl. "
          "OS is a one-shot modifier. Layer keys are one-shots: tap for one key, "
          "double-tap to lock, hold for momentary. Blank keys fall through to the layer below.\n")
    for name in layer_order:
        print(f"## {name.title()}\n")
        print(layer_table(layers[name], layer_names) + "\n")
    print("## Combos\n")
    print("| Keys | Output |\n|---|---|")
    for combo, output in combos:
        keys = " + ".join(cell(label(key, layer_names)) for key in combo_keys[combo])
        print(f"| {keys} | {cell(label(output, layer_names))} |")


if __name__ == "__main__":
    main()
