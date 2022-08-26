#!/bin/bash
set -e

SCRIPT_PATH=$(
  cd "$(dirname "$0")"
  pwd -P
)

if [[ "$(uname -s)" == "Darwin" ]]; then
  if [[ "$(uname -m)" == "arm64" ]] || [[ "$(sysctl -in sysctl.proc_translated)" == "1" ]]; then
    if command -v /usr/local/bin/brew >/dev/null 2>&1; then
      arch -x86_64 /usr/local/bin/brew bundle dump --file="$SCRIPT_PATH/homebrew/Brewfile.intel" --mas --force
    fi

    if command -v /opt/homebrew/bin/brew >/dev/null 2>&1; then
      arch -arm64e /opt/homebrew/bin/brew bundle dump --file="$SCRIPT_PATH/homebrew/Brewfile" --mas --force
    fi
  else
    if command -v brew >/dev/null 2>&1; then
      brew bundle dump --file="$SCRIPT_PATH/homebrew/Brewfile" --mas --force
      rm "$SCRIPT_PATH/homebrew/Brewfile.intel"
    fi
  fi
fi

if command -v code >/dev/null 2>&1; then
  code --list-extensions >"$SCRIPT_PATH/vscode/extension-list"
fi

echo "Done!"
