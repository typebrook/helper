if [[ -z "$SETTING_DIR" ]]; then
    SETTING_DIR=$HOME/settings
fi

# load custom aliases
source $SETTING_DIR/alias

# Add custom scripts into PATH
PATH=$PATH:$SETTING_DIR/scripts
find $SETTING_DIR/scripts -type d | sed 1d |\
while read dir; do
    PATH=$PATH:$dir
done

# sync with important git repos
$SETTING_DIR/scripts/sync.sh

# load custom functions
OSM_UTIL_DIR=$SETTING_DIR/scripts/osm
source $OSM_UTIL_DIR/osm

