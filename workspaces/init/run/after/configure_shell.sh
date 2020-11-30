#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -o xtrace

# Fill in any Prezto configs that haven't already been overridden
for rcfile in "$HOME"/.zprezto/runcoms/*; do
  if [[ ! -f "$HOME/.$(basename "$rcfile")" && $(basename "$rcfile") != README.md ]]; then
    ln -s "$rcfile" "$HOME/.$(basename "$rcfile")"
  fi
done

# Load custom preferences into iTerm
defaults write com.googlecode.iterm2 PrefsCustomFolder ~/.iterm
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder 1
