# .files
These are my dotfiles. Take anything you want, but at your own risk.

[![Codemagic build status](https://api.codemagic.io/apps/63ae1772bef3ad2397a807c8/new-macos-setup/status_badge.svg)](https://codemagic.io/apps/63ae1772bef3ad2397a807c8/new-macos-setup/latest_build)

## Overview
This depends mainly on [Zero.sh](https://github.com/zero-sh/zero.sh), which takes the following (in a pre-defined directory structure, to support multiple configurations):
* a `Brewfile`, which [homebrew-bundle](https://github.com/Homebrew/homebrew-bundle) uses to install:
    * [Homebrew](https://brew.sh/) formulae & casks
    * Applications from the Mac App Store, via [mas-cli](https://github.com/mas-cli/mas)
* a `defaults.yaml` file, defining a macOS UI configuration
* a `symlinks` folder, containing any items to be placed in the home directory

Other custom scripts include:
* setting up a [zsh](https://en.wikipedia.org/wiki/Z_shell) shell, with the [Prezto](https://github.com/sorin-ionescu/prezto) configuration framework
* using [Mackup](https://github.com/lra/mackup) to sync preferences for a few applications

## Details
I like to set up a machine in two phases:
1. Steps that add value quickly, or necessitate a reboot (i.e. tap-to-click, iTerm setup, password manager)
2. Steps that take time, aren't needed right away, or require authentication (i.e. anything from the App Store)

To support this, the workspaces that `zero` applies live in two groups:
* `workspaces/init` - for the first phase
* `workspaces/custom/workspaces` - for various second-phase options

## Install
To get started, clone this repository to ~/.dotfiles, and run the bootstrap script:

```sh
git clone https://github.com/pghk/dotfiles.git ~/.dotfiles
~/.dotfiles/helpers/bootstrap.sh
```

This will install Homebrew & Zero.sh, and then run `zero setup init` to customize the command-line and macOS user interfaces, and install essential apps.

```
workspaces/init
├── Brewfile
├── defaults.yaml
├── run
│   ├── after
│       ├── configure_shell.sh
│   └── before
│       ├── php_setup.sh
│       └── setup_shell.sh
└── symlinks
    ├── git
    ├── hammerspoon
    ├── iterm
    ├── mackup
    ├── vim
    └── zsh
```

### More install
The optional second phase can be run manually with `zero setup custom.[home|work]`, either of which will also apply the sibling `shared` workspace.

```
workspaces/custom/workspaces
├── home
│   └── Brewfile
├── shared
│   ├── Brewfile
└── work
    └── Brewfile
```

## Helper scripts
Common setup tasks can be performed by running these manually.

* `helpers/dump_brewfile.sh` - calls `brew bundle dump`, adding some line breaks to the output (for readability). Run this in any directory to overwrite the `Brewfile` in that directory, with a list of all currently installed brew formulae, casks, and MAS apps.
* `helpers/dump_macos_settings.sh` - writes the output of `defaults read` to a file named from the current time. Run this before and after changing settings in the UI, then review the diff to discover how you might be able to codify the change.
* `helpers/set_machine_name.sh` - sets `HostName`, `LocalHostName`, and `ComputerName` by calling [scutil](https://ss64.com/osx/scutil.html)
* `helpers/setup_dock.sh` - arranges the items in the macOS dock according to my preference (removes everything, then adds items back in order from a hard-coded bash array).
* `helpers/test.bats` - asserts in CI that this tool works properly.

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
