#!/bin/sh

# Terminus
cd ${HOME} && mkdir bin && curl -O https://raw.githubusercontent.com/pantheon-systems/terminus-installer/master/builds/installer.phar && php installer.phar install

# Docksal
#curl -fsSL https://get.docksal.io | sh

# Drush
