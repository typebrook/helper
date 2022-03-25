#compdef wi

function _wi() {
    compadd -S '' $(cd ~/vimwiki && ls ${words[2]}*)
}

_wi
