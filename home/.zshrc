# shellcheck disable=SC2148

#
# Configuration Variables
#

HISTFILE=$HOME/.histfile

HISTSIZE=999999999
# shellcheck disable=SC2034
SAVEHIST=$HISTSIZE

# shellcheck disable=SC2034
WORDCHARS=''

ZSH_CACHE_DIR=$HOME/.zcache

#
# Variables
#

export EDITOR=nano

if command -v code > /dev/null 2>&1; then
  export VISUAL=code
fi

#
# Homebrew
#

if command -v /opt/homebrew/bin/brew > /dev/null 2>&1; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if command -v /usr/local/bin/brew > /dev/null 2>&1; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if command -v brew > /dev/null 2>&1; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  RUBY_CONFIGURE_OPTS=--with-openssl-dir=$(brew --prefix openssl@1.1)
  export RUBY_CONFIGURE_OPTS
fi

#
# ZSH
#

# Uncomment to enable profiling zsh startup time with zprof
# zmodload zsh/zprof

if [[ ! -d $ZSH_CACHE_DIR ]]; then
  mkdir -p "$ZSH_CACHE_DIR"
fi

setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus

setopt interactivecomments

# History
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt share_history

# Completion
setopt always_to_end
setopt auto_menu
setopt complete_in_word
unsetopt flowcontrol
unsetopt menu_complete

zmodload -i zsh/complist

# zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion::complete:*' use-cache true
zstyle ':completion::complete:*' cache-path "$ZSH_CACHE_DIR"

autoload -Uz compinit
compinit

#
# SSH
#

if [[ $TERM_PROGRAM != vscode ]] && command -v ssh-agent > /dev/null 2>&1; then
  eval "$(ssh-agent)"
  ssh-add -A
fi

#
# Plugins
#

# zsh-syntax-highlighting settings
# shellcheck disable=SC2034
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# zgen settings
# shellcheck disable=SC2034
ZGEN_RESET_ON_CHANGE=$HOME/.zshrc

# autoupdate-zgen settings
# shellcheck disable=SC2034
ZGEN_PLUGIN_UPDATE_DAYS=7
# shellcheck disable=SC2034
ZGEN_SYSTEM_UPDATE_DAYS=7

# Setup zgen
ZGEN_CLONE_DIR=$HOME/zgen
ZGEN_SCRIPT_PATH=$ZGEN_CLONE_DIR/zgen.zsh

if [[ ! -f $ZGEN_SCRIPT_PATH ]]; then
  git clone git@github.com:tarjoilija/zgen.git "$ZGEN_CLONE_DIR"
fi

# shellcheck source=/dev/null
source "$ZGEN_SCRIPT_PATH"

if [[ $TERM_PROGRAM != vscode ]] && ! zgen saved; then
  # oh-my-zsh plugins
  zgen oh-my-zsh plugins/autojump
  zgen oh-my-zsh plugins/iterm2
  zgen oh-my-zsh plugins/sudo

  # zsh-users plugins
  zgen load zsh-users/zsh-autosuggestions
  zgen load zsh-users/zsh-completions
  zgen load zsh-users/zsh-syntax-highlighting # Must be sourced before zsh-history-substring-search
  zgen load zsh-users/zsh-history-substring-search

  # Other plugins
  zgen load djui/alias-tips
  # zgen load RobSis/zsh-completion-generator
  zgen load unixorn/autoupdate-zgen

  zgen save
fi

if command -v nano > /dev/null 2>&1; then
  NANORC_DIR=$HOME/.nano

  if [[ ! -d $NANORC_DIR ]]; then
    git clone git@github.com:scopatz/nanorc.git "$NANORC_DIR"
  fi
fi

if [[ -v ITERM_SESSION_ID ]]; then
  ITERM_INTEGRATION_PATH=$HOME/.iterm2_shell_integration.zsh

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

  RBENV_PLUGIN_DIR=$(rbenv root)/plugins
  RBENV_DEFAULT_GEMS_DIR=$RBENV_PLUGIN_DIR/rbenv-default-gems

  if [[ ! -d $RBENV_DEFAULT_GEMS_DIR ]]; then
    git clone git@github.com:rbenv/rbenv-default-gems.git "$RBENV_DEFAULT_GEMS_DIR"
  fi
fi

if command -v nodenv > /dev/null 2>&1; then
  eval "$(nodenv init -)"

  NODENV_PLUGIN_DIR=$(nodenv root)/plugins
  NODE_BUILD_UPDATE_DEFS_DIR=$NODENV_PLUGIN_DIR/node-build-update-defs

  if [[ ! -d $NODE_BUILD_UPDATE_DEFS_DIR ]]; then
    git clone git@github.com:nodenv/node-build-update-defs.git "$NODE_BUILD_UPDATE_DEFS_DIR"
  fi
fi

if command -v goenv > /dev/null 2>&1; then
  eval "$(goenv init -)"
fi

if [[ -f $HOME/.travis/travis.sh ]]; then
  # shellcheck source=/dev/null
  source "$HOME/.travis/travis.sh"
fi

#
# Prompt
#

if command -v starship > /dev/null 2>&1; then
  eval "$(starship init zsh)"
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

if command -v lsd > /dev/null 2>&1; then
  alias ls='lsd'
else
  alias ls='ls -G'
fi

if command -v hub > /dev/null 2>&1; then
  alias git='hub'
fi

function take() {
  mkdir -p "$@" && cd "${@:$#}" || exit 1
}

function configure-monitors() {
  displayplacer "id:4A329880-4032-7100-DE79-71A95CA6246A res:1440x900 color_depth:8 scaling:on origin:(0,0) degree:0" "id:31C5597E-A2FF-2BE8-7071-DEAC7D418B8E res:1440x2560 hz:60 color_depth:8 scaling:off origin:(1132,-2560) degree:90"
}

#
# Keybindings
#

bindkey -e

bindkey -M menuselect '^o' accept-and-infer-next-history

# zsh-history-substring-search key bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

#
# Finishing Touches
#

export GOPATH=$HOME/code
export PATH=$GOPATH/bin:$PATH

export PATH=$HOME/bin:$PATH
