#!/bin/bash

# If git is working in other process, then don't sync again
pidof git >/dev/null && exit 0

# my repo
sync() {
  cd "$1" || return
  [ -z "$(git remote -v)" ] && return

  pwd
  GIT_SSH_COMMAND="ssh -o ControlMaster=no" git pull --quiet || \
    echo "Has trouble when syncing $(pwd)"
}

sed /^#/d ~/.repos | while read -r repo; do
  eval "sync $repo &"
done

while true; do
  if test "$(jobs -r | wc -l)" -gt 0; then
    sleep 1;
  else
    which notify-send &>/dev/null && notify-send 'Repos synced'
    break
  fi
done

touch ~/.wakeup

# others repo
#check_upstream ~/git/tig || echo in `pwd` >/dev/tty &
