#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail -o xtrace

#   modified from original by https://discussions.apple.com/people/Hiroto
#    @ https://discussions.apple.com/thread/7538664

apps=(
    "/System/Applications/Messages.app"
    "/System/Applications/Mail.app"
    "/System/Applications/Photos.app"
    "/Applications/Fantastical.app"
    "/System/Applications/Contacts.app"
    "/System/Applications/Reminders.app"
    "/Applications/Arc.app"
    "/System/Applications/Music.app"
    "$HOME/Applications/IntelliJ IDEA Ultimate.app"
    "/Applications/Mona.app"
    "/Applications/Anybox.app"
    "/Applications/kitty.app"
 )

read -p "This will wipe out your existing dock. Continue? " -r
if [[ $REPLY =~ ^((yes|Yes)|(y|Y))$ ]]
  then
  # Backup the existing dock
  defaults read com.apple.dock persistent-apps > ~/Desktop/previous.dock.defaults
  # Wipe out the existing dock
  defaults write com.apple.dock persistent-apps -array

  shopt -s extglob
  for f in "${apps[@]}"
  do
      f=${f/%+(\/)}/                              # normalise bundle path so that it ends with /
      fq=$(sed 's/[^[:alnum:]]/\\&/g' <<< "$f")   # quote meta characters for regex

      [[ -n $(defaults read com.apple.dock persistent-apps |
          sed -En "s/\"_CFURLString\" = \"?($fq)\"?;/\1/p" ) ]] && continue   # already exists

      defaults write com.apple.dock persistent-apps -array-add "
  <dict>
      <key>tile-data</key>
      <dict>
          <key>file-data</key>
          <dict>
              <key>_CFURLString</key>
              <string>${f}</string>
              <key>_CFURLStringType</key>
              <integer>0</integer>
          </dict>
      </dict>
  </dict>
  "
  done

  printf "Restarting dock... "
  killall Dock
  echo 'done'
  exit 0
fi

echo "Dock setup cancelled."
exit 1
