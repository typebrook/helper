#!/bin/bash

cd $SETTING_DIR && git pull --quiet || echo in `pwd` > /dev/tty &
cd ~/vimwiki && git pull --quiet || echo in `pwd` > /dev/tty &
check_upstream ~/git/tig || echo in `pwd` > /dev/tty &
check_upstream ~/.vim_runtime || echo in `pwd` > /dev/tty &
