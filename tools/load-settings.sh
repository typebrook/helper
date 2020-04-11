if [[ -z "$SETTING_DIR" ]]; then
    SETTING_DIR=$HOME/settings
fi

# set default editor
export EDITOR=vim

# load custom aliases
source $SETTING_DIR/alias

# Add custom scripts into PATH
PATH=$PATH:$SETTING_DIR/tools
find $SETTING_DIR/tools -type d | sed 1d |\
while read dir; do
    PATH=$PATH:$dir
done

# sync with important git repos
$SETTING_DIR/tools/sync.sh

# load custom functions
OSM_UTIL_DIR=$SETTING_DIR/tools/osm
source $OSM_UTIL_DIR/osm

# go
PATH=$PATH:$HOME/go/bin

