#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -o xtrace

MY_USER=pghk

HOST=raw.githubusercontent.com
PROJECT=twpayne/chezmoi

CURRENT=master
KNOWN=3f636c1b30686c84c524722dbd0b0ce9a0953fb9
EXPECT=078b3c19ba5146d669e63b5387b5e11f2796a8f0785f776ea01813424408657e

FILE_PATH=assets/scripts
INSTALL=install.sh

trap "[[ ! -f $INSTALL ]] || rm $INSTALL" EXIT
trap 'exit' INT TERM

url() {
	echo https://${HOST}/${PROJECT}/${1}/${FILE_PATH}/${INSTALL}
}

curl -s $(url $CURRENT) >$INSTALL
SHA=$(openssl sha256 $INSTALL | cut -d '=' -f 2)

if [ $SHA != $EXPECT ]; then
	echo "${INSTALL} doesn't match last reviewed version. Compare with " \
		"$(url $KNOWN)"
	exit
fi

chezmoi_args=(init --verbose "--branch next" "--apply $MY_USER")

chmod 770 $INSTALL
./$INSTALL -b /usr/local/bin -- ${chezmoi_args[@]}
