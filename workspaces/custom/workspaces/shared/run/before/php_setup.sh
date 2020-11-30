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

put_composer_bins_in_path () {
  CGR_BINS="$(composer config -g home)/vendor/bin"
  for i in "$CGR_BINS"/*; do
    if [[ ! -e "/usr/local/bin/$(basename "$i")" ]]; then
      ln -s "$i" /usr/local/bin/
    fi
  done
}

# Install consolidation/cgr: a safer alternative to `composer global require`
if ! command -v cgr >/dev/null; then
  composer global require consolidation/cgr
  put_composer_bins_in_path
fi

# Install all other composer packages using cgr
cgr pantheon-systems/terminus
cgr drupal/coder

put_composer_bins_in_path

# Register Drupal coding standard with PHPCS tool
if (command -v phpcs >/dev/null && [[ -f ~/.composer/global/drupal/coder/coder_sniffer ]]); then
  phpcs --config-set installed_paths ~/.composer/global/drupal/coder/coder_sniffer
  phpcs -i
fi