# dotfiles

[![Build Status](https://img.shields.io/static/v1.svg?label=CSL&message=software%20against%20climate%20change&color=green?style=flat&logo=github)](https://climatestrike.software/)

## Install

### Automated Installation

Run the install script after checking out this repository to automatically
create symlinks.

```sh
$ ./install.sh
```

### Manual File Locations

#### `git`

##### `hooks`

All files belong in `$HOME/.config/git/hooks` with the same names.

##### `template`

All files and directories belong in `$HOME/.config/git/template` with the same
paths. While the template directory can be a symlink, none of its children can.

#### `home`

All files and directories belong in `$HOME` with the same paths.

#### `homebrew`

##### `Brewfile`

Run `brew bundle --file=path/to/Brewfile` to configure taps and install
packages. Update with `brew bundle dump --file=path/to/Brewfile --force`.

#### `powerline`

All files and directories belong in `$HOME/.config/powerline` with the same
paths.

#### `rbenv`

##### `default-gems`

`$(rbenv root)/default-gems`

#### `starship`

All files belong in `$HOME/.config` with the same paths.

#### `vscode`

##### `extention-list`

Run `xargs -n 1 code --install-extension < path/to/extension-list` to install
extensions. Update with `code --list-extensions > path/to/extension-list`.

##### `user`

All files and directories belong in the following directories with the same
paths.

- macOS: `$HOME/Library/Application Support/Code/User`
