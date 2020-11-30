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

zero setup "$@" --directory "$HOME/.dotfiles"