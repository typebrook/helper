#!/bin/bash

# my repo
sync() {
  [ ! -d $1 ] && return
  cd $1 && git pull --quiet || echo in `pwd` >/dev/tty &
}
sync $SETTING_DIR
sync ~/vimwiki
sync ~/.task
sync ~/.password-store

# others repo
check_upstream ~/git/tig || echo in `pwd` >/dev/tty &
check_upstream ~/.vim_runtime || echo in `pwd` >/dev/tty &

# rsync
if [[ `cat /etc/hostname` != 'vultr' ]]; then
  rsync -a --delete pham@topo.tw:~/.thunderbird/ ~/.thunderbird &
fi
