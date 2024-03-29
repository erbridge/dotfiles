#!/bin/bash
set -e
shopt -s dotglob

if ! command -v perl >/dev/null 2>&1; then
  echo "Perl is required to run this script. Install it and try again."
  exit 1
fi

SCRIPT_PATH=$(
  cd "$(dirname "$0")"
  pwd -L
)

function relpath {
  local path=$1
  local base=$2

  perl -MFile::Spec -e 'print File::Spec->abs2rel(@ARGV)' "$path" "$base"
}

function for-each-file-in {
  local dir=$1
  shift

  for path in "$dir"/*; do
    if ! [ -e "$path" ]; then
      continue
    fi

    if [ -d "$path" ]; then
      for-each-file-in "$path" "$@"
    elif [ -f "$path" ]; then
      "$@" "$path"
    fi
  done
}

function check-symlink-parent-conflict {
  local target_path
  local target_dir=$1
  local source_path=$2
  local source_dirname

  source_dirname=$(basename "$source_path")
  target_path=$target_dir/$source_dirname

  if [ -L "$target_path" ]; then
    echo "$target_path is a symlink."
    FOUND_CONFLICT=1
  elif [ -f "$target_path" ]; then
    echo "$target_path is a file."
    FOUND_CONFLICT=1
  fi
}

function check-symlink-file-conflict {
  local target_path
  local target_dir=$1
  local source_root=$2
  local source_path=$3
  local source_relpath

  source_relpath=$(relpath "$source_path" "$source_root")
  target_path=$target_dir/$source_relpath

  if [ -L "$target_path" ]; then
    echo "$target_path is a symlink."
    FOUND_CONFLICT=1
  elif [ -f "$target_path" ]; then
    echo "$target_path is a file."
    FOUND_CONFLICT=1
  elif [ -d "$target_path" ]; then
    echo "$target_path is a directory."
    FOUND_CONFLICT=1
  fi
}

function check-symlink-dir-conflict {
  local target_path=$1

  if [ -L "$target_path" ]; then
    echo "$target_path is a symlink."
    FOUND_CONFLICT=1
  elif [ -f "$target_path" ]; then
    echo "$target_path is a file."
    FOUND_CONFLICT=1
  elif [ -d "$target_path" ]; then
    echo "$target_path is a directory."
    FOUND_CONFLICT=1
  fi
}

function symlink-dir {
  local target_path=$1
  local target_dir
  local source_path=$2
  local source_dir

  target_dir=$(dirname "$target_path")
  source_dir=$(dirname "$source_path")

  mkdir -p "$target_dir"
  ln -sniFv "$source_path" "$target_path" || true
}

function symlink-file {
  local target_path
  local target_dir=$1
  local source_root=$2
  local source_path=$3
  local source_relpath

  source_relpath=$(relpath "$source_path" "$source_root")
  target_path=$target_dir/$source_relpath

  mkdir -p "$(dirname "$target_path")"
  ln -siFv "$source_path" "$target_path" || true
}

function make-dir-symlink {
  local source_dir
  local source_dirname=$1
  local target_dir=$2

  source_dir=$SCRIPT_PATH/$source_dirname

  echo "Symlinking $source_dirname to $target_dir..."
  echo "Checking for possible conflicts..."
  echo

  if [ -d "$target_dir" ] && ! [ -L "$target_dir" ]; then
    echo "The target directory $target_dir is already a directory. Skipping."
  else
    FOUND_CONFLICT=
    check-symlink-dir-conflict "$target_dir"

    if [ "$FOUND_CONFLICT" ]; then
      echo

      while true; do
        local create_symlinks=
        read -rp "Do you want to attempt to overwrite the above with a symlink to dotfiles? [y/N] " create_symlinks

        if [ "$create_symlinks" = "y" ] || [ "$create_symlinks" = "Y" ]; then
          echo
          echo "Creating directory symlink..."
          echo

          symlink-dir "$target_dir" "$source_dir"

          break
        elif ! [ "$create_symlinks" ] || [ "$create_symlinks" = "n" ] || [ "$create_symlinks" = "N" ]; then
          break
        fi
      done
    else
      echo "No conflicts found. Creating directory symlink..."
      echo

      symlink-dir "$target_dir" "$source_dir"
    fi
  fi

  echo
}

function make-file-symlinks {
  local source_dir
  local source_dirname=$1
  local target_dir=$2

  source_dir=$SCRIPT_PATH/$source_dirname

  echo "Symlinking $source_dirname files to $target_dir..."
  echo "Checking for possible conflicts..."
  echo

  FOUND_CONFLICT=
  check-symlink-parent-conflict "$target_dir" "$source_dir"

  if [ "$FOUND_CONFLICT" ]; then
    echo "The target directory $target_dir is a file or is already a symlink. Skipping."
  else
    FOUND_CONFLICT=
    for-each-file-in "$source_dir" check-symlink-file-conflict "$target_dir" "$source_dir"

    if [ "$FOUND_CONFLICT" ]; then
      echo

      while true; do
        local create_symlinks=
        read -rp "Do you want to attempt to overwrite the above with symlinks to dotfiles? [y/N] " create_symlinks

        if [ "$create_symlinks" = "y" ] || [ "$create_symlinks" = "Y" ]; then
          echo
          echo "Creating symlinks..."
          echo

          for-each-file-in "$source_dir" symlink-file "$target_dir" "$source_dir"

          break
        elif ! [ "$create_symlinks" ] || [ "$create_symlinks" = "n" ] || [ "$create_symlinks" = "N" ]; then
          break
        fi
      done
    else
      echo "No conflicts found. Creating symlinks..."
      echo

      for-each-file-in "$source_dir" symlink-file "$target_dir" "$source_dir"
    fi
  fi

  echo
}

while true; do
  INSTALL_PACKAGES=
  read -rp "Do you want to install packages from dotfiles? [y/N] " INSTALL_PACKAGES

  if [ "$INSTALL_PACKAGES" = "y" ] || [ "$INSTALL_PACKAGES" = "Y" ]; then
    if [[ "$(uname -s)" == "Darwin" ]]; then
      if ! command -v brew >/dev/null 2>&1; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi

      eval "$(brew shellenv)"
      FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

      brew bundle install --file="$SCRIPT_PATH/homebrew/Brewfile" --no-lock --verbose
    fi

    break
  elif ! [ "$INSTALL_PACKAGES" ] || [ "$INSTALL_PACKAGES" = "n" ] || [ "$INSTALL_PACKAGES" = "N" ]; then
    break
  fi
done

make-file-symlinks home "$HOME"
make-file-symlinks bin "$HOME/bin"
make-file-symlinks bundle "$HOME/.bundle"
make-file-symlinks cargo "$HOME/.cargo"
make-file-symlinks ssh "$HOME/.ssh"
make-file-symlinks ssh/config.d "$HOME/.ssh/config.d"
make-file-symlinks starship "$HOME/.config"

if command -v code >/dev/null 2>&1; then
  while true; do
    INSTALL_PACKAGES=
    read -rp "Do you want to install VSCode extensions from dotfiles? [y/N] " INSTALL_PACKAGES

    if [ "$INSTALL_PACKAGES" = "y" ] || [ "$INSTALL_PACKAGES" = "Y" ]; then
      xargs -n 1 code --install-extension <"$SCRIPT_PATH/vscode/extension-list"

      break
    elif ! [ "$INSTALL_PACKAGES" ] || [ "$INSTALL_PACKAGES" = "n" ] || [ "$INSTALL_PACKAGES" = "N" ]; then
      break
    fi
  done
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  make-file-symlinks vscode/user "$HOME/Library/Application Support/Code/User"
fi

if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init -)"

  make-file-symlinks rbenv "$(rbenv root)"
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  echo "Now set up Raycast and iTerm and you're done!"
  echo
  echo "Raycast's settings are here:"
  echo "  $SCRIPT_PATH/raycast"
  echo
  echo "In Raycast:"
  echo "  Import Preferences & Data"
  echo
  echo "iTerm's preferences are here:"
  echo "  $SCRIPT_PATH/iterm"
  echo
  echo "In iTerm's preferences dialogue:"
  echo "  General > Preferences > Load preferences from a custom folder or URL"
else
  echo "Done!"
fi
