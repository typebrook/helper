# load custom aliases
export SETTING_DIR=${SETTING_DIR:=$HOME/settings}
source $SETTING_DIR/alias
[[ -d $SETTING_DIR/private ]] && source $SETTING_DIR/private/*

# Config shell
case $SHELL in
  *zsh)
    setopt extended_glob
    fpath=($SETTING_DIR/zsh $fpath)
    autoload -U deer
    zle -N deer
    bindkey '\ek' deer
    ;;
  *bash)
    shopt -s extglob
    ;;
esac

# set default editor
export EDITOR=vim

# Add custom scripts into PATH
BIN_DIR=$HOME/bin
PATH=$PATH:$BIN_DIR
mkdir -p $BIN_DIR
find $BIN_DIR -xtype l | xargs rm 2>/dev/null || true

find $SETTING_DIR/tools -type f -executable | \
xargs realpath | xargs -I{} ln -sf {} $BIN_DIR

# Mail
MAIL=$HOME/Maildir

# load custom functions
OSM_UTIL_DIR=$SETTING_DIR/tools/osm
source $OSM_UTIL_DIR/osm

# sync with important git repos
$SETTING_DIR/tools/init/sync.sh

# local
PATH=$PATH:$HOME/.local/bin

# go
PATH=$PATH:$HOME/go/bin

# android-studio
PATH=$PATH:$HOME/android-studio/bin

# cargo
PATH=$PATH:$HOME/.cargo/bin

# yarn
PATH=$PATH:$HOME/.yarn/bin

# Run something after exit shell
trap 'exit.sh' EXIT
