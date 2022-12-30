#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -o xtrace

brew install php

install_composer () {
  EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

  if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
  then
      >&2 echo 'ERROR: Invalid installer signature'
      rm composer-setup.php
      exit 1
  fi

  php composer-setup.php --install-dir=/usr/local/bin/ --filename=composer
  rm composer-setup.php
}

if ! command -v composer >/dev/null; then
  install_composer
fi

put_composer_bins_in_path () {
  CGR_BINS="$(composer config -g home)/vendor/bin"
  for i in "$CGR_BINS"/*; do
    if [[ ! -e "/usr/local/bin/$(basename "$i")" ]]; then
      ln -s "$i" /usr/local/bin/
    fi
  done
}

composer global require pantheon-systems/terminus

put_composer_bins_in_path

