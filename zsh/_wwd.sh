#compdef wwd

function _wwd() {
    compadd -S '' $(
      cd ~/vimwiki/diary/ && \
      find -name '*.md' -printf "%f\n" | \
      sed -E 's/.md$//'
    )
}

_wwd
