"----------------------------------------------------------------------
" SYNTAX_HIGHLIGHT
"----------------------------------------------------------------------

syntax enable

function! GetHighlightGroupName()
    let l:syntaxID = synID(line('.'), col('.'), 1)
    let l:groupName = synIDattr(l:syntaxID, 'name')
    echo "Highlight Group Name: " . l:groupName
endfunction

" Defualt highlight for matched parenthesis is so weird in many colorscheme
" Why the background color is lighter than my caret !?
highlight MatchParen ctermfg=NONE ctermbg=darkgrey cterm=NONE
highlight LuaParen ctermfg=NONE ctermbg=darkgrey cterm=NONE

" Show trailing spaces
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" Persist visualized lines
" define line highlight color
highlight MultiLineHighlight ctermbg=LightYellow guibg=LightYellow ctermfg=Black guifg=Black
" highlight the current line
nnoremap <silent> <leader><leader>h :call matchadd('MultiLineHighlight', '\%'.line('.').'l')<CR>
" clear all the highlighted lines
nnoremap <silent> <leader><leader>H :call clearmatches()<CR>
