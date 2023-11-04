#!/usr/bin/env zsh
set -o errexit -o nounset -o pipefail -o xtrace

# Adds plugins to Vim for colorscheme, status bar, and language support

DIR="$HOME/.vim/pack/default/start"
mkdir -p "$DIR"

plugins=(
  "catppuccin/vim"
  "vim-airline/vim-airline"
  "sheerun/vim-polyglot"
)

for i in "${plugins[@]}"; do
  [[ -d "${DIR}/${i}"]] || git clone "https://github.com/$i"
done

