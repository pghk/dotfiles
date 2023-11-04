#!/usr/bin/env zsh
set -o errexit -o nounset -o pipefail -o xtrace

# Installs a command history database, to track exit statuses & path context
DIR="${ZDOTDIR}/zsh-histdb"
if [[ -d $DIR ]]; then
  exit 0
fi
git clone https://github.com/larkery/zsh-histdb $DIR

