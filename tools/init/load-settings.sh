trap 'exit.sh' EXIT

export SETTING_DIR=${SETTING_DIR:=$HOME/helper}
export EDITOR=vim
export TERM=xterm-256color
export XDG_CONFIG_HOME=~/.config

# Get current shell
export shell=$(</proc/$$/cmdline sed -E 's/(.)-.+$/\1/' | tr -d '[\0\-]')
shell=${shell##*/}

# load custom aliases
source $SETTING_DIR/alias
[[ -d $SETTING_DIR/private ]] && for f in $SETTING_DIR/private/*; do source $f; done

# Add custom scripts into PATH
BIN_DIR=$HOME/bin
PATH=$BIN_DIR:$PATH
mkdir -p $BIN_DIR
find $BIN_DIR -xtype l -exec rm {} + 2>/dev/null
find $SETTING_DIR/tools -type f -executable -exec realpath {} + | \
xargs -I{} ln -sf {} $BIN_DIR

# Mail
MAIL=$HOME/Maildir

# sync with important git repos
setsid sync.sh

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

# fzf
if which fzf &>/dev/null; then
  fzf_preview() { fzf --preview 'cat {}'; }
  source ~/.fzf.${shell} &>/dev/null
fi

# Set zsh or bash
if [[ $- =~ i ]]; then
    if [[ $shell == zsh ]]; then
      setopt extended_glob
      fpath=($SETTING_DIR/zsh $fpath)
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
fi

# Working DIR
[[ `pwd` == $HOME ]] && cd ~/Downloads

true
