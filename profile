# trap 'exit.sh' EXIT

# Global Env {{{
export PATH=~/.local/bin:$PATH
export HELPER_DIR=${HELPER_DIR:=$HOME/helper}
export TERM=xterm-256color
export XDG_CONFIG_HOME=~/.config
export XDG_STATE_HOME=~/.local/share/
export MAIL=$HOME/Mail
export EDITOR=vim
export SYSTEMD_EDITOR=vim
export VISUAL=$EDITOR
export TIG_EDITOR=$EDITOR
export GIT_EDITOR=$EDITOR
# }}}
# IM for GUI {{{
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
# }}}
# Custom Helper features {{{
# Get current shell
shell=$(</proc/$$/cmdline sed -E 's/(.)-.+$/\1/' | tr -d '[\0\-]')
export shell=${shell##*/}

# load custom aliases
source $HELPER_DIR/alias

# sourcr rc files in private/ and bin/
[[ -d $HELPER_DIR/private ]] && for f in $HELPER_DIR/private/*; do source $f; done
find $HELPER_DIR/bin -not -executable -name '*rc' | while read rcfile; do source $rcfile; done
find $HELPER_DIR/bin -mindepth 1 -type d | while read dir; do PATH+=:${dir}; done

# }}}
# fzf {{{
if which fzf &>/dev/null; then
  export FZF_COMPLETION_OPTS='--bind=ctrl-c:print-query'
  export FZF_CTRL_T_OPTS='--no-multi --bind=ctrl-c:print-query'
  export FZF_CTRL_R_OPTS='--bind=ctrl-c:print-query'
  fzf_preview() { fzf --preview 'cat {}'; }
  [ -f ~/.fzf.${shell} ] && source ~/.fzf.${shell}
fi
# }}}
# Set config for interactive mode {{{
[[ ! $- =~ i ]] && return 0

# attch to tmux session if exists {{{
if which tmux &>/dev/null; then
  test -z "$TMUX" && tmux attach
fi
# }}}

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
fi

if [[ $shell == bash ]]; then
  shopt -s extglob
  HISTTIMEFORMAT='%Y-%m-%d %T '

  bind -m emacs-standard -x '"\ek": fzf_preview'

  _precmd() {
    local exit_code=$?
    if [ -n "$_PS1_SIMPLE" ]; then
      PS1="$_PS1_SIMPLE"
      return
    fi

    local jobcount=$(jobs | wc -l)
    local jobstring=""
    [ "$jobcount" -gt 0 ] && jobstring="($jobcount)"

    if [ $exit_code -eq 0 ]; then
        PS1="\[\e[1;32m\]\h\[\e[0;1;36m\] \W\[\e[0m\]${jobstring} "
    else
        PS1="\[\e[1;41;30m\]\h\[\e[0;1;36m\] \W\[\e[0m\]${jobstring} "
    fi
  }
  PROMPT_COMMAND=_precmd
fi
# }}}
# claude code {{{
export CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN=1
#}}}

true
