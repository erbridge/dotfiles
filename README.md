# dotfiles

## Install

### Automated Installation

Run the install script after checking out this repository to automatically
create symlinks.

```sh
$ ./install.sh
```

### Manual File Locations

#### `home`

All files belong in `$HOME` with the same paths.

#### `homebrew`

##### `Brewfile`

Run `brew bundle --file=path/to/Brewfile` to configure taps and install
packages. Update with `brew bundle dump --file=path/to/Brewfile --force`.

#### `powerline`

All files belong in `$HOME/.config/powerline` with the same paths.

#### `rbenv`

##### `default-gems`

`$(rbenv root)/default-gems`

#### `vscode`

##### `settings.json`

- macOS: `$HOME/Library/Application Support/Code/User/settings.json`
