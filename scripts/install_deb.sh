#!/usr/env/bin sh

GITHUB_USER=pghk

sudo apt-get update
sudo apt-get install git

chezmoi init --branch develop --apply $GITHUB_USER
