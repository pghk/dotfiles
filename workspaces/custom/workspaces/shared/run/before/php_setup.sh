#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -o xtrace

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

if ! command -v cgr >/dev/null; then
  composer global require consolidation/cgr
  ln -s "$(composer config -g home)/vendor/bin/cgr" /usr/local/bin/
fi

cgr pantheon-systems/terminus

# Link composer installed binaries into part of PATH
CGR_BINS="$(composer config -g home)/vendor/bin"
for i in "$CGR_BINS"/*; do
  ln -s "$i" /usr/local/bin/
done