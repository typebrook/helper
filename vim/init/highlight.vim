" highlight MatchParen ctermfg=NONE ctermbg=darkgrey cterm=NONE
hi LuaParen ctermfg=NONE ctermbg=darkgrey cterm=NONE

" Show trailing spaces
if has('nvim')
  match ExtraWhitespace /\s\+$/
endif
hi ExtraWhitespace ctermbg=red guibg=red

hi CursorLine guibg=NONE
" Only works when :set cursorline in neovim
hi CursorLineNr term=bold cterm=bold ctermfg=226 gui=bold guifg=#eeee00

hi Folded guifg=#848089 guibg=#37343a ctermfg=lightblue ctermbg=black

hi NonText guifg=black guibg=#2d2a2e ctermfg=black ctermbg=black
