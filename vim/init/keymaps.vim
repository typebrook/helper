"======================================================================
" Only for key mapping
"======================================================================
" vim: sw=2 ts=2 foldmethod=marker foldmarker={{{,}}}

" COMMON_MAPPING {{{

" Space for searching
map <space> /

" Escape normal mode by <C-c>
inoremap <C-c> <Esc>l

" Set wrap
nnoremap \w :set wrap!<CR>

" Fast saving
function! s:WriteOrEnterFileName()
  if !empty(expand('%')) | write! | else | call feedkeys(":w ") | endif
endfunction
nnoremap <leader>w :call <SID>WriteOrEnterFileName()<CR>

" :W sudo saves the file
" (useful for handling the permission-denied error)
command! W execute 'w !sudo -S tee %' <bar> edit!

" Quit
nnoremap <leader>q :q<CR>
nnoremap cq :cq<CR>

" Remap <CR> in Quickfix, Cmdwin Location list
augroup vimrc_CRfix
  au!
  autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
  autocmd CmdwinEnter * nnoremap <buffer> <CR> <CR>
  autocmd CmdwinEnter * nnoremap <buffer> <C-c> <C-c>
augroup END

" Spell
nnoremap \s :set spell!<CR>:set spell?<CR>
nnoremap <leader>ss ]s
nnoremap <leader>S [s

" Show full path by default
nnoremap <C-g> 1<C-g>

" Translate by Google API
vnoremap Tz :!trans -t zh-TW -b<CR>
vnoremap Te :!trans -t en-US -b<CR>

let g:alacritty_extra_padding = 0
function! ToggleWinPadding()
  if g:alacritty_extra_padding
    !alacritty msg config --window-id $WINDOWID --reset
  else
    redir => output | hi LineNr | redir END
    let bg_color = matchstr(output, 'guibg=\zs[^\s]\+\ze')
    exe "hi EndOfBuffer guifg="..bg_color.." guibg="..bg_color
    exe "!alacritty msg config --window-id $WINDOWID window.padding.x=300 'colors.primary.background=\"\\"..bg_color.."\"'"
  endif

  let g:alacritty_extra_padding = !g:alacritty_extra_padding
endfunc
nnoremap <leader>z <Cmd>silent call ToggleWinPadding()<CR>

" }}}
" WORKING_DIR {{{

let g:last_path = execute("pwd")
augroup SaveLatestDir
  au!
  autocmd DirChangedPre * let g:last_path = split(execute('pwd'), "\n")[0]
augroup END

" Switch CWD to the directory of the open buffer
nnoremap cd :cd %:p:h<CR>:pwd<CR>

nnoremap cd<space> :cd<space>
nnoremap cdg :call CdToGitRepo()<CR>:pwd<CR>
nnoremap <C-[> :cd ..<CR>:pwd<CR>
nnoremap <C-]> :call InCaseCdToLatestDir()<CR>

" Switch CWD to root git directory
function! CdToGitRepo()
  let l:git_dir = finddir('.git', escape(expand('%:p:h'), ' ') . ';')
  let l:repo = fnameescape(fnamemodify(l:git_dir, ':h'))
  execute "cd" l:repo
endfunction

function! InCaseCdToLatestDir()
  try
    execute "norm! \<C-]>"
  catch
    cd -
    pwd
  endtry
endfunction

" }}}
" MOTION {{{

" j/k will move virtual lines (lines that wrap)
nnoremap <silent> <expr> j (v:count == 0 ? 'gj' : 'j')
nnoremap <silent> <expr> k (v:count == 0 ? 'gk' : 'k')

" Quick move in a line
nnoremap <C-h> 30h
nnoremap <C-l> 30l

" File under the cursor
nnoremap <CR> gf
nnoremap gF :e <cfile><CR>

xnoremap iq i"
xnoremap aq a"


" READLINE_FEATURES {{{

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
" cnoremap <C-r> <C-d>
cnoremap <C-h> <BackSpace>
cnoremap <C-n> <Down>
cnoremap <C-p> <Up>
cnoremap <C-k> <C-x>d$<C-c>
cnoremap <M-d> <C-x>de<C-c>

" Moving with wrap
nnoremap <m-j> gj
nnoremap <m-k> gk
inoremap <m-j> <c-\><c-o>gj
inoremap <m-k> <c-\><c-o>gk
" }}}
" JUMP_TO_TABS_WITH_ALT {{{

nnoremap <silent><A-1> :tabn 1<CR>
nnoremap <silent><A-2> :tabn 2<CR>
nnoremap <silent><M-3> :tabn 3<CR>
nnoremap <silent><M-4> :tabn 4<CR>
nnoremap <silent><M-5> :tabn 5<CR>
nnoremap <silent><M-6> :tabn 6<CR>
nnoremap <silent><M-7> :tabn 7<CR>
nnoremap <silent><M-8> :tabn 8<CR>
nnoremap <silent><M-9> :tablast<CR>
inoremap <silent><A-1> <Esc>:tabn 1<CR>
inoremap <silent><A-2> <Esc>:tabn 2<CR>
inoremap <silent><M-3> <Esc>:tabn 3<CR>
inoremap <silent><M-4> <Esc>:tabn 4<CR>
inoremap <silent><M-5> <Esc>:tabn 5<CR>
inoremap <silent><M-6> <Esc>:tabn 6<CR>
inoremap <silent><M-7> <Esc>:tabn 7<CR>
inoremap <silent><M-8> <Esc>:tabn 8<CR>
inoremap <silent><M-9> <Esc>:tablast<CR>

" }}}

" }}}
" REGISTER {{{
" Paste register 0
nnoremap <C-p> "0p

" Toggle paste mode on and off
map <leader>pp :setlocal paste!<CR>

" Copy from system clipboard
nnoremap gp "+p
vnoremap Y "+y

" }}}
" MARKS {{{

" Delete mark
function! DeleteMark(mark)
  let mark = nr2char(a:mark)
  if mark =~ '[a-z]'
    execute "delmarks " . mark
  endif
endfunction
nnoremap dm :call DeleteMark(getchar())<CR>

"}}}
" EDIT {{{

" Move one line up and down
nnoremap <C-j> ddp
nnoremap <C-k> ddkP

" Clear current line
nnoremap S S<ESC>

" }}}
" TERMINAL {{{

" In case ALT key is not working
" execute "set <M-2>=\e2"
" execute "set <M-1>=\e1"
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

"}}}
" MANAGE_VIMRC {{{

" source .vimrc
nnoremap <leader>so V:so<CR>
nnoremap <leader><leader>so :source %<CR>
vnoremap so :source<CR>
autocmd! BUFWRITEPOST $MYVIMRC source $MYVIMRC

"  Find scripts
nnoremap <leader>e :scriptnames<space>
nnoremap <leader>ee :edit $MYVIMRC<CR>

" }}}
" MANAGE_BUFFERS {{{

" Set options
nnoremap so :set<space>
nnoremap <leader><leader>ft :<C-\>e'set filetype='..&filetype<CR>
nnoremap <leader><leader>sw :<C-\>e'set shiftwidth='..&shiftwidth<CR>
nnoremap <leader><leader>ts :<C-\>e'set tabstop='..&tabstop<CR>
nnoremap \e :set expandtab!<CR>:set expandtab?<CR>
nnoremap \l :set list!<CR>:set list?<CR>
nnoremap \n :set nu!<CR>:set nu?<CR>
nnoremap \r :set relativenumber!<CR>:set rnu?<CR>

" Open a new buffer
nnoremap <leader>B :enew<CR>
nnoremap <leader>O :e /tmp/buffer<CR>

" Let <leader>l toggle between this and the last accessed buffer
augroup SaveLastBuffer
  let g:lastbuffer = 1
  au BufLeave * if &buflisted | let g:lastbuffer = expand('<abuf>') | endif
augroup END
nnoremap <leader>l :exe "buffer ".g:lastbuffer<CR>

" Use Ctrl-C for buffer delete or quit vim {{{

" Toggle behavior for the last buffer in the last window
let g:quitVimWhenPressingCtrlC = 1
function! ToggleQuit()
  let g:quitVimWhenPressingCtrlC = !g:quitVimWhenPressingCtrlC
  let message = g:quitVimWhenPressingCtrlC ? "Unlock" : "Lock"
  echo message
endfunction
nnoremap \q :call ToggleQuit()<CR>

func! QuitWithCheck()
  if g:quitVimWhenPressingCtrlC
    silent! quit
  else
    echo "Press \\q to allow quit with <C-c>"
  endif
endfunc
function! CloseBufferSafely()
  " Ask Saving
  if &modified
    let answer = confirm("Save changes?", "&Yes\n&No\n&Cancel")
    if answer == 1 | write | endif
    if answer == 3 | return | endif
    if answer == "" | return | endif
  endif

  let l:bufnr = bufnr()

  if len(t:bufs) == 1
    " Close tab for last buffer
    tabclose
  else
    " Switch to proper buffer
    let l:next_buf = get(t:bufs, bufnr('#')) ? bufnr('#') : filter(t:bufs, 'v:val != '..l:bufnr)[0]
    exe "b "..l:next_buf
    call filter(t:bufs, 'v:val != '..l:bufnr)
  endif

  " Delete buffer if every t:buf doesn't have it
  for tab in gettabinfo()
    if get(tab.variables.bufs, l:bufnr) | return | endif
  endfor
  exe "bd! "..l:bufnr

endfunction
function! Bye()
  let windows = gettabinfo(tabpagenr())[0]['windows']

  if len(t:bufs) <= 1 && len(windows) == 1
    call QuitWithCheck()
  elseif &diff
    silent call CloseBuffersForDiff()
  elseif len(windows) >1
    quit
  else
    call CloseBufferSafely()
    " silent! call CloseBufferSafely()
  endif
endfunction
nnoremap <silent> <C-c> :call Bye()<CR>

" }}}
" Diff Mode {{{

function! CloseBuffersForDiff()
  windo | if &diff && &buftype == "nofile" | bdelete | endif
  norm! zv
endfunction

command! DiffOrig vert new | set buftype=nofile nobuflisted | read ++edit # | 0d_
      \ | diffthis | wincmd p | diffthis

" Uset <C-w>d to toggle Diff mode
function! s:SwitchDiff()
  if &diff
    call CloseBuffersForDiff()
  else
    DiffOrig
  endif
endfunction
com! SwitchDiff call s:SwitchDiff()
nnoremap <C-w>d <Cmd>silent! SwitchDiff<CR>

function! s:SwitchDiffForGitHEAD()
  norm cdg
  if &diff
    windo | if &buftype == "nofile" | bdelete | endif
    norm! zv
  else
    vert new | set buftype=nofile nobuflisted
    read !git show HEAD:#
    0d_ | diffthis | wincmd p | diffthis
  endif
endfunction
command! SwitchDiffForGitHEAD call s:SwitchDiffForGitHEAD()
nnoremap <C-w>D <Cmd>silent! SwitchDiffForGitHEAD<CR>

" }}}

" }}}
" MANAGE_WINDOWS {{{

nnoremap <leader><leader>sb :windo set scrollbind!<CR>

" 窗口切换：ALT+SHIFT+hjkl
" 传统的 CTRL+hjkl 移动窗口不适用于 vim 8.1 的终端模式，CTRL+hjkl 在
" bash/zsh 及带文本界面的程序中都是重要键位需要保留，不能 tnoremap 的
"----------------------------------------------------------------------
nnoremap <m-H> <c-w>h
nnoremap <m-L> <c-w>l
nnoremap <m-J> <c-w>j
nnoremap <m-K> <c-w>k
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
" }}}
" MANAGE_TABS {{{

" Useful mappings for managing tabs
map <leader>tn :tabnew<CR>
map <leader>tc :tabclose<CR>
map <leader>tm :tabmove<SPACE>
map <leader>to :tabonly<CR>

nnoremap <silent><m-h> :call Tab_MoveLeft()<CR>
nnoremap <silent><m-l> :call Tab_MoveRight()<CR>

" Let <leader>tl toggle between this and the last accessed tab
let g:lasttab = 1
nnoremap <Leader>tl :exe "tabn ".g:lasttab<CR>
autocmd TabLeave * let g:lasttab = tabpagenr()

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <C-r>=expand("%:p:h")<CR>

" Tab move functions
function! Tvab_MoveLeft()
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
" }}}
" FOLD {{{

" Set fold options
nnoremap <leader><leader>fm :<C-\>e'set foldmethod='..&foldmethod<CR>
nnoremap <leader><leader>fc :<C-\>e'set foldcolumn='..&foldcolumn<CR>

" Toggle fold and foldcolumn
nnoremap <expr> zi "zizz:silent set foldcolumn="..(&foldenable ? "0" : "auto:3").."\<CR>"

" Show fold level when it changes
nnoremap zm zm:set foldlevel?<CR>
nnoremap zr zr:set foldlevel?<CR>

" Fold all except selection
vnoremap zF :<C-u>call ToggleUnfoldSelection()<CR>
" Resume
nnoremap zF :call ToggleUnfoldSelection()<CR>zv

nnoremap \z :call GrayOutOtherFolds()<CR>

" Select current fold
onoremap az :<C-U>silent! keepjumps normal![zV]z<CR>
xnoremap az :<C-U>silent! keepjumps normal![zV]z<CR>
onoremap iz :<C-U>silent! keepjumps normal![zjV]zk<CR>
xnoremap iz :<C-U>silent! keepjumps normal![zjV]zk<CR>

" Use l to open fold
nnoremap <expr> l foldclosed('.') == -1 ? 'l' : 'zo'

" Open fold in next line
nnoremap <expr> zo foldclosed('.') == -1 ? 'zjzo' : 'zo'
nnoremap <expr> zO foldclosed('.') == -1 ? 'zjzO' : 'zO'

" Go to next fold and unfold
nnoremap zJ zjzx
nnoremap zK zkzx

" Fold file except selection
autocmd BufEnter * let b:unfold_selection = 0
function! ToggleUnfoldSelection()
  if !b:unfold_selection
    let b:unfold_selection = 1
    mkview
    echo 'Unfold'..&foldmethod

    let &foldmethod = "manual"
    norm! zE
    execute "0,'<-1fold"
    execute "'>+1,$fold"
  else
    let b:unfold_selection = 0
    loadview
  endif
endfunction

autocmd BufEnter * let b:clear_matches = 0
function! GrayOutOtherFolds()
  if b:clear_matches
    let b:clear_matches = 0
    call clearmatches()
  else
    let b:clear_matches = 1
    let pos = getpos('.')
    exe "norm! [zV]z\<C-c>"
    call matchadd('Folded', '\%<'.line("'<").'l')
    call matchadd('Folded', '\%>'.line("'>").'l')
    norm! zR
    call setpos('.', pos)
  endif
endfunction

" }}}
" HIGHLIGHT {{{

" Disable highlight when <leader><CR> is pressed
nnoremap <silent> <leader><CR> :noh<CR>

function! HiFile()
  let i = 1
  while i <= line("$")
    if strlen(getline(i)) > 0 && len(split(getline(i))) > 2
      let w = split(getline(i))[0]
      let l:command =  "syn match " . w . " /^" . w . "\\s\\+xxx/"
      exe l:command
    endif
    let i += 1
  endwhile
endfunction

function! GetHighlightGroupName()
  let l:syntaxID = synID(line('.'), col('.'), 1)
  let l:groupName = synIDattr(l:syntaxID, 'name')
  echo l:groupName
endfunction
nnoremap <leader>H :call GetHighlightGroupName()<CR>

" Persist visualized lines
" define line highlight color
highlight MultiLineHighlight ctermbg=LightYellow guibg=LightYellow ctermfg=Black guifg=Black
" highlight the current line
nnoremap <silent> <leader>gh :call matchadd('MultiLineHighlight', '\%'.line('.').'l')<CR>
" clear all the highlighted lines
nnoremap <silent> <leader>gH :call clearmatches()<CR>

" }}}
" SURROUND {{{

inoremap ' ''<Left>
inoremap " ""<Left>
inoremap ( ()<Left>
inoremap [ []<Left>
inoremap { {}<Left>

vnoremap ' <ESC>`<i'<ESC>`>la'<ESC>
vnoremap q <ESC>`<i"<ESC>`>la"<ESC>
vnoremap ( <ESC>`<i(<ESC>`>la)<ESC>
vnoremap [ <ESC>`<i[<ESC>`>la]<ESC>
vnoremap { <ESC>`<i{<ESC>`>la}<ESC>
vnoremap ` <ESC>`<i`<ESC>`>la`<ESC>
vnoremap Q <ESC>`<i「<ESC>`>la」<ESC>

function! AddSpaceForSelection()
  " If visual selection by lines, add empty space at top and bottom
  if line("'<") != line("'>") || (col("'<") == 1 && col("'>") == len(getline('.'))+1)
    '< norm! O
    '> norm! o
    exe "norm! "..(line("'<")-1).."GV"..(line("'>")+1).."G"
    " Otherwise, add space at start and end column
  else
    call cursor('.', col("'<"))
    execute "norm! i\<space>"
    call cursor('.', col("'>")+1)
    execute "norm! a\<space>"
  endif
endfunction
vnoremap <space> :<C-u>call AddSpaceForSelection()<CR>

" }}}
" QUICKFIX {{{

nnoremap <leader>cn :cn<CR>
nnoremap <leader>cp :cp<CR>
nnoremap <leader>cw :cw 10<CR>

" }}}
" REDIRECTION_WITH_BUFFER {{{

" Usage:
" 	:Redir hi ............. show the full output of command ':hi' in a scratch window
" 	:Redir !ls -al ........ show the full output of command ':!ls -al' in a scratch window
"
function! Redir(cmd)
  if a:cmd =~ '^!'
    let output = system(matchstr(a:cmd, '^!\zs.*'))
  else
    redir => output
    execute a:cmd
    redir END
  endif
  enew
  let w:scratch = 1
  setlocal buftype=nofile noswapfile
  call setline(1, split(output, "\n"))
endfunction

command! -nargs=1 -complete=command Redir silent call Redir(<q-args>)
command! -nargs=1 -complete=command R silent call Redir(<q-args>)
nnoremap <leader>rr :Redir<space>
" }}}
" SEARCH/SUBSTITUTE {{{

" Search for selected test
vnoremap * y/\V<C-R>=escape(@",'/\')<CR><CR>

nnoremap g/ gv<esc>/\%V
vnoremap g/ <esc>/\%V

" Substitue across file
vnoremap <leader>s y:%s//<C-R>0/g<LEFT><LEFT>

" Usage: Press <TAB> n times for area, and <CR> for substitute
let g:search_selection = 0
" When leaving visual mode, resume search_selection
autocmd Modechanged [vV\x16]*:* let g:search_selection = 0
xmap <expr> <TAB> g:search_selection ? "//e<CR>" : "*:let g:search_selection = 1<CR>gv//e<CR>"
xmap <expr> <S-TAB> g:search_selection ? "??<CR>" : "*:let g:search_selection = 1<CR>gv??<CR>" 
vnoremap <CR> :s//<C-R>0/g<Left><Left>

" }}}
" SIGN {{{

nnoremap <leader><leader>sc :<C-\>e'set signcolumn='..&signcolumn<CR>

nnoremap <leader>si :exe ":sign place " .. line('.') .. " line=" .. line('.') .. " name=piet file=" .. expand("%:p")<CR>
nnoremap <leader>sI :exe ":sign unplace * file=" .. expand("%:p")<CR>

" }}}
" GIT_TIG {{{

let g:tig_explorer_keymap_commit_split   = '<C-s>'
let g:tig_explorer_keymap_commit_vsplit  = '<C-v>'
nnoremap <C-t> <Cmd>Tig<CR>
nnoremap <C-t>s <Cmd>TigStatus<CR>
nnoremap <C-t>b <Cmd>TigBlame<CR>

" }}}
" Tmp: Markdown items (temproray solution) {{{

" Toggle list item in markdown: "- [ ] XXX" -> "XXX" -> "- XXX" -> "- [ ] XXX"
" autocmd FileType markdown          nnoremap <buffer> <leader>i V:!sed -E '/^ *- \[.\]/ { s/^( *)- \[.\] */\1/; q; }; /^ *[^[:space:]-]/ { s/^( *)/\1- /; q; }; /^ *- / { s/^( *)- /\1- [ ] /; q; }'<CR><CR>
" autocmd FileType markdown          nnoremap <buffer> <leader>I V:!sed -E 's/^( *)/\1- [ ] /'<CR><CR>

" Toggle task status: "- [ ] " -> "- [x]" -> "- [.] " -> "- [ ] "
" nnoremap <leader>x V:!sed -E '/^ *- \[ \]/ { s/^( *)- \[ \]/\1- [x]/; q; }; /^ *- \[\x\]/ { s/^( *)- \[\x\]/\1- [.]/; q; }; /^ *- \[\.\]/ { s/^( *)- \[\.\]/\1- [ ]/; q; }'<CR><CR>
" }}}
" Tmp: Common system command {{{
" Show date selector
nnoremap <leader>dd :r !sh -c 'LANG=en zenity --calendar --date-format="\%Y.\%m.\%d" 2>/dev/null'<CR><CR>
nnoremap <leader>dD :r !sh -c 'LANG=en zenity --calendar --date-format="\%a \%b \%d" 2>/dev/null'<CR><CR>
nnoremap <leader>dt :r !date +\%H:\%m<CR>A

" }}}
" Tmp: Compile {{{

" 编译运行 C/C++ 项目
" 详细见：http://www.skywind.me/blog/archives/2084
"----------------------------------------------------------------------

" 自动打开 quickfix window ，高度为 6
let g:asyncrun_open = 6

" 任务结束时候响铃提醒
let g:asyncrun_bell = 1

" 设置 F10 打开/关闭 Quickfix 窗口
nnoremap <F10> :call asyncrun#quickfix_toggle(6)<CR>

" F9 编译 C/C++ 文件
nnoremap <silent> <F9> :AsyncRun gcc -Wall -O2 "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <CR>

" F5 运行文件
nnoremap <silent> <F5> :call ExecuteFile()<CR>

" F7 编译项目
nnoremap <silent> <F7> :AsyncRun -cwd=<root> make <CR>

" F8 运行项目
nnoremap <silent> <F8> :AsyncRun -cwd=<root> -raw make run <CR>

" F6 测试项目
nnoremap <silent> <F6> :AsyncRun -cwd=<root> -raw make test <CR>

" 更新 cmake
nnoremap <silent> <F4> :AsyncRun -cwd=<root> cmake . <CR>

" Windows 下支持直接打开新 cmd 窗口运行
if has('win32') || has('win64')
  nnoremap <silent> <F8> :AsyncRun -cwd=<root> -mode=4 make run <CR>
endif


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



" F2 在项目目录下 Grep 光标下单词，默认 C/C++/Py/Js ，扩展名自己扩充
" 支持 rg/grep/findstr ，其他类型可以自己扩充
" 不是在当前目录 grep，而是会去到当前文件所属的项目目录 project root
" 下面进行 grep，这样能方便的对相关项目进行搜索
"----------------------------------------------------------------------
if executable('rg')
  noremap <silent><F2> :AsyncRun! -cwd=<root> rg -n --no-heading
        \ --color never -g *.h -g *.c* -g *.py -g *.js -g *.vim
        \ <C-R><C-W> "<root>" <CR>
elseif has('win32') || has('win64')
  noremap <silent><F2> :AsyncRun! -cwd=<root> findstr /n /s /C:"<C-R><C-W>"
        \ "\%CD\%\*.h" "\%CD\%\*.c*" "\%CD\%\*.py" "\%CD\%\*.js"
        \ "\%CD\%\*.vim"
        \ <CR>
else
  noremap <silent><F2> :AsyncRun! -cwd=<root> grep -n -s -R <C-R><C-W>
        \ --include='*.h' --include='*.c*' --include='*.py'
        \ --include='*.js' --include='*.vim'
        \ '<root>' <CR>
endif

" }}}
