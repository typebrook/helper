"======================================================================
"
" Only for key mapping
"
"   - COMMON_MAPPING
"   - LINKS
"   - MOVING_WITH_READLINE
"   - INSERT_SURROUNDING
"   - JUMP_TO_TABS_WITH_ALT
"   - MANAGE_TABS
"   - MANAGE_BUFFERS
"   - SURROURD_WITH_CHAR
"   - REDIRECTION_WITH_BUFFER
"   - 终端支持
"   - 编译运行
"   - 符号搜索
"
"======================================================================
" vim: set ts=4 sw=4 tw=78 noet :

"----------------------------------------------------------------------
" COMMON_MAPPING
"----------------------------------------------------------------------

" Space for searching
map <space> /

" j/k will move virtual lines (lines that wrap)
noremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
noremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

" Search for selected test
vnoremap * y/\V<C-R>=escape(@",'/\')<CR><CR>

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :nohlsearch<cr>

" Quick move in a line
noremap <C-h> 30h
noremap <C-l> 30l

" Paste register 0
nnoremap <C-p> "0p

" Fast saving
nmap <leader>w :w!<cr>

" Fast quit with error
nmap <leader>q :cq<cr>

" Switch wrap
nmap <leader>W :set wrap!<cr>

" :W sudo saves the file
" (useful for handling the permission-denied error)
command! W execute 'w !sudo -S tee %' <bar> edit!

" New tab like browser
nmap <C-t>n :tabnew<CR>
nmap <C-t>c :tabclose<CR>
nmap <C-t>m :tabmove
nmap <C-t>o :tabonly

" Enter to open file
nnoremap <CR> gf
nnoremap gF :e <cfile><CR>
augroup vimrc_CRfix
  au!
  " Quickfix, Location list, &c. remap <CR> to work as expected
  autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
  autocmd CmdwinEnter * nnoremap <buffer> <CR> <CR>
  autocmd CmdwinEnter * nnoremap <buffer> <C-c> <C-c>
augroup END

" Open terminal
nnoremap <leader>, :terminal ++noclose<CR>
vnoremap <leader>, :terminal<CR>

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<cr>

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Move one line up and down
nnoremap <C-j> ddp
nnoremap <C-k> ddkP

" In case ALT key is not working
" execute "set <M-1>=\e1"
" execute "set <M-2>=\e2"
" execute "set <M-3>=\e3"
" execute "set <M-4>=\e4"
" execute "set <M-5>=\e5"
" execute "set <M-6>=\e6"
" execute "set <M-7>=\e7"
" execute "set <M-8>=\e8"
" execute "set <M-9>=\e9"
" execute "set <M-0>=\e0"
" execute "set <M-f>=\ef"
" execute "set <M-b>=\eb"
" execute "set <M-d>=\ed"
" execute "set <M-l>=\el"
" execute "set <M-h>=\eh"

" Copy from system clipboard
nnoremap <leader>P :r !xsel -ob<CR>
vnoremap Y :w !xsel -ib<CR>

" Spell
nnoremap <leader>ts :set spell!<CR>
nnoremap <leader>ss ]s
nnoremap <leader>S [s

" Show full path by default
nnoremap <C-g> 1<C-g>

" Translate by Google API
vnoremap Tz :!trans -t zh-TW -b<CR>
vnoremap Te :!trans -t en-US -b<CR>

" source .vimrc
nnoremap <leader>so V:so<CR>
nnoremap <leader><leader>so :source ~/.vimrc<CR>
vnoremap so :source<CR>


"----------------------------------------------------------------------
" => Fast editing and reloading of vimrc configs
"----------------------------------------------------------------------
nnoremap <leader>e :edit $MYVIMRC<CR>
autocmd! bufwritepost $MYVIMRC source $MYVIMRC


"----------------------------------------------------------------------
" MOVING_WITH_READLINE
"----------------------------------------------------------------------
inoremap <C-f> <Right>
inoremap <C-b> <Left>
inoremap <C-a> <C-o>0
inoremap <C-e> <C-o>$
inoremap <M-f> <S-Right>
inoremap <M-b> <S-Left>
inoremap <C-d> <del>
inoremap <C-h> <BackSpace>
inoremap <C-j> <Down>
inoremap <C-k> <Up>

set cedit=<C-x>
cnoremap <C-f> <Right>
cnoremap <C-b> <Left>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <M-f> <S-Right>
cnoremap <M-b> <S-Left>
cnoremap <C-d> <Del>
cnoremap <C-r> <C-d>
cnoremap <C-h> <BackSpace>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>
cnoremap <C-k> <C-x>d$<C-c>
cnoremap <M-d> <C-x>de<C-c>

" Moving with wrap
noremap <m-j> gj
noremap <m-k> gk
inoremap <m-j> <c-\><c-o>gj
inoremap <m-k> <c-\><c-o>gk

"----------------------------------------------------------------------
" INSERT_SURROUNDING
"----------------------------------------------------------------------
inoremap ' ''<Left>
inoremap " ""<Left>
inoremap ( ()<Left>
inoremap [ []<Left>
inoremap { {}<Left>

"----------------------------------------------------------------------
" JUMP_TO_TABS_WITH_ALT
"----------------------------------------------------------------------
noremap <silent><A-1> :tabn 1<CR>
noremap <silent><A-2> :tabn 2<CR>
noremap <silent><M-3> :tabn 3<CR>
noremap <silent><M-4> :tabn 4<CR>
noremap <silent><M-5> :tabn 5<CR>
noremap <silent><M-6> :tabn 6<CR>
noremap <silent><M-7> :tabn 7<CR>
noremap <silent><M-8> :tabn 8<CR>
noremap <silent><M-9> :tablast<CR>
inoremap <silent><A-1> <Esc>:tabn 1<CR>
inoremap <silent><A-2> <Esc>:tabn 2<CR>
inoremap <silent><M-3> <Esc>:tabn 3<CR>
inoremap <silent><M-4> <Esc>:tabn 4<CR>
inoremap <silent><M-5> <Esc>:tabn 5<CR>
inoremap <silent><M-6> <Esc>:tabn 6<CR>
inoremap <silent><M-7> <Esc>:tabn 7<CR>
inoremap <silent><M-8> <Esc>:tabn 8<CR>
inoremap <silent><M-9> <Esc>:tablast<CR>


"----------------------------------------------------------------------
" MANAGE_TABS
"----------------------------------------------------------------------

" Useful mappings for managing tabs
map <leader>tn :tabnew<CR>
map <leader>to :tabonly<CR>
map <leader>tc :tabclose<CR>
map <leader>tm :tabmove<SPACE>
noremap <silent><m-h> :call Tab_MoveLeft()<cr>
noremap <silent><m-l> :call Tab_MoveRight()<cr>

" Let <leader>tl toggle between this and the last accessed tab
let g:lasttab = 1
nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
autocmd TabLeave * let g:lasttab = tabpagenr()

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <C-r>=expand("%:p:h")<cr>

" Tab move functions
function! Tab_MoveLeft()
	let l:tabnr = tabpagenr() - 2
	if l:tabnr >= 0
		exec 'tabmove '.l:tabnr
	endif
endfunc
function! Tab_MoveRight()
	let l:tabnr = tabpagenr() + 1
	if l:tabnr <= tabpagenr('$')
		exec 'tabmove '.l:tabnr
	endif
endfunc


"----------------------------------------------------------------------
" MANAGE_BUFFERS
"----------------------------------------------------------------------

" Open a new buffer
nmap <leader>O :e /tmp/buffer<CR>

" Next buffer
noremap <leader>l :bn<CR>

" set filetype
noremap <leader><leader>ft :set filetype=

" Let <leader>l toggle between this and the last accessed buffer
let g:lastbuffer = 1
noremap <Tab> :exe "buffer ".g:lastbuffer<CR>
au BufLeave * let g:lastbuffer = bufnr()

"----------------------------------------------------------------------
" SURROURD_WITH_CHAR
"----------------------------------------------------------------------
vnoremap S sa
vnoremap ' <ESC>`<i'<ESC>`>la'<ESC>
vnoremap q <ESC>`<i"<ESC>`>la"<ESC>
vnoremap ( <ESC>`<i(<ESC>`>la)<ESC>
vnoremap [ <ESC>`<i[<ESC>`>la]<ESC>
vnoremap { <ESC>`<i{<ESC>`>la}<ESC>
vnoremap ` <ESC>`<i`<ESC>`>la`<ESC>
vnoremap <space> <ESC>`<i<space><ESC>`>la<space><ESC>
vnoremap z <ESC>`<i「<ESC>`>la」<ESC>


"----------------------------------------------------------------------
" REDIRECTION_WITH_BUFFER
"----------------------------------------------------------------------
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
nnoremap <leader>rr :Redir

"----------------------------------------------------------------------
" Markdown items (temproray solution)
"----------------------------------------------------------------------

" Toggle list item in markdown: "- [ ] XXX" -> "XXX" -> "- XXX" -> "- [ ] XXX"
" autocmd FileType markdown          nnoremap <buffer> <leader>i V:!sed -E '/^ *- \[.\]/ { s/^( *)- \[.\] */\1/; q; }; /^ *[^[:space:]-]/ { s/^( *)/\1- /; q; }; /^ *- / { s/^( *)- /\1- [ ] /; q; }'<CR><CR>
" autocmd FileType markdown          nnoremap <buffer> <leader>I V:!sed -E 's/^( *)/\1- [ ] /'<CR><CR>

" Toggle task status: "- [ ] " -> "- [x]" -> "- [.] " -> "- [ ] "
" nnoremap <leader>x V:!sed -E '/^ *- \[ \]/ { s/^( *)- \[ \]/\1- [x]/; q; }; /^ *- \[\x\]/ { s/^( *)- \[\x\]/\1- [.]/; q; }; /^ *- \[\.\]/ { s/^( *)- \[\.\]/\1- [ ]/; q; }'<CR><CR>


"----------------------------------------------------------------------
" Common command
"----------------------------------------------------------------------
" Show date selector
nnoremap <leader>dd :r !sh -c 'LANG=en zenity --calendar --date-format="\%Y.\%m.\%d" 2>/dev/null'<CR><CR>
nnoremap <leader>dD :r !sh -c 'LANG=en zenity --calendar --date-format="\%a \%b \%d" 2>/dev/null'<CR><CR>
nnoremap <leader>dt :r !date +\%H:\%m<CR>A


"----------------------------------------------------------------------
" 窗口切换：ALT+SHIFT+hjkl
" 传统的 CTRL+hjkl 移动窗口不适用于 vim 8.1 的终端模式，CTRL+hjkl 在
" bash/zsh 及带文本界面的程序中都是重要键位需要保留，不能 tnoremap 的
"----------------------------------------------------------------------
noremap <m-H> <c-w>h
noremap <m-L> <c-w>l
noremap <m-J> <c-w>j
noremap <m-K> <c-w>k
inoremap <m-H> <esc><c-w>h
inoremap <m-L> <esc><c-w>l
inoremap <m-J> <esc><c-w>j
inoremap <m-K> <esc><c-w>k

if has('terminal') && exists(':terminal') == 2 && has('patch-8.1.1')
	" vim 8.1 支持 termwinkey ，不需要把 terminal 切换成 normal 模式
	" 设置 termwinkey 为 CTRL 加减号（GVIM），有些终端下是 CTRL+?
	" 后面四个键位是搭配 termwinkey 的，如果 termwinkey 更改，也要改
	set termwinkey=<c-_>
	tnoremap <m-H> <c-_>h
	tnoremap <m-L> <c-_>l
	tnoremap <m-J> <c-_>j
	tnoremap <m-K> <c-_>k
	tnoremap <m-q> <c-\><c-n>
elseif has('nvim')
	" neovim 没有 termwinkey 支持，必须把 terminal 切换回 normal 模式
	tnoremap <m-H> <c-\><c-n><c-w>h
	tnoremap <m-L> <c-\><c-n><c-w>l
	tnoremap <m-J> <c-\><c-n><c-w>j
	tnoremap <m-K> <c-\><c-n><c-w>k
	tnoremap <m-q> <c-\><c-n>
endif



"----------------------------------------------------------------------
" 编译运行 C/C++ 项目
" 详细见：http://www.skywind.me/blog/archives/2084
"----------------------------------------------------------------------

" 自动打开 quickfix window ，高度为 6
let g:asyncrun_open = 6

" 任务结束时候响铃提醒
let g:asyncrun_bell = 1

" 设置 F10 打开/关闭 Quickfix 窗口
nnoremap <F10> :call asyncrun#quickfix_toggle(6)<cr>

" F9 编译 C/C++ 文件
nnoremap <silent> <F9> :AsyncRun gcc -Wall -O2 "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>

" F5 运行文件
nnoremap <silent> <F5> :call ExecuteFile()<cr>

" F7 编译项目
nnoremap <silent> <F7> :AsyncRun -cwd=<root> make <cr>

" F8 运行项目
nnoremap <silent> <F8> :AsyncRun -cwd=<root> -raw make run <cr>

" F6 测试项目
nnoremap <silent> <F6> :AsyncRun -cwd=<root> -raw make test <cr>

" 更新 cmake
nnoremap <silent> <F4> :AsyncRun -cwd=<root> cmake . <cr>

" Windows 下支持直接打开新 cmd 窗口运行
if has('win32') || has('win64')
	nnoremap <silent> <F8> :AsyncRun -cwd=<root> -mode=4 make run <cr>
endif


"----------------------------------------------------------------------
" F5 运行当前文件：根据文件类型判断方法，并且输出到 quickfix 窗口
"----------------------------------------------------------------------
function! ExecuteFile()
	let cmd = ''
	if index(['c', 'cpp', 'rs', 'go'], &ft) >= 0
		" native 语言，把当前文件名去掉扩展名后作为可执行运行
		" 写全路径名是因为后面 -cwd=? 会改变运行时的当前路径，所以写全路径
		" 加双引号是为了避免路径中包含空格
		let cmd = '"$(VIM_FILEDIR)/$(VIM_FILENOEXT)"'
	elseif &ft == 'python'
		let $PYTHONUNBUFFERED=1 " 关闭 python 缓存，实时看到输出
		let cmd = 'python "$(VIM_FILEPATH)"'
	elseif &ft == 'javascript'
		let cmd = 'node "$(VIM_FILEPATH)"'
	elseif &ft == 'perl'
		let cmd = 'perl "$(VIM_FILEPATH)"'
	elseif &ft == 'ruby'
		let cmd = 'ruby "$(VIM_FILEPATH)"'
	elseif &ft == 'php'
		let cmd = 'php "$(VIM_FILEPATH)"'
	elseif &ft == 'lua'
		let cmd = 'lua "$(VIM_FILEPATH)"'
	elseif &ft == 'zsh'
		let cmd = 'zsh "$(VIM_FILEPATH)"'
	elseif &ft == 'ps1'
		let cmd = 'powershell -file "$(VIM_FILEPATH)"'
	elseif &ft == 'vbs'
		let cmd = 'cscript -nologo "$(VIM_FILEPATH)"'
	elseif &ft == 'sh'
		let cmd = 'bash "$(VIM_FILEPATH)"'
	else
		return
	endif
	" Windows 下打开新的窗口 (-mode=4) 运行程序，其他系统在 quickfix 运行
	" -raw: 输出内容直接显示到 quickfix window 不匹配 errorformat
	" -save=2: 保存所有改动过的文件
	" -cwd=$(VIM_FILEDIR): 运行初始化目录为文件所在目录
	if has('win32') || has('win64')
		exec 'AsyncRun -cwd=$(VIM_FILEDIR) -raw -save=2 -mode=4 '. cmd
	else
		exec 'AsyncRun -cwd=$(VIM_FILEDIR) -raw -save=2 -mode=0 '. cmd
	endif
endfunc



"----------------------------------------------------------------------
" F2 在项目目录下 Grep 光标下单词，默认 C/C++/Py/Js ，扩展名自己扩充
" 支持 rg/grep/findstr ，其他类型可以自己扩充
" 不是在当前目录 grep，而是会去到当前文件所属的项目目录 project root
" 下面进行 grep，这样能方便的对相关项目进行搜索
"----------------------------------------------------------------------
if executable('rg')
	noremap <silent><F2> :AsyncRun! -cwd=<root> rg -n --no-heading 
				\ --color never -g *.h -g *.c* -g *.py -g *.js -g *.vim 
				\ <C-R><C-W> "<root>" <cr>
elseif has('win32') || has('win64')
	noremap <silent><F2> :AsyncRun! -cwd=<root> findstr /n /s /C:"<C-R><C-W>" 
				\ "\%CD\%\*.h" "\%CD\%\*.c*" "\%CD\%\*.py" "\%CD\%\*.js"
				\ "\%CD\%\*.vim"
				\ <cr>
else
	noremap <silent><F2> :AsyncRun! -cwd=<root> grep -n -s -R <C-R><C-W> 
				\ --include='*.h' --include='*.c*' --include='*.py' 
				\ --include='*.js' --include='*.vim'
				\ '<root>' <cr>
endif
