#!/usr/bin/env sh

# Install Homebrew
ruby -e "$(
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install
)"

# Install and setup Python
brew install pyenv
pyenv install 3.8.0
pyenv global 3.8.0
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# Install Cider:
pip install -U --user cider

# Replace the emoji font
curl -L https://github.com/emojione/emojione-assets/releases/download/4.5/emojione-mac.ttc\
 -o "${HOME}/Library/Fonts/Apple Color Emoji.ttc"

# Run Cider to install Homebrew Casks & Formulae, set macOS defaults,  symlink and run additional scripts:
cider restore
