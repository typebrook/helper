#compdef tkc

function _tkc() {
    compadd -S '' $(cut -d' ' -f1 ~/log/plan.context.md)
}

_tkc
