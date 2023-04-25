#!/bin/bash

# If git is working in other process, then don't sync again
pidof git >/dev/null && exit 0

# my repo
sync() {
  {
    cd $1 && [[ -n `git remote -v` ]] || return
  } 2>/dev/null
  GIT_SSH_COMMAND="ssh -o ControlMaster=no" git pull --quiet || echo Has trouble when syncing `pwd`
}

while read repo; do
  sync $repo &
done <~/.repos 

while true; do
  if test $(jobs -r | wc -l) -gt 0; then
    sleep 1;
  else
    which notify-send &>/dev/null && notify-send 'Repos synced'
    break
  fi
done &

# others repo
#check_upstream ~/git/tig || echo in `pwd` >/dev/tty &

# thunderbird
#if [[ `cat /etc/hostname` != 'vultr' ]]; then
#  rsync -a pham@topo.tw:~/.thunderbird/ ~/.thunderbird &
#fi
