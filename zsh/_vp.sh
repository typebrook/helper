#compdef vp

function _vp() {
  compadd -S '' $(find ~/blog/content -name '*.md' | grep -o '[^/]*$')
}

_vp
