#!/usr/bin/env sh

casks=(
  "atom"
  "bartender"
  "daisydisk"
  "docker"
  "evernote"
  "fantastical"
  "firefox"
  "firefox-developer-edition"
  "font-firacode-nerd-font"
  "font-input"
  "font-open-sans"
  "font-roboto"
  "google-chrome"
  "hammerspoon"
  "istat-menus"
  "kaleidoscope"
  "kap"
  "karabiner-elements"
  "lando"
  "moom"
  "numi"
  "phpstorm"
  "postman"
  "sequel-pro"
  "skitch"
  "slack"
  "sourcetree"
  "spotify"
  "tableplus"
  "transmit"
  "visual-studio-code"
  "xscope"
  "atom"
)

work_casks=(
  "microsoft-teams"
  "zoomus"
)

if [[ $INSTALL_WORK_APPS == true ]]; then
  for cask in $work_casks; do casks+=$cask; done
fi

formulas=(
  "ack"
  "findutils"
  "gnu-sed --with-default-names"
  "gnupg"
  "go"
  "goaccess"
  "goaccess"
  "grep"
  "gzip"
  "httpie"
  "imagemagick"
  "lftp"
  "moreutils"
  "nmap"
  "node"
  "openssh"
  "pandoc"
  "pyenv"
  "python"
  "redis"
  "rename"
  "screen"
  "sqlite"
  "ssh-copy-id"
  "switchaudio-osx"
  "terminal-notifier"
  "tree"
  "unrar"
  "zopfli"
  "coreutils"
)



# As long as we're not testing...
if [[ ! $CI == true ]]; then

  for formula in ${!formulas[@]}; do
    brew install ${formulas[$formula]}
  done

  for cask in ${!casks[@]}; do
    brew cask install ${casks[$cask]}
  done

  # Docksal
  curl -fsSL https://get.docksal.io | sh

# Don't test installing all of this stuff 
else
  brew install moreutils
fi

# Composer
source ~/.cider/scripts/stage_2/get-composer.sh

# Terminus & Drush
utilpath=~/.utils

if [[ ! -d $utilpath ]]; then
  mkdir $utilpath
fi
cd $utilpath

mkdir terminus drush

cd $utilpath/terminus; composer require pantheon-systems/terminus
cd $utilpath/drush; composer require drush/drush:8.*
cd $utilpath

# Link composer installed binares into part of PATH
for i in $(ls $utilpath); do
  if [[ -f $utilpath/$i/vendor/bin/$i ]]; then
    ln -s $utilpath/$i/vendor/bin/$i /usr/local/bin/
  fi
done
cd