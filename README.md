# .files
These are my dotfiles. Take anything you want, but at your own risk.

It's not tested yet, or expected to function. Work in progress and all that.

## Overview
This depends mainly on [Zero.sh](https://github.com/zero-sh/zero.sh) (spiritual successor to [Cider](https://github.com/msanders/cider)), which:
* uses [Homebrew](https://brew.sh/) to install formulae and casks
* uses [mas-cli](https://github.com/mas-cli/mas) to install applications from the Mac App Store
* sets macOS defaults from a YAML
* symlinks configuration files to the home directory

Custom scripts do the following:
* set up a [zsh](http://www.zsh.org/) shell, with the [Prezto](https://github.com/sorin-ionescu/prezto) configuration framework
* use [Mackup](https://github.com/lra/mackup) to sync preferences for a few applications

## Details
[Zero.sh](https://github.com/zero-sh/zero.sh) uses a pre-defined directory structure to support configuration of multiple machines. Each `zero` setup can consist of:
* `Brewfile` -  lists formulae, casks, and App Store apps
* `symlinks` -  folder containing items to be placed in the home directory
* `defaults.yml` - specifies settings to be applied in macOS

When called with no arguments, `zero setup` will read these from the top-level. Additional/separate configs can be stored under the `workspaces/` path.

This project leverages that feature to support my preference of setting up a machine in two phases, by placing configs in both the top-level *and* in separate workspaces.
The idea is that the first phase should be minimal, relatively quick, and contain anything that requires a reboot to take effect. Anything requiring authentication (like the App Store) happens in the second phase, giving me a chance to set up my password manager.

## Install
To get started, clone this repository to ~/.dotfiles, and run the bootstrap script:

```sh
git clone https://github.com/pghk/dotfiles.git ~/.dotfiles
~/.dotfiles/helpers/bootstrap.sh
```

This will install Homebrew & Zero.sh, and then run `zero setup` to apply the top-level configurations, customizing the command-line and macOS user interfaces. 

### Phase Two
To install items from the Mac App Store, and a larger set of Homebrew items, a more specific config can be applied on top of the first phase, with:

```sh
zero setup [home|work]
```

> note: running either the 'home' or 'work' setups will also run the sibling 'shared' setup  

## Helper scripts
Common setup tasks can be performed by running these manually.

* `helpers/dump_brewfile.sh` - calls `brew bundle dump`, adding some line breaks to the output (for readability). Run this in any directory to overwrite the `Brewfile` in that directory, with a list of all currently installed brew formulae, casks, and MAS apps.
* `helpers/dump_macos_settings.sh` - writes the output of `defaults read` to a file named from the current time. Run this before and after changing settings in the UI, then review the diff to discover how you might be able to codify the change.
* `helpers/set_machine_name.sh` - sets `HostName`, `LocalHostName`, and `ComputerName` by calling [scutil](https://ss64.com/osx/scutil.html)
* `helpers/setup_dock.sh` - arranges the items in the macOS dock according to my preference (removes everything, then adds items back in order from a hard-coded bash array)
* `helpers/test`

## Additional resources
* [Awesome Dotfiles](https://github.com/webpro/awesome-dotfiles)
* [Zero.sh](https://github.com/zero-sh/zero.sh) - Radically simple personal bootstrapping tool for macOS
* [Homebrew](http://brew.sh/) / [homebrew-cask](https://github.com/Homebrew/homebrew-cask) - The Missing Package Manager for macOS
* [mas-cli](https://github.com/mas-cli/mas) - Mac App Store command line interface
* [Mackup](https://github.com/lra/mackup) - Keep your application settings in sync
* [Prezto](https://github.com/sorin-ionescu/prezto) - The configuration framework for Zsh
* [Pure](https://github.com/sindresorhus/pure) - Pretty, minimal and fast Zsh prompt
* [ZSH History Database](https://github.com/larkery/zsh-histdb) - A slightly better history for Zsh
* [Hammerspoon](https://www.hammerspoon.org/) - Staggeringly powerful macOS desktop automation with Lua

## Credits
Many thanks to the creators of incredibly useful tools like [Zero.sh](https://github.com/zero-sh/zero.sh), and to [dotfiles community](http://dotfiles.github.io/) in general!
