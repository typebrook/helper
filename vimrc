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

" general
nmap <c-c> :q<cr>
nnoremap <leader>R :.w !bash<cr>
nnoremap <leader>, :w !bash<cr>
nnoremap <leader>W :set wrap!<cr>
nnoremap <leader>T :vertical terminal<cr>
nnoremap <leader>u :set clipboard=unnamedplus<cr>
nnoremap <CR> o<Esc>

nnoremap <C-K> ddkP
nnoremap <C-J> ddp
nnoremap <silent> <leader>s
             \ : if exists("syntax_on") <BAR>
             \    syntax off <BAR>
             \ else <BAR>
             \    syntax enable <BAR>
             \ endif<CR>
nnoremap <leader>S :echo join(reverse(map(synstack(line('.'), col('.')), 'synIDattr(v:val,"name")')),' ')<cr>

onoremap p i(

" vimwiki
nnoremap <leader>tt :VimwikiTable<cr>
nnoremap <leader>wg :VimwikiGoto 
nnoremap <leader>a :VimwikiSearchTags 
nnoremap <leader>i I- <esc>l
let g:vimwiki_list = [{'path': '~/vimwiki/', 'auto_tags': 1}]

augroup vimwikiPush
  autocmd!
  autocmd VimLeave ~/vimwiki/* :!(~/vimwiki/scripts/upload.sh > /dev/null 2>&1 &)
augroup END

" vim_markdown
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_conceal = 0

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
" => vim-racer
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set hidden
let g:racer_cmd = "~/.cargo/bin/racer"
let g:racer_experimental_completer = 1

au FileType rust nmap gd <Plug>(rust-def)
au FileType rust nmap gs <Plug>(rust-def-split)
au FileType rust nmap gx <Plug>(rust-def-vertical)
au FileType rust nmap <leader>gd <Plug>(rust-doc)

 
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
Plug 'rust-lang/rust.vim'
Plug 'racer-rust/vim-racer'

" Initialize plugin system
call plug#end()
