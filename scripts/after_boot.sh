#!/usr/bin/env sh

logpath=~/.sysinstall.$(date +"%d-%b")
if [[ ! -d $logpath ]]; then
  mkdir $logpath
fi

script $logpath/mackup_install.log sh -x $(pip3 install mackup)

script $logpath/app_store.log sh -x ~/.cider/scripts/stage_2/get-mas-apps.sh

script $logpath/more_homebrew.log sh -x ~/.cider/scripts/stage_2/get-the-rest.sh