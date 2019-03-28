"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Custom Config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set cursorline
set number
set relativenumber
set showcmd
set nowrap
set nosol
set ss=1
set siso=999
let g:vim_markdown_conceal = 0

nmap <c-c> :q<cr>
nnoremap <leader>t :.w !bash<cr>
nnoremap <leader>W :set wrap!<cr>
nnoremap <leader>tt :TableFormat<cr>
nnoremap <leader>u :set clipboard=unnamedplus<cr>

let g:vim_markdown_folding_disabled = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" =>  Redirect the output of a Vim or external command into a scratch buffer 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Copy from : https://gist.github.com/romainl/eae0a260ab9c135390c30cd370c20cd7
" Usage:
" 	:Redir hi ............. show the full output of command ':hi' in a scratch window
" 	:Redir !ls -al ........ show the full output of command ':!ls -al' in a scratch window
"
function! Redir(cmd)
	for win in range(1, winnr('$'))
		if getwinvar(win, 'scratch')
			execute win . 'windo close'
		endif
	endfor
	if a:cmd =~ '^!'
		let output = system(matchstr(a:cmd, '^!\zs.*'))
	else
		redir => output
		execute a:cmd
		redir END
	endif
	vnew
	let w:scratch = 1
	setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile
	call setline(1, split(output, "\n"))
endfunction

command! -nargs=1 -complete=command Redir silent call Redir(<q-args>)
nnoremap <leader>r :Redir 


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
" run :PlugInstall to install plugins

call plug#begin('~/.vim/plugged')

" Add indent line
Plug 'Yggdroot/indentLine'
Plug 'mileszs/ack.vim'
Plug 'tpope/vim-surround'
Plug 'lifepillar/pgsql.vim'
Plug 'vimwiki/vimwiki'
Plug 'iberianpig/tig-explorer.vim'

" Initialize plugin system
call plug#end()
