#! /usr/bin/env sh

apps=(
  [1039633667]='Irvue'
  [1091189122]='Bear'
  [918858936]='Airmail 3'
  [445189367]='PopClip'
  [1346203938]='OmniFocus'
  [1278508951]='Trello'
  [1384080005]='Tweetbot 3'
  [412736166]='piZZa'
  [585829637]='Todoist'
  [924726344]='Deliveries'
)

for ID in ${!apps[@]}; do
  echo "installing ${apps[$ID]}..." && mas install $ID
done
