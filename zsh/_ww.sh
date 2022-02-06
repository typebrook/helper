#compdef ww

function _ww() {
    compadd -S '' $(cd ~/vimwiki && ls ${words[2]}*)
}

_ww
