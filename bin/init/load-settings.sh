# trap 'exit.sh' EXIT

export SETTING_DIR=${SETTING_DIR:=$HOME/helper}
export BIN_DIR=~/bin
export PATH=$BIN_DIR:$PATH
export TERM=xterm-256color
export XDG_CONFIG_HOME=~/.config
export XDG_STATE_HOME=~/.local/share/
export MAIL=$HOME/Maildir
if which nvim &>/dev/null; then
  export EDITOR=nvim
  export VISUAL=nvim
  export TIG_EDITOR=nvim
  export GIT_EDITOR=nvim
else
  export EDITOR=vim
  export VISUAL=vim
  export TIG_EDITOR=vim
  export GIT_EDITOR=vim
fi

# Get current shell
shell=$(</proc/$$/cmdline sed -E 's/(.)-.+$/\1/' | tr -d '[\0\-]')
export shell=${shell##*/}

# load custom aliases
source $SETTING_DIR/alias

# sourcr rc files in private/ and bin/
[[ -d $SETTING_DIR/private ]] && for f in $SETTING_DIR/private/*; do source $f; done
find $SETTING_DIR/bin -not -executable -name '*rc' | while read rcfile; do source $rcfile; done

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
  export FZF_COMPLETION_OPTS='--bind=ctrl-c:print-query'
  export FZF_CTRL_T_OPTS='--no-multi --bind=ctrl-c:print-query'
  export FZF_CTRL_R_OPTS='--bind=ctrl-c:print-query'
  fzf_preview() { fzf --preview 'cat {}'; }
  source ~/.fzf.${shell}
fi

# Set zsh or bash
if [[ $- =~ i ]]; then
    if [[ $shell == zsh ]]; then
      setopt extended_glob
      fpath=($SETTING_DIR/zsh $fpath)
      alias history='history -i'
      autoload compinit; compinit

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

# Apply nvm
[ -e $HOME/.config/nvm/nvm.sh ] && source "$HOME/.config/nvm/nvm.sh"

# Working DIR
[[ `pwd` == $HOME ]] && test -d ~/Downloads && cd ~/Downloads

true
