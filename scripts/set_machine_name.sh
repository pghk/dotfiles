#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -o xtrace

read -p "Change the hostname, etc of this machine? " -r
if [[ $REPLY =~ ^((yes|Yes)|(y|Y))$ ]]; then
	read -p "Give me a name: " -r name

	echo "Setting Computer Name"
	scutil --set ComputerName "$name"
	echo "Setting Local Host Name"
	scutil --set LocalHostName "$name"
	echo "Setting Host Name"
	scutil --set HostName "$name"

	dscacheutil -flushcache
	echo "Hi, my name is $name!"
else
	echo "Renaming cancelled"
	exit 0
fi
