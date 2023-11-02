#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -o xtrace

# Z-shell: rhymes with seashell
ZSH_FROM_HOMEBREW="$(command -v zsh)"
sudo sh -c "echo $ZSH_FROM_HOMEBREW >> /etc/shells"
sudo chsh -s "$ZSH_FROM_HOMEBREW" "$USER"

# Prezto: Zsh config management
git clone --recursive https://github.com/sorin-ionescu/prezto.git "$HOME/.zprezto"

if [ ! -d "$HOME/.zsh_plugins/" ]; then
  mkdir -p "$HOME/.zsh_plugins/"
fi

# History Database: records more info on issued commands, like exit statuses and working directories
git clone https://github.com/larkery/zsh-histdb "$HOME/.zsh_plugins/zsh-histdb"

# Vim plugins: colorscheme, status bar, language support (syntax highlighting etc)
plugin_path="$HOME/.vim/pack/default/start"

plugins=(
  "catppuccin/vim"
  "vim-airline/vim-airline"
  "sheerun/vim-polyglot"
)

mkdir -p "$plugin_path" && cd "$plugin_path" || return
for i in "${plugins[@]}"; do
  git clone "https://github.com/$i"
done

cd || return

