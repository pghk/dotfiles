#!/usr/bin/env zsh
set -o errexit -o nounset -o pipefail -o xtrace

# Installs a nice configuration framework for Zsh

P="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/.zprezto"

if [[ -d ${P} ]]; then
  echo "Prezto is installed!"
  exit 0
fi

git clone --recursive https://github.com/sorin-ionescu/prezto.git ${P}

