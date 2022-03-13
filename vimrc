"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Custom Config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set cursorline
set number
set relativenumber
set showcmd
set nowrap
set nostartofline
set sidescroll=1
set sidescrolloff=999
set shell=/bin/bash
" set clipboard=unnamedplus

" general
function! Bye()
    if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 1
        :quit
    else
        :bdelete
    endif
endfunction
nnoremap <silent> <C-C> :call Bye()<CR>
nnoremap <silent> <C-S-C> :q!<CR>
nnoremap <leader>, :.terminal ++noclose<CR>
vnoremap <leader>, :terminal<CR>
nnoremap Y viW:!tee >(xsel -ib)<CR>
vnoremap Y :!tee >(xsel -ib)<CR>
nnoremap <leader>< :%terminal ++noclose<CR>
nnoremap <leader>W :set wrap!<CR>
nnoremap <leader>T :vertical terminal<CR>
nnoremap <C-K> ddkP
nnoremap <C-J> ddp
nnoremap <leader>R :read !
nnoremap <leader>P :r !xsel -ob<CR>
set autoread
set nofoldenable " disable folding

" move
" nnoremap <Tab> }
" nnoremap <S-Tab> {
inoremap <C-L> <Right>
cnoremap <C-L> <Right>
cnoremap <C-H> <Left>
nmap H 0
nnoremap L $
nnoremap <C-L> 60l
nnoremap <C-H> 60h
nnoremap / ms/

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
" next parenthesis
onoremap fp :<c-u>normal! f(vi(<cr> 
onoremap b i{
onoremap fb :<c-u>normal! f{vi{<cr> 
onoremap ab a{
" block
onoremap B /return<CR>

" Search
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>'")

" S&R
nnoremap <leader>; :%s:::g<Left><Left><Left>
vnoremap <leader>; :s:::g<Left><Left><Left>
cnoremap \\ \(\)<Left><Left>

" Fix paste bug triggered by inoremaps
set t_BE=

" surround with charactor
vnoremap ' <ESC>`<i'<ESC>`>la'<ESC>
vnoremap q <ESC>`<i"<ESC>`>la"<ESC>
vnoremap ( <ESC>`<i(<ESC>`>la)<ESC>
vnoremap { <ESC>`<i{<ESC>`>la}<ESC>
vnoremap [ <ESC>`<i[<ESC>`>la]<ESC>
vnoremap ` <ESC>`<i`<ESC>`>la`<ESC>
vnoremap , <ESC>`<i<<ESC>`>la><ESC>
vnoremap 8 <ESC>`<i*<ESC>`>la*<ESC>

" abbrev
iabbrev @@ typebrook@gmail.com

" vim_markdown
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_conceal = 0
vnoremap <C-K> <ESC>`<i[<ESC>`>la]()<ESC>i

" shell script
autocmd FileType sh set shiftwidth=2

" XML fold
let g:xml_syntax_folding=1
autocmd FileType xml setlocal foldmethod=syntax

" JSON fold
let g:json_syntax_folding=1
autocmd FileType json setlocal foldmethod=syntax

" Apply new SniptMat Parser
let g:snipMate = { 'snippet_version' : 1  }

" Set width of mutt as 72
au BufRead /tmp/mutt-* set tw=72

" Redirection with buffer
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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Settings for Vimwiki
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nnoremap <leader>tt :VimwikiTable<CR>
nnoremap <leader>wg :VimwikiGoto 
nnoremap <leader>wT :VimwikiSearchTags 
nnoremap <leader>i I- <esc>l
nnoremap <leader>I :s/^[ ]*- \(\[.\] \)*//<CR>
nmap <leader>D dd:VimwikiMakeDiaryNote<CR>Gp:w!<CR>:Bclose<CR>
vnoremap <leader>D d:VimwikiMakeDiaryNote<CR>Gp:w!<CR>
let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]

" Git push quietly whenever leaving vim with VimWiki files
augroup vimwikiPush
  autocmd!
  autocmd VimLeave ~/vimwiki/* :!(cd ~/vimwiki && git add * && git commit -am update && git push origin >/dev/null 2>&1 &)
augroup END

" Configuration fro vim-instant-markdown
let g:instant_markdown_autostart = 0
nnoremap <leader>md :InstantMarkdownPreview<CR>    

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Settings for Blog
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Generate static pages
augroup blogRebuild
  autocmd!
  autocmd BufWritePost ~/blog/*.md :!(cd ~/blog && hugo &>/dev/null &)
augroup END

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

autocmd FileType rust nmap gd <Plug>(rust-def)
autocmd FileType rust nmap gs <Plug>(rust-def-split)
autocmd FileType rust nmap gx <Plug>(rust-def-vertical)
autocmd FileType rust nmap <leader>gd <Plug>(rust-doc)

 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim-plug
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" run :PlugInstall to install plugins

call plug#begin('~/.vim/plugged')

" Add indent line
Plug 'Yggdroot/indentLine'
Plug 'mileszs/ack.vim'
Plug 'tpope/vim-surround'
"Plug 'lifepillar/pgsql.vim'
Plug 'vimwiki/vimwiki'
"Plug 'iberianpig/tig-explorer.vim'
"Plug 'rust-lang/rust.vim'
"Plug 'racer-rust/vim-racer'
"Plug 'suan/vim-instant-markdown', {'for': 'markdown'}
Plug 'junegunn/fzf.vim'
Plug 'michal-h21/vim-zettel'
Plug 'rlue/vim-barbaric'

" Initialize plugin system
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => lf
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use lf as file selector
function! LF()
    let temp = tempname()
    exec 'silent !lf -selection-path=' . shellescape(temp)
    if !filereadable(temp)
        redraw!
        return
    endif
    let names = readfile(temp)
    if empty(names)
        redraw!
        return
    endif
    exec 'edit ' . fnameescape(names[0])
    for name in names[1:]
        exec 'argadd ' . fnameescape(name)
    endfor
    redraw!
endfunction
command! -bar LF call LF()
" Override NERDTree comes with amix/vimrc
map <leader>nn :LF<cr>
