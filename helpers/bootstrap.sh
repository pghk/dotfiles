#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -o xtrace

# Installs Homebrew, Casks & Formulae
# Symlinks config files, Runs setup scripts, Sets macOS defaults
# With help from https://github.com/zero-sh/zero.sh

HOMEBREW_URL="https://raw.githubusercontent.com/Homebrew/install/master/install.sh"

if ! command -v brew >/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL $HOMEBREW_URL)"
fi

export PATH="/usr/local/bin:$PATH"

if ! command -v zero >/dev/null; then
    echo "Installing Zero..."
    brew install zero-sh/tap/zero
fi

if $CI; then
    xcode-select --install
    softwareupdate -i "Command Line Tools for Xcode-14.2" 
    brew config
    zero bundle init
    zero apply-defaults init
    zero apply-symlinks init
    zero run-scripts init
fi

if ! $CI; then
    zero setup init
fi
