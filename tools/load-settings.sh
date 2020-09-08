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

# sync with important git repos
$SETTING_DIR/tools/sync.sh

# Add custom scripts into PATH
BIN_DIR=$HOME/bin
PATH=$PATH:$BIN_DIR
mkdir -p $BIN_DIR
find $BIN_DIR -xtype l | xargs rm

find $SETTING_DIR/tools -type f -executable | \
xargs realpath | xargs -I{} ln -sf {} $BIN_DIR

# load custom functions
OSM_UTIL_DIR=$SETTING_DIR/tools/osm
source $OSM_UTIL_DIR/osm

# go
PATH=$PATH:$HOME/go/bin
