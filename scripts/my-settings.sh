if [[ -z "$SETTING_DIR" ]]; then
    SETTING_DIR=$HOME/settings
fi

source $SETTING_DIR/alias.sh

PATH=$PATH:$SETTING_DIR/scripts
$SETTING_DIR/scripts/sync.sh
