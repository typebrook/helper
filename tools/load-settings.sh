if [[ -z "$SETTING_DIR" ]]; then
  SETTING_DIR=$HOME/settings
fi

if [[ $0 == 'zsh' ]]; then
  setopt extended_glob
elif [[ $0 == 'bash' ]]; then
  shopt -s extglob
fi

# set default editor
export EDITOR=vim

# load custom aliases
source $SETTING_DIR/alias

# Add custom scripts into PATH
mkdir -p $HOME/bin
PATH=$PATH:$HOME/bin

find $SETTING_DIR/tools -type f -executable | \
xargs realpath | \
xargs -I{} ln -sf {} $HOME/bin

# sync with important git repos
$SETTING_DIR/tools/sync.sh

# load custom functions
OSM_UTIL_DIR=$SETTING_DIR/tools/osm
source $OSM_UTIL_DIR/osm

# go
PATH=$PATH:$HOME/go/bin

