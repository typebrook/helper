#! /usr/bin/env bash

set -e

# Default settings
SETTING_DIR=${SETTING_DIR:-~/settings}
REPO=${REPO:-typebrook/settings}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-dev}

if [ ! -d $SETTING_DIR ]; then
  git clone --depth=1 --branch "$BRANCH" "$REMOTE" "$SETTING_DIR" || {
      error "git clone of settings repo failed"
      exit 1
  }
fi

sed "/^# $REPO/, /^$/ d"
cat <<EOF

# $REPO
export SETTING_DIR=$HOME/settings
source $SETTING_DIR/tools/load-settings.sh

EOF >> ~/.$(basename $SHELL)rc

cd "$SETTING_DIR" && make
