"======================================================================
" init-config.vim
" Do some autocommand for by contexts
"======================================================================

" Unnamed Buffer {{{

" Automatically delete unnamed empty buffer when leaving
augroup DeleteUnnamedEmptBuffer!
  au!
  au BufLeave {} if getline(1, '$') == [''] | setlocal bufhidden=wipe | endif
augroup END

" }}}
" Small Terminal {{{

augroup TerminalSize
  au!
  function! LayoutForSmallTerminal(bound)
    if &lines < a:bound || g:alacritty_extra_padding
      silent! set laststatus=0 showtabline=0 signcolumn=0 nowrap scrolloff=1
    else
      silent! set laststatus& showtabline=2 signcolumn& scrolloff&
    endif
  endfunc
  autocmd VimEnter,VimResized * silent call LayoutForSmallTerminal(20)
  autocmd VimLeave * if g:alacritty_extra_padding | call ToggleWinPadding() | endif
augroup END

" }}}
" X11 {{{

" Change IM to US when exit to Normal mode
autocmd InsertLeave * :silent !fcitx-remote -c &>/dev/null || true

" }}}
" TMUX {{{

" 有 tmux 何没有的功能键超时（毫秒）
if $TMUX != ''
  set ttimeoutlen=30
elseif &ttimeoutlen > 80 || &ttimeoutlen <= 0
  set ttimeoutlen=80
endif

" 防止tmux下vim的背景色显示异常
" Refer: http://sunaku.github.io/vim-256color-bce.html
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

" }}}
" KeyCode {{{

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
" 功能键终端码矫正
"----------------------------------------------------------------------
function! s:key_escape(name, code)
  if has('nvim') == 0 && has('gui_running') == 0
    exec "set ".a:name."=\e".a:code
  endif
endfunc

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

" }}}
" Filetype {{{

augroup InitFileTypes

  au!

  " Filetype for Vim {{{

  " Help page
  autocmd BufEnter * if &filetype == 'help' | wincmd T | set buflisted nofoldenable | endif

  " quickfix: hide line number
  autocmd FileType quickfix setlocal nonumber

  " }}}
  " Shebeng: Set filetype from shebeng {{{
  function! s:ApplyShebang()
    let l:filetype = matchstr(getline(1), '^#!.*[ /]\zs[[:alnum:]]\+$')
    let l:shebangMatch = #{ node: "javascript" }
    if l:filetype != ""
      if has_key(shebangMatch, l:filetype)
        let l:filetype = shebangMatch[l:filetype]
      endif
      execute "set filetype=".l:filetype
    endif
  endfunc
  autocmd BufReadPost * call <SID>ApplyShebang()
  " }}}
  " Markdown {{{

  augroup Config_Markdown
    au!

    au FileType markdown call InitMarkdownFile()
    function! InitMarkdownFile()
      setlocal wrap sw=2 ts=2
      let g:markdown_apply_heading_level = 0
      nnoremap \fl :let markdown_apply_heading_level = !markdown_apply_heading_level<CR>zX

      let b:in_frontmatter = 0
      setlocal foldexpr=MarkdownLevel() foldmethod=expr
      setlocal foldtext=MarkdownFoldTextHeading()

      call MarkdownHighlights()
    endfunc

    function! MarkdownHighlights()
      syn match MarkdownHtmlDetails '^<details>' conceal cchar=▶
      syn match MarkdownHtmlSummary '<summary>' conceal cchar= 
      syn match MarkdownHtmlSummaryEnd '</summary>' conceal
      syn match MarkdownHtmlDetailsEnd '^</details>' conceal cchar=E
    endfunc

    function! MarkdownLevel()
      " For frontmatter
      if v:lnum == 1 && getline(1) =~ '^---'
        let b:in_frontmatter = 1
        return '>1'
      endif
      if b:in_frontmatter
        if getline(v:lnum) =~ '^---'
          let b:in_frontmatter = 0
          return '<1'
        else
          return '='
        endif
      endif

      " Fold for heading and the following contents
      let hash_num = matchstr(getline(v:lnum), '^#\+')
      if !empty(hash_num)
        let foldlevel = g:markdown_apply_heading_level ? len(hash_num) - 1 : 1
        " HEADING
        return len(hash_num) == 1 ? 0 : '>'.foldlevel
      else
        " Contents
        return "="
      endif
    endfunc

    function! MarkdownFoldTextHeading()
      " For frontmatter
      if v:foldstart == 1 && getline(v:foldstart) =~ '^---'
        return '===FrontMatter==='
      endif

      " For heading, foltext()
      let origin = split(MarkdownFoldText()[2:], ' ')
      let heading = substitute(join(origin[:-3], ' '), '\#', '  ', 'g')
      let lines = origin[-2][1:]
      let fills = repeat('.', 48 - strwidth(heading) - len(lines))
      return heading.."  "..fills.."  "..lines
    endfunc

  augroup END

  " }}}
  " HTML {{{

  " Usage: <leader>cl(ass) or <leader>id to edit html tag attribute
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
  endfunc
  autocmd FileType html,markdown nnoremap <buffer> <leader>cl :call <SID>ChangeAttr("class")<CR>
  autocmd FileType html,markdown nnoremap <buffer> <leader>id :call <SID>ChangeAttr("id")<CR>

  " Reload preview server
  autocmd BufWrite *.html,*.js,*.css call ReloadServer()
  function! ReloadServer()
    silent !browser-sync reload &>/dev/null
  endfunc

  " }}}
  " Mail {{{

  autocmd BufRead /tmp/mutt-* setlocal tw=72

  " }}}
  " Password {{{

  " Hide the first line of a file if editing password file
  " TODO a better way to determine a file is related to password-store, now use
  " files under /dev/shm as filter
  autocmd BufRead /dev/shm/*.txt call SetPasswordFile()
  function! SetPasswordFile()
    setlocal foldminlines=0
    setlocal foldmethod=manual
    setlocal foldtext="Password"
    norm! ggzfl
  endfunc
  " }}}
  " Beancount {{{

  autocmd BufRead,BufNewFile *.bean call PrepareBean()
  function! PrepareBean()
    set filetype=beancount
    silent !setsid fava ~/bean/main.bean &>/dev/null
    autocmd VimLeave * silent !killall fava
  endfunc

  " }}}

augroup END

" }}}
