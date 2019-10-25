#!/usr/bin/env sh

# Install Homebrew
ruby -e "$(
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install
)"

# Install Cider:
pip install -U --user cider

# Add a symlink for cider
ln -s ~/Library/Python/2.7/bin/cider /usr/local/bin/cider

# Replace the emoji font
curl -L https://github.com/emojione/emojione-assets/releases/download/4.5/emojione-mac.ttc\
 -o "${HOME}/Library/Fonts/Apple Color Emoji.ttc"

# Run Cider to install Homebrew Casks & Formulae, set macOS defaults,  symlink and run additional scripts:
cider restore
