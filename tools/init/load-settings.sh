# load custom aliases
export SETTING_DIR=${SETTING_DIR:=$HOME/settings}
source $SETTING_DIR/alias

# Config shell
if [[ $SHELL =~ zsh$ ]]; then
  setopt extended_glob
  fpath=($SETTING_DIR/zsh $fpath)
elif [[ $SHELL =~ bash$ ]]; then
  shopt -s extglob
fi

# set default editor
export EDITOR=vim

# Add custom scripts into PATH
BIN_DIR=$HOME/bin
PATH=$PATH:$BIN_DIR
mkdir -p $BIN_DIR
find $BIN_DIR -xtype l | xargs rm 2>/dev/null || true

find $SETTING_DIR/tools -type f -executable | \
xargs realpath | xargs -I{} ln -sf {} $BIN_DIR

# load custom functions
OSM_UTIL_DIR=$SETTING_DIR/tools/osm
source $OSM_UTIL_DIR/osm

# sync with important git repos
$SETTING_DIR/tools/init/sync.sh

# go
PATH=$PATH:$HOME/go/bin

# android-studio
PATH=$PATH:$HOME/android-studio/bin

# cargo
PATH=$PATH:$HOME/.cargo/bin

# Run something after exit shell
trap 'exit.sh' EXIT
