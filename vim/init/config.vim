"======================================================================
"
" init-config.vim - 正常模式下的配置，在 init-basic.vim 后调用
"
" Created by skywind on 2018/05/30
" Last Modified: 2018/05/30 19:20:46
"
"======================================================================


"----------------------------------------------------------------------
" 有 tmux 何没有的功能键超时（毫秒）
"----------------------------------------------------------------------
if $TMUX != ''
  set ttimeoutlen=30
elseif &ttimeoutlen > 80 || &ttimeoutlen <= 0
  set ttimeoutlen=80
endif


"----------------------------------------------------------------------
" 终端下允许 ALT，详见：http://www.skywind.me/blog/archives/2021
" 记得设置 ttimeout （见 init-basic.vim） 和 ttimeoutlen （上面）
"----------------------------------------------------------------------
if has('nvim') == 0 && has('gui_running') == 0
  function! s:metacode(key)
    exec "set <M-".a:key.">=\e".a:key
  endfunc
  " set 0-9
  for i in range(10)
    call s:metacode(nr2char(char2nr('0') + i))
  endfor
  " set a-z A-Z
  for i in range(26)
    call s:metacode(nr2char(char2nr('a') + i))
    call s:metacode(nr2char(char2nr('A') + i))
  endfor
  for c in [',', '.', '/', ';', '{', '}']
    call s:metacode(c)
  endfor
  for c in ['?', ':', '-', '_', '+', '=', "'"]
    call s:metacode(c)
  endfor
endif


"----------------------------------------------------------------------
" 终端下功能键设置
"----------------------------------------------------------------------
function! s:key_escape(name, code)
  if has('nvim') == 0 && has('gui_running') == 0
    exec "set ".a:name."=\e".a:code
  endif
endfunc


"----------------------------------------------------------------------
" 功能键终端码矫正
"----------------------------------------------------------------------
call s:key_escape('<F1>', 'OP')
call s:key_escape('<F2>', 'OQ')
call s:key_escape('<F3>', 'OR')
call s:key_escape('<F4>', 'OS')
call s:key_escape('<S-F1>', '[1;2P')
call s:key_escape('<S-F2>', '[1;2Q')
call s:key_escape('<S-F3>', '[1;2R')
call s:key_escape('<S-F4>', '[1;2S')
call s:key_escape('<S-F5>', '[15;2~')
call s:key_escape('<S-F6>', '[17;2~')
call s:key_escape('<S-F7>', '[18;2~')
call s:key_escape('<S-F8>', '[19;2~')
call s:key_escape('<S-F9>', '[20;2~')
call s:key_escape('<S-F10>', '[21;2~')
call s:key_escape('<S-F11>', '[23;2~')
call s:key_escape('<S-F12>', '[24;2~')


"----------------------------------------------------------------------
" 防止tmux下vim的背景色显示异常
" Refer: http://sunaku.github.io/vim-256color-bce.html
"----------------------------------------------------------------------
if &term =~ '256color' && $TMUX != ''
  " disable Background Color Erase (BCE) so that color schemes
  " render properly when inside 256-color tmux and GNU screen.
  set t_ut=
endif

" Ref: https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6
" You might have to force true color when using regular vim inside tmux as the
" colorscheme can appear to be grayscale with 'termguicolors' option enabled.
if !has('gui_running') && &term =~ '^\%(screen\|tmux\)'
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif


"----------------------------------------------------------------------
" 配置微调
"----------------------------------------------------------------------

" 打开文件时恢复上一次光标所在位置
autocmd BufReadPost *
      \ if line("'\"") > 1 && line("'\"") <= line("$") |
      \	 exe "normal! g`\"" |
      \ endif

" 定义一个 DiffOrig 命令用于查看文件改动
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
        \ | wincmd p | diffthis
endif


"----------------------------------------------------------------------
" 文件类型微调
"----------------------------------------------------------------------
augroup InitFileTypesGroup

  " 清除同组的历史 autocommand
  au!

  " help page: open in a new tab
  autocmd BufEnter *.txt if &filetype == 'help' | wincmd T | endif

  " shegang: Automatically apply filetype by shebang
  function! s:ApplyShebang()
    let l:filetype = matchstr(getline(1), '^#!.*[ /]\zs[[:alnum:]]\+$')
    let l:shebangMatch = #{ node: "javascript" }
    if l:filetype != ""
      if has_key(shebangMatch, l:filetype)
        let l:filetype = shebangMatch[l:filetype]
      endif
      echo "filetype from shebang: ".l:filetype
      execute "set filetype=".l:filetype
    endif
  endfunction
  autocmd BufReadPost * call <SID>ApplyShebang()

  " html: Quickly edit html tag class
  function! s:ChangeAttr(pattern)
    let l:attr = matchstr(getline('.'), a:pattern.'="')
    if l:attr == ''
      let l:all_attrs = matchstr(getline('.'), '<[[:alnum:]]\+\zs\s\?[^>]*>\ze')
      execute 's/'.l:all_attrs.'/ '.a:pattern.'=""'.l:all_attrs.'/'
      noh
      normal! 0f"l
      startinsert
    else
      normal! 0
      call search(l:attr)
      normal! f"l
      noh
      startinsert
    endif
  endfunction
  " Edit class and id for javascript files
  autocmd FileType html nnoremap <leader>cl :call <SID>ChangeAttr("class")<CR>
  autocmd BufLeave nunmap <leader>cl
  autocmd FileType html nnoremap <leader>id :call <SID>ChangeAttr("id")<CR>
  autocmd BufLeave nunmap <leader>id

  " markdown
  au FileType markdown setlocal wrap
  au FileType markdown set sw=2 ts=2
  " Fold by heading level
  function! MarkdownLevel()
    let hash_num = matchstr(getline(v:lnum), '^#\+')
    let hash_num_at_top = matchstr(getline(v:lnum-1), '^#\+')
    if empty(hash_num)
      if empty(hash_num_at_top)
        return "="
      else
        return ">".(len(hash_num-1))
      endif
    else
      return len(hash_num)-1
    endif
  endfunction
  au FileType markdown setlocal foldexpr=MarkdownLevel()
  au FileType markdown setlocal foldmethod=expr

  " quickfix: hide line number
  au FileType qf setlocal nonumber

  " 强制对某些扩展名的 filetype 进行纠正
  au BufNewFile,BufRead *.as setlocal filetype=actionscript
  au BufNewFile,BufRead *.pro setlocal filetype=prolog
  au BufNewFile,BufRead *.es setlocal filetype=erlang
  au BufNewFile,BufRead *.asc setlocal filetype=asciidoc
  au BufNewFile,BufRead *.vl setlocal filetype=verilog
  au BufRead /tmp/mutt-* set tw=72

augroup END
