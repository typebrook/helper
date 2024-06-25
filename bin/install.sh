#! /usr/bin/env bash

set -e

# Default settings
SETTING_DIR=${SETTING_DIR:-~/helper}
REPO=${REPO:-typebrook/helper}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-dev}
COMMENT_IN_RCFILE="# $REPO: source custom shell settings"
PROFILE=profile.sh

case "$(basename $SHELL)" in
  bash) RCFILE=~/.bashrc
  ;;
  zsh) RCFILE=~/.config/zsh/.zshrc
  ;;
  *) echo Current shell is not bash or zsh; exit 1;
  ;;
esac

# If ~/helper doesn't exist, do git clone
if [ ! -d $SETTING_DIR ]; then
	git clone --depth=1 --branch "$BRANCH" "$REMOTE" "$SETTING_DIR" || {
		error "git clone of helper repo failed"
		exit 1
	}
fi

# Write initial commands into .bashrc or .zshrc
sed -i "\^$COMMENT_IN_RCFILE^, /^$/ d" $RCFILE
cat >>$RCFILE <<EOF

$COMMENT_IN_RCFILE
export SETTING_DIR=$SETTING_DIR
source \$SETTING_DIR/$PROFILE

EOF

echo Add profile into $RCFILE
cd "$SETTING_DIR" || exit 1
make
