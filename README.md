# .files
These are my dotfiles. Take anything you want, but at your own risk.

It's not tested yet, or expected to function. Work in progress and all that.

The framework here is provided by [Cider](https://github.com/msanders/cider), which brings with it the benefit of setting macOS defaults from a YAML. Cider also handles installing formulae and casks from [Homebrew](https://brew.sh/).

We'll also download some things from the App Store using [mas-cli](https://github.com/mas-cli/mas), and sync a few application preferences with [Mackup](https://github.com/lra/mackup). We'll set [zsh](http://www.zsh.org/) as the shell, and bring in my custom [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) theme.

## Package overview
I think I'm including some of these

* Core
    * Bash + [coreutils](http://en.wikipedia.org/wiki/GNU_Core_Utilities) + bash-completion
    * [Homebrew](http://brew.sh/), [homebrew-cask](http://caskroom.io/)
    * Node.js + npm
    * GNU [sed](http://www.gnu.org/software/sed/), [grep](https://www.gnu.org/software/grep/), [Wget](https://www.gnu.org/software/wget/)
    * [fasd](https://github.com/clvv/fasd), [psgrep](https://github.com/jvz/psgrep/blob/master/psgrep), [pgrep](http://linux.die.net/man/1/pgrep), [tree](http://mama.indstate.edu/users/ice/tree/)
    * Git + [SourceTree](http://www.sourcetreeapp.com)
    * [rvm](https://rvm.io/) (Ruby 2.1)
    * Python 2
* Dev (FE/JS/JSON): [jq](http://stedolan.github.io/jq/)
* Graphics: [imagemagick](http://www.imagemagick.org)
* OS X: [dockutil](https://github.com/kcrawford/dockutil), [Mackup](https://github.com/lra/mackup), [Quick Look plugins](https://github.com/sindresorhus/quick-look-plugins)
* [OS X apps](https://github.com/webpro/dotfiles/blob/master/install/brew-cask.sh)

## Install

Download [bootstrap.sh](https://github.com/pghk/dotfiles/raw/master/scripts/bootstrap.sh) to desktop, and run it:

```sh
~/Desktop/bootstrap.sh | tee -a sysinstall.$(date +"%d-%b").log
```

This will update macOS, install xcode, Homebrew, and Cider, clone this repository to ~/.cider, then run Cider, which will:

- Install casks and formulae from Homebrew
  - write default settings to macOS
  - symlink some configurations
  - then kick off additional scripts to:
    - Get apps from the App Store
    - Install additional tools like Composer

## Additional resources
* [Awesome Dotfiles](https://github.com/webpro/awesome-dotfiles)
* [Homebrew](http://brew.sh/) / [FAQ](https://github.com/Homebrew/homebrew/wiki/FAQ)
* [homebrew-cask](http://caskroom.io/) / [usage](https://github.com/phinze/homebrew-cask/blob/master/USAGE.md)

## Credits
Many thanks to the [dotfiles community](http://dotfiles.github.io/) and the creators of the incredibly useful tools.
