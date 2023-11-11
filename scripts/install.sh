#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -o xtrace

LOG_DIR=${HOME}/.local/share/macos

if [ "${1:-''}" != 'recording' ]; then
	[[ -d $LOG_DIR ]] || mkdir -p $LOG_DIR
	DATE=$(date +"%F.%H%M")
	exec script "${LOG_DIR}/dotfile_install.${DATE}.txt" ${0} 'recording'
fi

MY_USER=pghk

if [ ! command -v brew ] && [ -z $CI ]; then
	"Homebrew installation required: see https://brew.sh/ for instructions"
	exit 1
fi

brew bundle --no-lock --file=/dev/stdin <<-EOF
	brew "chezmoi"
EOF

chezmoi init --verbose --branch next --apply $MY_USER
