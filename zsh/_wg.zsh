#compdef wg

function _wg() {
    compadd -S '' $(cd ~/vimwiki && ls ${words[2]}*)
}

_wg
