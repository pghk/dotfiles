# .files
These are the scripts and configuration files that I use
to set up a computer the way I like to do

[![Codemagic build
status](https://api.codemagic.io/apps/63ae1772bef3ad2397a807c8/new-macos-setup/status_badge.svg)](https://codemagic.io/apps/63ae1772bef3ad2397a807c8/new-macos-setup/latest_build)

## Overview
The underlying framework here is provided by
[chezmoi](https://www.chezmoi.io/), which allows me to manage
multiple versions of the setup, by using templates. 

Some highlights:

- custom [window management
functions](https://github.com/pghk/dotfiles/blob/develop/source/dot_hammerspoon/grid.lua),
written for Hammerspoon
- command line
[auto-completion](https://github.com/pghk/dotfiles/blob/e9baf95f3a3caba4d10a374a5fa3291a545f5a23/source/private_dot_config/zsh/dot_zshrc#L18)
which first suggests previously successful commands (prioritizing
those run in the current directory), before falling back to
standard options ([
zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions),
[ZSH History Database](https://github.com/larkery/zsh-histdb),
[zsh-completions](https://github.com/zsh-users/zsh-completions))
- a script that moves to the trash anything in the ~/Downloads
folder older than 30 days. Once a crontab one-liner, now a .plist
for `launchd` that I wrapped in an Applescript "app" just so it
could have a custom icon in the preferences pane, which now seems
to have the generic script icon anyway
- a Brewfile composed of separate profiles for first-boot (no
service dependencies), long-term (connected to password
management and cloud storage), personal and work, used to install
apps with
[homebrew-bundle](https://github.com/Homebrew/homebrew-bundle)
and [mas-cli](https://github.com/mas-cli/mas)

## Usage
1. Step through the initial macOS setup dialog, skipping
everything that's optional
2. Open the Terminal app and run `xcode-select --install`
3. Open Safari to https://brew.sh and download the `.pkg` asset
for the latest release (i.e.
[4.1.20](https://github.com/Homebrew/brew/releases/tag/4.1.20))
4. System settings > Privacy & Security > Full Disk Access > Add
Utilities/Terminal (in order to be able to set macOS settings
later via the `defaults` command)
5. `curl https://raw.githubusercontent.com/pghk/dotfiles/develop/scripts/install.sh > setup.sh`
and run it
7. Answer prompts from install script, choosing the profile `init`
8. Wait for software to be installed and macOS settings to be
applied, then reboot
9. Start [Kitty](https://sw.kovidgoyal.net/kitty/), Karabiner,
Hammerspoon
10. `dot init` - answer prompts again, choosing the profile
`(personal|work)`
12. Sign in to iCloud etc
13. `dot apply` to install more software
14. Start Alfred, Bartender, iStat menus
15. [Erase everything](https://support.apple.com/en-us/HT212749)
and start over
16. Repeat 7 to 26 more times, performing experiments, taking
notes and making small tweaks along the way until the process
actually goes smoothly
17. Plug in your backup drive and copy over everything you can't
remember if it's important or not
18. `defaults write com.apple.menuextra.clock IsAnalog -bool
true`

## Helper scripts
Common setup tasks can be performed by running
these manually: 

* `dump_macos_settings.sh` - writes the output of `defaults read`
to a file named from the current time. Run this before and after
changing settings in the UI, then review the diff to discover how
you might be able to codify the change
* `set_machine_name.sh` - sets `HostName`, `LocalHostName`, and
`ComputerName` by calling
[scutil](https://ss64.com/osx/scutil.html)
* `setup_dock.sh` - arranges the items in the macOS dock by
removing everything and then putting back the listed items
* `test.bats` - asserts in CI that this tool works properly

## Additional resources
* [chezmoi](https://www.chezmoi.io/) - Manage your dotfiles
across multiple diverse machines, securely.
* [Awesome Dotfiles](https://github.com/webpro/awesome-dotfiles)
* [Homebrew](http://brew.sh/) /
[homebrew-cask](https://github.com/Homebrew/homebrew-cask) - The
Missing Package Manager for macOS
* [mas-cli](https://github.com/mas-cli/mas) - Mac App Store
command line interface
* [Mackup](https://github.com/lra/mackup) - Keep your application
settings in sync. I'm not actually using this right now, but it's
a good resource for finding out where apps store their
preferences
* [Prezto](https://github.com/sorin-ionescu/prezto) - The
configuration framework for Zsh
* [ZSH History Database](https://github.com/larkery/zsh-histdb) -
A slightly better history for Zsh
* [Hammerspoon](https://www.hammerspoon.org/) - Staggeringly
powerful macOS desktop automation with Lua

