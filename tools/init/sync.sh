#!/bin/bash

# If git is working in other process, then don't sync again
pidof git >/dev/null && exit 0

# my repo
sync() {
  { cd $1 && [[ -n $(git remote -v) ]] || return; } 2>/dev/null
  git pull --quiet || echo Has trouble when syncing `pwd` >/dev/tty
}
sync $SETTING_DIR &
sync ~/blog &
sync ~/vimwiki &
sync ~/.task &
sync ~/.password-store &
sync ~/.vim_runtime &

while [ $(jobs -r | wc -l) -gt 0 ]; do
  sleep 1;
done

if which notify-send &>/dev/null; then
  notify-send 'Repos synced'
fi

# others repo
#check_upstream ~/git/tig || echo in `pwd` >/dev/tty &

# thunderbird
#if [[ `cat /etc/hostname` != 'vultr' ]]; then
#  rsync -a pham@topo.tw:~/.thunderbird/ ~/.thunderbird &
#fi
