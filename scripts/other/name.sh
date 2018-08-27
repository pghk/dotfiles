#!/usr/bin/env sh

read -p "Change the hostname, etc of this machine? " -r
if [[ $REPLY =~ ^((yes|Yes)|(y|Y))$ ]]; then
  read -p "Give me a name: " name

  echo "Setting Computer Name"
  #sudo scutil --set ComputerName $name
  echo "Setting Local Host Name"
  #sudo scutil --set LocalHostName $name
  echo "Setting Host Name"
  #sudo scutil --set HostName $name

  dscacheutil -flushcache
  echo "Hi, my name is $name!"
else
  echo "Renaming cancelled"
  exit 0
fi
