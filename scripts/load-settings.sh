if [[ -z "$SETTING_DIR" ]]; then
    SETTING_DIR=$HOME/settings
fi

# load custom aliases
source $SETTING_DIR/alias

# Add custom scripts into PATH
PATH=$PATH:$SETTING_DIR/scripts

# sync with important git repos
$SETTING_DIR/scripts/sync.sh

# load custom functions
OSM_UTIL_DIR=$SETTING_DIR/scripts/osm
source $OSM_UTIL_DIR/osm && PATH=$PATH:$OSM_UTIL_DIR
