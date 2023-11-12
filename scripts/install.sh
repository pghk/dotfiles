#!/usr/bin/env bash
set -o errexit -o pipefail -o xtrace

LOG_DIR=${HOME}/.local/share/macos

if [ "${1}" != 'recording' ] && [ ! $CI ]; then
	[[ -d $LOG_DIR ]] || mkdir -p $LOG_DIR
	DATE=$(date +"%F.%H%M")
	exec script "${LOG_DIR}/dotfile_install.${DATE}.txt" ${0} 'recording'
fi

MY_USER=pghk

if [ ! $(type brew &>/dev/null) ] && [ -z $CI ]; then
	if [ -d /opt/homebrew ]; then
		eval $(/opt/homebrew/bin/brew shellenv)
	else
		"Homebrew installation required: see https://brew.sh/ for instructions"
		exit 1
	fi
fi

brew bundle --no-lock --file=/dev/stdin <<-EOF
	brew "chezmoi"
EOF

chezmoi init --verbose --branch next --apply $MY_USER
