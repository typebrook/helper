#compdef vp

function _vp() {
    compadd -S '' $(cd ~/blog/content/posts && ls ${words[2]}*)
}

_vp
