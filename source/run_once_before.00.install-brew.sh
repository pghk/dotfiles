#!/bin/bash

brew bundle --no-lock --file=/dev/stdin <<EOF
tap "bats-core/bats-core"
# Bash Automated Testing System
brew "bats-core"
# Manage your dotfiles across multiple diverse machines, securely
brew "chezmoi"
# Vi 'workalike' with many additional features
brew "vim"
# Common assertions for Bats
brew "bats-core/bats-core/bats-assert"
# Supporting library for Bats test helpers
brew "bats-core/bats-core/bats-support"
EOF