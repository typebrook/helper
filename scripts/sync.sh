#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
source $DIR/check_upstream.sh

cd ~/git/settings && git pull --quiet &
cd ~/vimwiki && git pull --quiet &
check_upstream git/tig &
check_upstream .vim_runtime &
