#! /bin/bash

date +%s >~/.wakeup

find $HELPER_DIR/bin -executable | while read file; do ln -sf $file ~/bin/; done
