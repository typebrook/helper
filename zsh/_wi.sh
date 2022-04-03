#compdef wi

function _wi() {
    compadd -S '' $(cd ~/vimwiki && find -not -path "./logseq/*" -name '*.md' -printf "%f\n" | sed -E '/^[0-9]{4}-[0-9]{2}-[0-9]{2}/d')
}

_wi
