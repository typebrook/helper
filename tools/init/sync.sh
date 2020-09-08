#!/bin/bash

# my repo
cd $SETTING_DIR && git pull --quiet || echo in `pwd` > /dev/tty &
if [ -d ~/vimwiki ]; then
  cd ~/vimwiki && git pull --quiet || echo in `pwd` > /dev/tty &
fi

# others repo
check_upstream ~/git/tig || echo in `pwd` > /dev/tty &
check_upstream ~/.vim_runtime || echo in `pwd` > /dev/tty &
