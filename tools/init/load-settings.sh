export SETTING_DIR=${SETTING_DIR:=$HOME/settings}
export EDITOR=vim

# load custom aliases
source $SETTING_DIR/alias
[[ -d $SETTING_DIR/private ]] && for f in $SETTING_DIR/private/*; do source $f; done

# set caps as ctrl under X
setxkbmap -option ctrl:nocaps 2>/dev/null

# Config shell
shell=$(cat /proc/$$/cmdline | tr -d '\0')
case $shell in
  *zsh*)
    setopt extended_glob
    fpath=($SETTING_DIR/zsh $fpath)
    compinit
    autoload -U deer
    zle -N deer
    bindkey '\ek' deer
    ;;
  *bash*)
    shopt -s extglob
    ;;
esac

# Add custom scripts into PATH
BIN_DIR=$HOME/bin
PATH=$PATH:$BIN_DIR
mkdir -p $BIN_DIR
find $BIN_DIR -xtype l | xargs rm 2>/dev/null || true

find $SETTING_DIR/tools -type f -executable | \
xargs realpath | xargs -I{} ln -sf {} $BIN_DIR

# Mail
MAIL=$HOME/Maildir

# sync with important git repos
sync.sh

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
