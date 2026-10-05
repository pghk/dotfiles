---
name: zed
description: >
  Zed editor configuration: keymap actions, settings, and config validation.
  Use when editing keymap.json or settings.json for Zed, looking up valid
  action names, or debugging keymap binding errors.
---

## Keymap action names

Never guess or infer action names from patterns, conventions, or web search
summaries. Always fetch the authoritative list before writing any action name:

  https://zed.dev/docs/all-actions

Web search summaries are unreliable for exact names — they have produced wrong
names in the past (e.g. `ActivatePrevItem` instead of `ActivatePreviousItem`).
Only the fetched page is reliable.

## Action name format

Zed actions use PascalCase with a `namespace::` prefix, e.g.:

```
pane::ActivateNextItem
pane::ActivatePreviousItem
editor::MoveLineDown
workspace::ActivatePaneRight
```

## Validating changes

Zed watches config files and reloads them live. Keymap errors appear as UI
notifications — they are not written to the log file at `~/Library/Logs/Zed/Zed.log`.

There is no headless/CLI mode for validating config. The authoritative action
list at the URL above is the only way to verify action names without running Zed.
