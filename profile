# trap 'exit.sh' EXIT

export PATH=~/.local/bin:$PATH
export HELPER_DIR=${HELPER_DIR:=$HOME/helper}
export TERM=xterm-256color
export XDG_CONFIG_HOME=~/.config
export XDG_STATE_HOME=~/.local/share/
export MAIL=$HOME/Maildir
if which nvim &>/dev/null; then
  export EDITOR=nvim
else
  export EDITOR=vim
fi
export VISUAL=$EDITOR
export TIG_EDITOR=$EDITOR
export GIT_EDITOR=$EDITOR

# IM for GUI
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Get current shell
shell=$(</proc/$$/cmdline sed -E 's/(.)-.+$/\1/' | tr -d '[\0\-]')
export shell=${shell##*/}

# load custom aliases
source $HELPER_DIR/alias

# sourcr rc files in private/ and bin/
[[ -d $HELPER_DIR/private ]] && for f in $HELPER_DIR/private/*; do source $f; done
find $HELPER_DIR/bin -not -executable -name '*rc' | while read rcfile; do source $rcfile; done
find $HELPER_DIR/bin -mindepth 1 -type d | while read dir; do PATH+=:${dir}; done

# fzf
if which fzf &>/dev/null; then
  export FZF_COMPLETION_OPTS='--bind=ctrl-c:print-query'
  export FZF_CTRL_T_OPTS='--no-multi --bind=ctrl-c:print-query'
  export FZF_CTRL_R_OPTS='--bind=ctrl-c:print-query'
  fzf_preview() { fzf --preview 'cat {}'; }
  [ -f ~/.fzf.${shell} ] && source ~/.fzf.${shell}
fi

# Set zsh or bash
if [[ $- =~ i ]]; then
    if [[ $shell == zsh ]]; then
      setopt extended_glob interactive_comments
      fpath=($HELPER_DIR/zsh $fpath)
      alias history='history -i'
      autoload compinit; compinit

      #autoload -U deer
      #zle -N deer
      #bindkey '\ek' deer
      bindkey -s '\ek' 'fzf_preview'
      bindkey -s '' 'fg || vl'
    elif [[ $shell == bash ]]; then
      shopt -s extglob
      HISTTIMEFORMAT='%Y-%m-%d %T '

      bind -m emacs-standard -x '"\ek": fzf_preview'
    fi
fi

# Apply nvm
[ -e $HOME/.config/nvm/nvm.sh ] && source "$HOME/.config/nvm/nvm.sh"

true
