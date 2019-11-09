#!/bin/bash

cd $SETTING_DIR && git pull --quiet &
cd ~/vimwiki && git pull --quiet &
check_upstream ~/git/tig &
check_upstream ~/.vim_runtime &
