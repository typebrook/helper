#! /usr/bin/env bash

set -e

# Default settings
SETTING_DIR=${SETTING_DIR:-~/helper}
REPO=${REPO:-typebrook/helper}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-dev}
RCFILE=${RCFILE:-~/.$(basename $SHELL)rc}

if [ ! -d $SETTING_DIR ]; then
  git clone --depth=1 --branch "$BRANCH" "$REMOTE" "$SETTING_DIR" || {
      error "git clone of helper repo failed"
      exit 1
  }
fi

# Write initial commands into .bashrc or .zshrc
sed -i'.bak' "\^# $REPO^, /^$/ d" $RCFILE
cat >>$RCFILE <<EOF

# $REPO
export SETTING_DIR=$SETTING_DIR
source \$SETTING_DIR/tools/init/load-settings.sh
EOF

cd "$SETTING_DIR" || exit 1
git swapprotocol
make
