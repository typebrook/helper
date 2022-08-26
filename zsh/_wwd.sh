#compdef wwd

function _wwd() {
    compadd -S '' $(
      cd ~/log/diary/ && \
      find -name '*.md' -printf "%f\n" | \
      sed -E 's/.md$//'
    )
}

_wwd
