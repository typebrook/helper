#compdef ww

function _ww() {
    compadd -S '' $(
      cd ~/log && \
      find -name '*.md' | \
      sed -E 's#./##; s/.md$//'
    )
}

_ww
