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
cat ~/.cider/symlinks/.zshrc > ~/.zshrc

# set theme to powerlevel9k, and editor to vi
cat ~/.cider/symlinks/.zpreztorc > ~/.zpreztorc

# install powerline
pip install --user powerline-status

# set vim config
cp ~/.cider/symlinks/.vimrc ~/

# get colorscheme
mkdir -p ~/.vim/colors
wget https://raw.githubusercontent.com/mhartington/oceanic-next/master/colors/\
  OceanicNext.vim -O ~/.vim/colors/OceanicNext.vim
