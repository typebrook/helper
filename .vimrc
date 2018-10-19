"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Custom Config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set cursorline
set number
set relativenumber
set showcmd
set mouse=a
nmap <c-c> :q<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Open URL under cursor
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Solution is here: https://stackoverflow.com/questions/9458294/
function! HandleURL()
  let s:uri = matchstr(getline("."), '[a-z]*:\/\/[^ >,;]*')
  echo s:uri
  if s:uri != ""
    silent exec "!xdg-open ".s:uri.""
  else
    echo "No URI found in line."
  endif
endfunction
nmap gx :call HandleURL()<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Make Alt key works on Gnome terminal
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Solution is here: https://stackoverflow.com/questions/6778961
let c='a'
while c <= 'z'
  exec "set <A-".c.">=\e".c
  exec "imap \e".c." <A-".c.">"
  let c = nr2char(1+char2nr(c))
endw
set timeout ttimeoutlen=50
 
 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-plug
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugged')

" Add indent line
Plug 'Yggdroot/indentLine'

" Initialize plugin system
call plug#end()
