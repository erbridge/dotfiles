# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' completions 1
zstyle ':completion:*' glob 1
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' matcher-list '' '+m:{[:lower:][:upper:]}={[:upper:][:lower:]} r:|[._-]=* r:|=*' '+l:|=* r:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' original false
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' substitute 1
zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=999999999
SAVEHIST=$HISTSIZE
setopt autocd
bindkey -e
# End of lines configured by zsh-newuser-install
# Run again with:
# autoload -Uz zsh-newuser-install
# zsh-newuser-install -f

export EDITOR=nano

# zsh-syntax-highlighting settings
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# zgen settings
ZGEN_RESET_ON_CHANGE="$HOME/.zshrc"

# autoupdate-zgen settings
ZGEN_PLUGIN_UPDATE_DAYS=7
ZGEN_SYSTEM_UPDATE_DAYS=7

# Setup zgen
ZGEN_CLONE_DIR="$HOME/zgen"

if [[ ! -f $ZGEN_CLONE_DIR/zgen.zsh ]]; then
    git clone git@github.com:tarjoilija/zgen.git $ZGEN_CLONE_DIR
fi

source "$ZGEN_CLONE_DIR/zgen.zsh"

if ! zgen saved; then
    # oh-my-zsh plugins
    zgen oh-my-zsh plugins/autojump
    zgen oh-my-zsh plugins/rails

    # zsh-users plugins
    zgen load zsh-users/zsh-autosuggestions
    zgen load zsh-users/zsh-completions
    zgen load zsh-users/zsh-history-substring-search
    zgen load zsh-users/zsh-syntax-highlighting

    # Other plugins
    zgen load djui/alias-tips
    zgen load RobSis/zsh-completion-generator
    zgen load unixorn/autoupdate-zgen

    zgen save
fi

if which pip > /dev/null 2>&1 && pip show powerline-status > /dev/null 2>&1; then
  powerline-daemon -q

  POWERLINE_ROOT="$(pip show powerline-status | grep Location | sed 's/Location: //')/powerline"
  POWERLINE_PATH="$POWERLINE_ROOT/bindings/zsh/powerline.zsh"

  if [[ -f $POWERLINE_PATH ]]; then
    source "$POWERLINE_PATH"
  fi
fi

if which rbenv > /dev/null 2>&1; then
    eval "$(rbenv init -)"

    RBENV_PLUGIN_DIR="$(rbenv root)/plugins"
    RBENV_DEFAULT_GEMS_DIR="$RBENV_PLUGIN_DIR/rbenv-default-gems"

    if [[ ! -d $RBENV_DEFAULT_GEMS_DIR ]]; then
      git clone git@github.com:rbenv/rbenv-default-gems.git $RBENV_DEFAULT_GEMS_DIR
    fi
fi
