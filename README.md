# dotfiles

## Install

### Automated Installation

Run the install script after checking out this repository to automatically
create symlinks.

```sh
$ ./install.sh
```

### Manual File Locations

#### `bin`

All files belong in `$HOME/bin` with the same paths.

#### `cargo`

All files belong in `$HOME/.cargo` with the same paths.

#### `home`

All files and directories belong in `$HOME` with the same paths.

#### `homebrew`

##### `Brewfile`

Run `brew bundle --file=path/to/Brewfile` to configure taps and install
packages. Update with `brew bundle dump --file=path/to/Brewfile --force`.

#### `rbenv`

##### `default-gems`

`$(rbenv root)/default-gems`

#### `ssh`

All files belong in `$HOME/.ssh` with the same paths.

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
