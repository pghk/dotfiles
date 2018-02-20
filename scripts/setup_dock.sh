#!/bin/bash
#   modified from original by https://discussions.apple.com/people/Hiroto
#    @ https://discussions.apple.com/thread/7538664
#
#   version:
#       0.10
#

apps=(
    "/Applications/Siri.app"
    "/Applications/Firefox.app"
    "/Applications/Airmail 2.app"
    "/Applications/Google Chrome.app"
    "/Applications/Tweetbot.app"
    "/Applications/Bear.app"
    "/Applications/Trello.app"
    "/Applications/OmniFocus.app"
    "/Applications/Photos.app"
    "/Applications/Messages.app"
    "/Applications/Slack.app"
    "/Applications/iTunes.app"
    "/Applications/iTerm.app"
    "/Applications/1Password 6.app"
  )

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

killall Dock
