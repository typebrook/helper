#compdef context

function _context() {
  compadd -S '' $(sed -E '/^$/q' ~/log/plan.context.md | cut -d' ' -f1)
}

_context
