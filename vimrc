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
nmap <C-C> :q<CR>
nnoremap <leader>, :w !bash<CR>
nnoremap <leader>W :set wrap!<CR>
nnoremap <leader>T :vertical terminal<CR>
nnoremap <leader>u :set clipboard=unnamedplus<CR>
nnoremap <C-K> ddkP
nnoremap <C-J> ddp
" disable syntax
nnoremap <silent> <leader>s
             \ : if exists("syntax_on") <BAR>
             \    syntax off <BAR>
             \ else <BAR>
             \    syntax enable <BAR>
             \ endif<CR>
" show current syntax
nnoremap <leader>S :echo join(reverse(map(synstack(line('.'), col('.')), 'synIDattr(v:val,"name")')),' ')<CR>

" Operator pending
onoremap p i(
onoremap ap a(
onoremap np :<c-u>normal! f(vi(<cr>
onoremap b /return<CR>

" S&R
nnoremap <leader>; :%s:::g<Left><Left><Left>
vnoremap <leader>; :s:::g<Left><Left><Left>
cmap ;\ \(\)<Left><Left>

" 習慣成自然
nnoremap H 0
nnoremap L $
nnoremap <C-L> 60l
nnoremap <C-H> 60h
" inoremap <ESC> <nop>

" Fix paste bug triggered by inoremaps
set t_BE=

" surround with '' or ""
nnoremap <leader>' ea'<esc>bi'<esc>e
nnoremap <leader>" ea"<esc>bi"<esc>e
vnoremap ' <ESC>`<i'<ESC>`>la'<ESC>
vnoremap " <ESC>`<i"<ESC>`>la"<ESC>

" abbrev
iabbrev @@ typebrook@gmail.com

" vim_markdown
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_conceal = 0

" xml fold
let g:xml_syntax_folding=1
au FileType xml setlocal foldmethod=syntax

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Settings for Vimwiki
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nnoremap <leader>tt :VimwikiTable<CR>
nnoremap <leader>wg :VimwikiGoto 
nnoremap <leader>wa :VimwikiSearchTags 
nnoremap <leader>i I- <esc>l
nnoremap <leader>ii I- [ ] <esc>l
let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]

" Git push quietly whenever leaving vim after editing Vimwiki
augroup vimwikiPush
  autocmd!
  autocmd VimLeave ~/vimwiki/* :!(~/vimwiki/scripts/upload.sh > /dev/null 2>&1 &)
augroup END

" Configuration fro vim-instant-markdown
let g:instant_markdown_autostart = 0
nnoremap <leader>md :InstantMarkdownPreview<CR>    


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" =>  Redirect the output of a Vim or external command into a scratch buffer 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Copy from : https://gist.github.com/romainl/eae0a260ab9c135390c30cd370c20cd7
" 
" Usage:
" 	:Redir hi ............. show the full output of command ':hi' in a scratch window
" 	:Redir !ls -al ........ show the full output of command ':!ls -al' in a scratch window

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
Plug 'suan/vim-instant-markdown', {'for': 'markdown'}

" Initialize plugin system
call plug#end()
