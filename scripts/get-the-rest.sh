#!/usr/bin/env sh

casks=(
  "atom"
  "backblaze"
  "bartender"
  "daisydisk"
  "deluge"
  "evernote"
  "fantastical"
  "firefox"
  "flux"
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
  "textexpander"
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
  "terminus"
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
  "jq"
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

for formula in ${!formulas[@]}; do
  brew install ${formulas[$formula]}
done

for cask in ${!casks[@]}; do
  brew cask install ${casks[$cask]}
done

# Docksal
curl -fsSL https://get.docksal.io | sh

# Drush
