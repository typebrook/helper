#! /usr/bin/env bash

set -e

# Default settings
SETTING_DIR=${SETTING_DIR:-~/settings}
REPO=${REPO:-typebrook/settings}
REMOTE=${REMOTE:-https://github.com/${REPO}.git}
BRANCH=${BRANCH:-master}

git clone --depth=1 --branch "$BRANCH" "$REMOTE" "$SETTING_DIR" || {
	error "git clone of settings repo failed"
	exit 1
}

cd "$SETTING_DIR" && make
