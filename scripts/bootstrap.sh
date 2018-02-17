#!/bin/sh
set -x

# Update macOS, and enable the command line dev tools:
sudo softwareupdate -i -a
xcode-select --install

# Install Homebrew
ruby -e "$(
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install
)"

# Install Cider:
sudo easy_install pip
pip install -U cider

# Obtain the configuration specs:
git clone https://github.com/pghk/dotfiles.git ~/.cider

# Run Cider to install Homebrew Casks & Formulae, set macOS defaults,  symlink and run additional scripts:
cider restore
