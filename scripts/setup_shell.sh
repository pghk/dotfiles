#!/usr/bin/env sh

# Add the homebrew-installed zsh to list of shells
sudo sh -c "echo `which zsh` >> /etc/shells"

# Change shell to zsh
sudo chsh -s `which zsh` $USER

# get prezto for zsh config manangement
git clone --recursive https://github.com/sorin-ionescu/prezto.git\
 "${ZDOTDIR:-$HOME}/.zprezto"

# link prezto dotfiles into home directory
for i in $(ls ${ZDOTDIR:-$HOME}/.zprezto/runcoms/); do
  if [[ $i != README.md ]]; then
    ln -s "${ZDOTDIR:-$HOME}/.zprezto/runcoms/$i" "${ZDOTDIR:-$HOME}/.$i"
  fi
done

# customize the zsh config file
cat $HOME/.cider/symlinks/.zshrc > $HOME/.zshrc

# set theme to powerlevel9k, and editor to vi
cat $HOME/.cider/symlinks/.zpreztorc > $HOME/.zpreztorc

# set vim config
cp $HOME/.cider/symlinks/.vimrc $HOME/

# add colorscheme, status bar, and language packs using vim 8's package loader
plugin_path="$HOME/.vim/pack/default/start"

plugins=(
  "trevordmiller/nova-vim"
  "vim-airline/vim-airline"
  "sheerun/vim-polyglot"
)

mkdir -p $plugin_path && cd $plugin_path
for i in ${plugins[@]}; do
  git clone https://github.com/$i
done
cd
