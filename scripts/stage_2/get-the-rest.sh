#!/usr/bin/env sh

casks=(
  "atom"
  "backblaze"
  "bartender"
  "daisydisk"
  "evernote"
  "fantastical"
  "firefox"
  "google-chrome"
  "google-drive-file-stream"
  "kaleidoscope"
  "kap"
  "moom"
  "numi"
  "phpstorm"
  "sequel-pro"
  "skitch"
  "slack"
  "sourcetree"
  "spotify"
  "transmit"
  "visual-studio-code"
  "xscope"
  "pallotron-yubiswitch"
  "font-input"
  "font-open-sans"
  "font-roboto"
  "font-firacode-nerd-font"
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
