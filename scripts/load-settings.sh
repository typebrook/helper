if [[ -z "$SETTING_DIR" ]]; then
    SETTING_DIR=$HOME/settings
fi

# load custom aliases
source $SETTING_DIR/alias.sh

# Add custom scripts into PATH
PATH=$PATH:$SETTING_DIR/scripts

# sync with important git repos
$SETTING_DIR/scripts/sync.sh

# load custom functions
source $SETTING_DIR/utils/osm
