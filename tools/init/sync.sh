#!/bin/bash

# my repo
sync $SETTING_DIR
sync ~/vimwiki
sync ~/.task

# others repo
check_upstream ~/git/tig || echo in `pwd` > /dev/tty &
check_upstream ~/.vim_runtime || echo in `pwd` > /dev/tty &
