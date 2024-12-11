#!/usr/env/bin sh

GITHUB_USER=pghk

sudo apt-get update
sudo apt-get install git zsh sqlite3

chezmoi init --branch develop --apply $GITHUB_USER
