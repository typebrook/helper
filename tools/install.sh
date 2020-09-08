#! /usr/bin/env bash

set -xe

# Default settings
SETTING_DIR=${SETTING_DIR:-~/settings}
REPO=${REPO:-typebrook/settings}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-dev}
RCFILE=${RCFILE:-~/.$(basename $SHELL)rc}

if [ ! -d $SETTING_DIR ]; then
  git clone --depth=1 --branch "$BRANCH" "$REMOTE" "$SETTING_DIR" || {
      error "git clone of settings repo failed"
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

cd "$SETTING_DIR" && make
