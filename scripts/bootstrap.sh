#!/usr/bin/env sh
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
pip install -U --user cider

# Obtain the configuration specs:
git clone https://github.com/pghk/dotfiles.git ~/.cider

# Add a symlink for cider
ln -s ~/Library/Python/2.7/bin/cider /usr/local/bin/cider

# Run Cider to install Homebrew Casks & Formulae, set macOS defaults,  symlink and run additional scripts:
cider restore
