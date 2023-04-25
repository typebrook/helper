#! /bin/bash

# Add custom scripts into PATH
export SETTING_DIR=~/helper
export BIN_DIR=$HOME/bin
export PATH=$BIN_DIR:$PATH

mkdir -p $BIN_DIR
find $BIN_DIR -xtype l -exec rm {} + 2>/dev/null
find $SETTING_DIR/bin -type f -executable -exec realpath {} + | \
xargs -I{} ln -sf {} $BIN_DIR

# sync with important git repos
setsid ~/bin/sync.sh && \
which notify-send &>/dev/null && \
notify-send 'Repos synced'

# Copy context file from vps
rsync -au vps:~/.context ~/.context
