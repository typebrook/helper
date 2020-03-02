#! /usr/bin/env bash

set -e

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

sed -i "\^# $REPO^, /^$/ d" $RCFILE
echo "

# $REPO
export SETTING_DIR=$SETTING_DIR
source \$SETTING_DIR/tools/load-settings.sh

" >> $RCFILE

cd "$SETTING_DIR" && make
