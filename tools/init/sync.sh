#!/bin/bash

# If git is working in other process, then don't sync again
! pidof git && exit 0

# my repo
sync() {
  { cd $1 && [[ -n $(git remote -v) ]] || return; } 2>/dev/null
  git pull --quiet || echo in `pwd` >/dev/tty
}
sync $SETTING_DIR &
sync ~/blog &
sync ~/vimwiki &
sync ~/.task &
sync ~/.password-store &
sync ~/.vim_runtime &

# others repo
#check_upstream ~/git/tig || echo in `pwd` >/dev/tty &

# thunderbird
#if [[ `cat /etc/hostname` != 'vultr' ]]; then
#  rsync -a pham@topo.tw:~/.thunderbird/ ~/.thunderbird &
#fi
