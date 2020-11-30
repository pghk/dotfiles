#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -o xtrace

# Overwrite the existing file
brew bundle dump --describe --force

# Add line breaks for readability. Before each comment,
< Brewfile sed '/^#/{x;p;x;}' |\
  # before the cask section,
  awk '{if ($0 ~ /^cask/ && n++ == 0) print "\n" $0; else print $0}' |\
  # before the app store section
  awk '{if ($0 ~ /^mas/ && n++ == 0) print "\n" $0; else print $0}' \
> temp

mv temp Brewfile