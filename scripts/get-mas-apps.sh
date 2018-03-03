#! /usr/bin/env sh

apps=(
  [1039633667]='Irvue'
  [1278508951]='Trello'
  [412736166]='piZZa'
  [585829637]='Todoist'
  [557168941]='Tweetbot'
  [1091189122]='Bear'
  [918858936]='Airmail 2'
  [867299399]='OmniFocus'
  [924726344]='Deliveries'
  [445189367]='PopClip'
  [449589707]='Dash'
)

for ID in ${!apps[@]}; do
  echo "installing ${apps[$ID]}..." && mas install $ID
done
