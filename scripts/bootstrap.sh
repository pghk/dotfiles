#!/usr/bin/env sh

logpath=~/.sysinstall.$(date +"%d-%b")
mkdir $logpath

# Record the existing defaults before modifying anything
defaults read > ~/$logpath/initial.defaults

# Load, execute, and log the script which installs and runs Cider
installer=$(curl https://raw.githubusercontent.com/pghk/dotfiles/master/scripts/install.sh)
script $logpath/install.log -c $installer

# Configure zsh, iTerm, and VIM 
script $logpath/shell_setup.log -c ~/.cider/scripts/setup_shell.sh

# Record the modified defaults
defaults read > $logpath/custom.defaults
