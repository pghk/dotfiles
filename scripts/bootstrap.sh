#!/usr/bin/env sh
set -x

# Record the existing defaults before modifying anything
defaults read > ~/.$(date +"%d-%b").initial.defaults

# Install Homebrew
ruby -e "$(
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install
)"

# Install Cider:
sudo easy_install pip
pip install -U --user cider

# Obtain the configuration specs:
git clone https://github.com/pghk/dotfiles.git ~/.cider

# Add a symlink for cider
ln -s ~/Library/Python/2.7/bin/cider /usr/local/bin/cider

# Replace the emoji font
curl https://github.com/emojione/emojione-assets/releases/download/3.1.2/emojione-apple.ttc\
 -o "${HOME}/Library/Fonts/Apple Color Emoji.ttc"

# Run Cider to install Homebrew Casks & Formulae, set macOS defaults,  symlink and run additional scripts:
cider restore
