#!/bin/bash
set -e

SCRIPT_PATH=$(cd "$(dirname "$0")"; pwd -P)

if command -v brew > /dev/null 2>&1; then
  brew bundle dump --file="$SCRIPT_PATH/homebrew/Brewfile" --force
fi

if command -v code > /dev/null 2>&1; then
  code --list-extensions > "$SCRIPT_PATH/vscode/extension-list"
fi

echo "Done!"
