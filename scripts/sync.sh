#!/bin/bash

cd $SETTING_DIR && git pull --quiet || echo in $SETTING_DIR > /dev/tty &
cd ~/vimwiki && git pull --quiet || echo in ~/vimwiki > /dev/tty &
check_upstream ~/git/tig || echo in ~/git/tig > /dev/tty &
check_upstream ~/.vim_runtime || echo in ~/.vim_runtime > /dev/tty &
