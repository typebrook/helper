export SETTING_DIR=${SETTING_DIR:=$HOME/settings}
export EDITOR=vim
export TERM=xterm-256color

# load custom aliases
source $SETTING_DIR/alias
[[ -d $SETTING_DIR/private ]] && for f in $SETTING_DIR/private/*; do source $f; done

# Config shell

shell=$(</proc/$$/cmdline tr -d '\0' | tr -d '-')
shell=${shell##*/}

# fzf
if which fzf &>/dev/null; then
  fzf_preview() { fzf --preview 'cat {}'; }
  source ~/.fzf.$shell &>/dev/null
fi

if [[ $shell == zsh ]]; then
  setopt extended_glob
  fpath=($SETTING_DIR/zsh $fpath)
  compinit
  alias history='history -i'

  #autoload -U deer
  #zle -N deer
  #bindkey '\ek' deer
  bindkey -s '\ek' 'fzf_preview'
elif [[ $shell == bash ]]; then
  shopt -s extglob
  HISTTIMEFORMAT='%Y-%m-%d %T '

  bind -m emacs-standard -x '"\ek": fzf_preview'
fi

# Add custom scripts into PATH
BIN_DIR=$HOME/bin
PATH=$PATH:$BIN_DIR
mkdir -p $BIN_DIR
find $BIN_DIR -xtype l | xargs rm 2>/dev/null || true

find $SETTING_DIR/tools -type f -executable | \
xargs realpath | xargs -I{} ln -sf {} $BIN_DIR

# Mail
MAIL=$HOME/Maildir

# sync with important git repos
(sync.sh &)

# local
PATH=$PATH:$HOME/.local/bin

# go
PATH=$PATH:$HOME/go/bin

# android-studio
PATH=$PATH:$HOME/android-studio/bin

# cargo
PATH=$PATH:$HOME/.cargo/bin

# yarn
PATH=$PATH:$HOME/.yarn/bin

# Run something after exit shell
trap 'exit.sh' EXIT

[[ `pwd` == $HOME ]] && cd ~/Downloads

true
