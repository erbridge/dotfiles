#!/bin/bash
set -e

SCRIPT_PATH=$(
  cd "$(dirname "$0")"
  pwd -L
)

if [[ "$(uname -s)" == "Darwin" ]]; then
  if command -v brew >/dev/null 2>&1; then
    brew bundle dump --file="$SCRIPT_PATH/homebrew/Brewfile" --mas --force
  fi
fi

if command -v code >/dev/null 2>&1; then
  code --list-extensions >"$SCRIPT_PATH/vscode/extension-list"
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
  echo "Now dump Raycast and you're done!"
  echo
  echo "Raycast's settings belong here:"
  echo "  $SCRIPT_PATH/raycast"
  echo
  echo "In Raycast:"
  echo "  Export Preferences & Data"
else
  echo "Done!"
fi
