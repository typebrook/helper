#compdef tkc

function _tkc() {
  compadd -S '' $(sed -E '/^$/q' ~/log/plan.context.md | cut -d' ' -f1)
}

_tkc
