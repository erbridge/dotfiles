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

#
# Homebrew
#

if [[ "$(uname -s)" == "Darwin" ]] && ([[ "$(uname -m)" == "arm64" ]] || [[ "$(sysctl -in sysctl.proc_translated)" == "1" ]]); then
  if command -v /usr/local/bin/brew >/dev/null 2>&1; then
    eval "$(/usr/local/bin/brew shellenv)"
    FPATH=$(/usr/local/bin/brew --prefix)/share/zsh/site-functions:$FPATH
    alias ibrew='arch -x86_64 /usr/local/bin/brew'
  fi

  if command -v /opt/homebrew/bin/brew >/dev/null 2>&1; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    FPATH=$(/opt/homebrew/bin/brew --prefix)/share/zsh/site-functions:$FPATH
  fi
else
  if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv)"
    FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
  fi
fi

# if command -v brew >/dev/null 2>&1; then
#   export LDFLAGS=-L$(brew --prefix)/opt/libffi/lib $LDFLAGS
#   export CPPFLAGS=-I$(brew --prefix)/opt/libffi/include $CPPFLAGS
#   export PKG_CONFIG_PATH=$(brew --prefix)/opt/libffi/lib/pkgconfig:$PKG_CONFIG_PATH
# fi

export RUBY_CFLAGS=-DUSE_FFI_CLOSURE_ALLOC

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

#
# SSH
#

if [[ $TERM_PROGRAM != vscode ]] && command -v ssh-agent >/dev/null 2>&1; then
  eval "$(ssh-agent)"
  ssh-add --apple-load-keychain
fi

#
# ZSH Plugins
#

# zsh-syntax-highlighting settings
# shellcheck disable=SC2034
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Setup zgenom
ZGENOM_CLONE_DIR=$HOME/zgenom
ZGENOM_SCRIPT_PATH=$ZGENOM_CLONE_DIR/zgenom.zsh

if [[ ! -f $ZGENOM_SCRIPT_PATH ]]; then
  git clone git@github.com:jandamm/zgenom.git "$ZGENOM_CLONE_DIR"
fi

# shellcheck source=/dev/null
source "$ZGENOM_SCRIPT_PATH"

zgenom autoupdate --background

if ! zgenom saved; then
  # oh-my-zsh plugins
  zgenom ohmyzsh plugins/autojump
  zgenom ohmyzsh plugins/iterm2
  zgenom ohmyzsh plugins/sudo

  # zsh-users plugins
  zgenom load zsh-users/zsh-autosuggestions
  zgenom load zsh-users/zsh-completions
  zgenom load zsh-users/zsh-syntax-highlighting # Must be sourced before zsh-history-substring-search
  zgenom load zsh-users/zsh-history-substring-search

  # Other plugins
  zgenom load djui/alias-tips
  zgenom load eventi/noreallyjustfuckingstopalready
  # zgenom load RobSis/zsh-completion-generator
  # zgenom load unixorn/autoupdate-zgenom

  zgenom compile $HOME/.zshrc

  zgenom save

  if command -v rbenv >/dev/null 2>&1; then
    rbenv rehash
  fi

  if command -v nodenv >/dev/null 2>&1; then
    nodenv rehash
  fi

  if command -v pyenv >/dev/null 2>&1; then
    pyenv rehash
  fi
fi

#
# Prompt
#

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

#
# Plugins
#

if command -v nano >/dev/null 2>&1; then
  NANORC_DIR=$HOME/.nano

  if [[ ! -d $NANORC_DIR ]]; then
    git clone git@github.com:scopatz/nanorc.git "$NANORC_DIR"
  fi
fi

if [[ -v ITERM_PROFILE ]]; then
  ITERM2_INTEGRATION_PATH=$HOME/.iterm2_shell_integration.zsh

  if [[ ! -f $ITERM2_INTEGRATION_PATH ]]; then
    curl -L https://iterm2.com/shell_integration/zsh -o "$ITERM2_INTEGRATION_PATH"
  fi

  # shellcheck source=/dev/null
  source "$ITERM2_INTEGRATION_PATH"
fi

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init -)"

  RBENV_PLUGIN_DIR=$(rbenv root)/plugins
  RBENV_DEFAULT_GEMS_DIR=$RBENV_PLUGIN_DIR/rbenv-default-gems
  RBENV_GEMSET_DIR=$RBENV_PLUGIN_DIR/rbenv-gemset

  if [[ ! -d $RBENV_DEFAULT_GEMS_DIR ]]; then
    git clone git@github.com:rbenv/rbenv-default-gems.git "$RBENV_DEFAULT_GEMS_DIR"
  fi

  if [[ ! -d $RBENV_GEMSET_DIR ]]; then
    git clone git@github.com:jf/rbenv-gemset.git "$RBENV_GEMSET_DIR"
  fi
fi

if command -v nodenv >/dev/null 2>&1; then
  eval "$(nodenv init -)"

  NODENV_PLUGIN_DIR=$(nodenv root)/plugins
  NODE_BUILD_UPDATE_DEFS_DIR=$NODENV_PLUGIN_DIR/node-build-update-defs

  if [[ ! -d $NODE_BUILD_UPDATE_DEFS_DIR ]]; then
    git clone git@github.com:nodenv/node-build-update-defs.git "$NODE_BUILD_UPDATE_DEFS_DIR"
  fi
fi

if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"

  if command -v pyenv-virtualenv-init >/dev/null 2>&1; then
    eval "$(pyenv virtualenv-init -)"
  fi
fi

if command -v mcfly >/dev/null 2>&1; then
  export MCFLY_FUZZY=true
  export MCFLY_RESULTS=25
  export MCFLY_INTERFACE_VIEW=BOTTOM

  eval "$(mcfly init zsh)"
fi

if [[ -f $HOME/.travis/travis.sh ]]; then
  # shellcheck source=/dev/null
  source "$HOME/.travis/travis.sh"
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

{
  update_system_command="brew update && brew upgrade"

  if [[ "$(type ibrew)" == "ibrew is an alias"* ]]; then
    update_system_command="$update_system_command && ibrew update && ibrew upgrade"
  fi

  if command -v mas >/dev/null 2>&1; then
    update_system_command="$update_system_command && mas upgrade"

  fi

  alias update-system=$update_system_command
}

if command -v lsd >/dev/null 2>&1; then
  alias ls='lsd'
else
  alias ls='ls -G'
fi

if command -v hub >/dev/null 2>&1; then
  alias git='hub'
fi

function take() {
  mkdir -p "$@" && cd "${@:$#}" || exit 1
}

function configure-monitors() {
  if command -v scutil >/dev/null 2>&1; then
    COMPUTER_NAME=$(scutil --get ComputerName)

    case $COMPUTER_NAME in
    bread)
      displayplacer "id:4A329880-4032-7100-DE79-71A95CA6246A res:1440x900 color_depth:8 scaling:on origin:(0,0) degree:0" "id:31C5597E-A2FF-2BE8-7071-DEAC7D418B8E res:1440x2560 hz:60 color_depth:8 scaling:off origin:(1132,-2560) degree:90"
      ;;
    sourdough)
      displayplacer "id:37D8832A-2D66-02CA-B9F7-8F30A301B230 res:1680x1050 hz:60 color_depth:8 scaling:on origin:(0,0) degree:0" "id:FF7A1541-B6B9-EDFC-0857-D6964E3302DB res:1080x1920 hz:60 color_depth:8 scaling:off origin:(1410,-1920) degree:90"
      ;;
    esac
  fi
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

export GPG_TTY=$(tty)
