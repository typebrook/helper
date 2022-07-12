#compdef vp

function _vp() {
  compadd -S '' $(ssh vps find /home/pham/blog/content -name '\*.md' | grep -o '[^/]*$')
}

_vp
