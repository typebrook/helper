#! /bin/bash

date +%s >~/.wakeup

find $SETTING_DIR/bin -executable | while read file; do ln -sf $file ~/bin/; done
