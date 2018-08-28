#!/usr/bin/env sh

casks=(
  "atom"
  "bartender"
  "moom"
  "google-chrome"
  "visual-studio-code"
  "kaleidoscope"
  "evernote"
  "fantastical"
  "istat-menus"
  "karabiner-elements"
  "sequel-pro"
  "sourcetree"
  "transmit"
  "slack"
  "kap"
  "numi"
  "skitch"
  "xscope"
  "font-input"
  "font-open-sans"
  "font-roboto"
  "font-firacode-nerd-font"
  "firefox"
  "google-drive-file-stream"
  "phpstorm"
  "spotify"
  "pallotron-yubiswitch"
  "backblaze"
  "daisydisk"
)

formulas=(
  "coreutils"
  "moreutils"
  "findutils"
  "gnu-sed --with-default-names"
  "wget --with-iri"
  "gnupg"
  "grep"
  "ack"
  "openssh"
  "unrar"
  "rename"
  "pandoc"
  "ssh-copy-id"
  "tree"
  "screen"
  "imagemagick"
  "gzip"
  "zopfli"
  "lftp"
  "goaccess"
  "terminal-notifier"
  "node"
  "go"
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

composer require pantheon-systems/terminus
composer require require drush/drush:8.*

export PATH="$utilpath/vendor/bin:$PATH"
cd