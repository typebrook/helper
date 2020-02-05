#!/bin/bash

cd $SETTING_DIR && git pull --quiet & || echo in $SETTING_DIR
cd ~/vimwiki && git pull --quiet & || echo in ~/vimwiki
check_upstream ~/git/tig & || echo in ~/git/tig
check_upstream ~/.vim_runtime & || echo in ~/.vim_runtime
