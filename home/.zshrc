# shellcheck disable=SC2148

#
# ZSH Setup
#

# Uncomment to enable profiling zsh startup time with zprof
# zmodload zsh/zprof

if command -v brew > /dev/null 2>&1; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' completions 1
zstyle ':completion:*' glob 1
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list '' '+m:{[:lower:][:upper:]}={[:upper:][:lower:]} r:|[._-]=* r:|=*' '+l:|=* r:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' original false
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' substitute 1
zstyle :compinstall filename "$HOME/.zshrc"

setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus
setopt share_history

autoload -Uz compinit
compinit

#
# Configuration Variables
#

HISTFILE="$HOME/.histfile"

HISTSIZE=999999999
# shellcheck disable=SC2034
SAVEHIST=$HISTSIZE

# zsh-syntax-highlighting settings
# shellcheck disable=SC2034
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# zgen settings
# shellcheck disable=SC2034
ZGEN_RESET_ON_CHANGE="$HOME/.zshrc"

# autoupdate-zgen settings
# shellcheck disable=SC2034
ZGEN_PLUGIN_UPDATE_DAYS=7
# shellcheck disable=SC2034
ZGEN_SYSTEM_UPDATE_DAYS=7

#
# Variables
#

export EDITOR=nano

#
# Plugins
#

# Setup zgen
ZGEN_CLONE_DIR="$HOME/zgen"
ZGEN_SCRIPT_PATH="$ZGEN_CLONE_DIR/zgen.zsh"

if [[ ! -f $ZGEN_SCRIPT_PATH ]]; then
  git clone git@github.com:tarjoilija/zgen.git "$ZGEN_CLONE_DIR"
fi

# shellcheck source=/dev/null
source "$ZGEN_SCRIPT_PATH"

if ! zgen saved; then
  # oh-my-zsh plugins
  zgen oh-my-zsh plugins/autojump
  zgen oh-my-zsh plugins/iterm2
  zgen oh-my-zsh plugins/rails
  zgen oh-my-zsh plugins/sudo

  # zsh-users plugins
  zgen load zsh-users/zsh-autosuggestions
  zgen load zsh-users/zsh-completions
  zgen load zsh-users/zsh-syntax-highlighting # Must be sourced before zsh-history-substring-search
  zgen load zsh-users/zsh-history-substring-search

  # Other plugins
  zgen load djui/alias-tips
  zgen load RobSis/zsh-completion-generator
  zgen load unixorn/autoupdate-zgen

  zgen save
fi

if [[ -v ITERM_SESSION_ID ]]; then
  ITERM_INTEGRATION_PATH="$HOME/.iterm2_shell_integration.zsh"

  if [[ ! -f $ITERM_INTEGRATION_PATH ]]; then
    curl -L https://iterm2.com/shell_integration/zsh -o "$ITERM_INTEGRATION_PATH"
  fi

  # shellcheck source=/dev/null
  source "$ITERM_INTEGRATION_PATH"
fi

if command -v direnv > /dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if command -v rbenv > /dev/null 2>&1; then
  eval "$(rbenv init -)"

  RBENV_PLUGIN_DIR="$(rbenv root)/plugins"
  RBENV_DEFAULT_GEMS_DIR="$RBENV_PLUGIN_DIR/rbenv-default-gems"

  if [[ ! -d $RBENV_DEFAULT_GEMS_DIR ]]; then
    git clone git@github.com:rbenv/rbenv-default-gems.git "$RBENV_DEFAULT_GEMS_DIR"
  fi
fi

#
# Prompt
#

if command -v pip > /dev/null 2>&1 && pip show powerline-status > /dev/null 2>&1; then
  powerline-daemon -q

  POWERLINE_ROOT="$(pip show powerline-status | grep Location | sed 's/Location: //')/powerline"
  POWERLINE_PATH="$POWERLINE_ROOT/bindings/zsh/powerline.zsh"

  if [[ -f $POWERLINE_PATH ]]; then
    # shellcheck source=/dev/null
    source "$POWERLINE_PATH"
  fi
fi

#
# Aliases and Functions
#

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias 1='cd -'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

if command -v hub > /dev/null 2>&1; then
  alias git=hub
fi

function take() {
  mkdir -p "$@" && cd "${@:$#}" || exit 1
}

#
# Keybindings
#

bindkey -e

# zsh-history-substring-search key bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

#
# Finishing Touches
#

export PATH="$HOME/bin:$PATH"
