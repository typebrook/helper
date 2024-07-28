"======================================================================
" init-basic.vim - Need vim tiny compatible
"
" Used for general usecases. No keymap and personal preference
"======================================================================

" For Vimscript {{{

" Usage: type --- for foldmark
augroup filetype_vim
    autocmd!
    execute "autocmd FileType vim :inoreabbrev <buffer> --- ----------------{".."{{<CR>\" }"."}}"
    autocmd FileType vim setlocal foldmethod=marker foldlevel=0
augroup END

" }}}
" For Buffer and Tab {{{
augroup tabinfo
  au!
  let g:tab_group = {}
  " BufEnter {{{
  function! AddBufToTabGroup(tab_group)
    let l:tabId = tabpagenr()
    let l:bufnr = bufnr()

    if has_key(a:tab_group, l:tabId)
      for v in a:tab_group[l:tabId]
        if v == l:bufnr
          return
        endif
      endfor
      call add(a:tab_group[l:tabId], l:bufnr)
    else
      let a:tab_group[l:tabId] = [l:bufnr]
    endif

  endfunc
  autocmd BufWinEnter * if &buflisted | call AddBufToTabGroup(g:tab_group) | endif
  " }}}
  " BufDelete {{{
  function! RemoveBufFromTabGroup(tab_group)
    let l:tabId = tabpagenr()

    if has_key(a:tab_group, l:tabId)
      let l:new_tab_group = {}

      for [k, tab_list] in items(a:tab_group)
        let l:list = []
        for buf in tab_list
          if buflisted(buf) > 0 && buf != expand('<abuf>')
            call add(l:list, buf)
          end
        endfor
        if !empty(l:list)
          let l:new_tab_group[k] = l:list
        endif
      endfor
      let g:tab_group = l:new_tab_group

    endif

  endfunc
  autocmd BufDelete * call RemoveBufFromTabGroup(g:tab_group)
  "}}}
augroup END
"}}}
" GERERNAL {{{

let mapleader = ","     " Always use comma as leader key
set nocompatible        " Disable vi compatible, today is 20XX
set path=.,**           " Allow :find with completion
set mouse=              " Disable mouse selection
set winaltkeys=no       " Allow alt key for mapping

" Turn persistent undo on
" means that you can undo even when you close a buffer/VIM
set undofile
set undodir=~/.vim/.undodir

" Apply plugin and indent by filetype
filetype plugin indent on

" Set to auto read when a file is changed from the outside
" Unnamed buffer like CmdWindows should prevent this
set autoread
autocmd FocusGained,BufEnter .* checktime

" spell
set spell
set spellfile="/tmp/spell"

" Custom sign from help page :h sign
sign define piet text=>> texthl=Search

" }}}
" VISUAL {{{

" colorscheme desert

" Editing Area
set wrap                " enable wrap by default
set scrolloff=3         " Leave some buffer when scrolling down
set showmatch           " Show pairing brackets
set display=lastline
set lazyredraw
set whichwrap=b,s

" Side column
set  number relativenumber

" Cursor
set cursorline
set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
set matchtime=2

" In most of the cases, it is overrides by lightline.vim
set statusline=\ %F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c
set laststatus=2            " Always show the status line
set ruler                    " Show cursor position
set wildmenu wildoptions=pum,fuzzy

" Format of error message
set errorformat+=[%f:%l]\ ->\ %m,[%f:%l]:%m

" Direction for new window
set splitright

" }}}
" EDIT {{{

" overrides ftplugin in runtimepath
" Don't wrap line when typing CJK characters
" Don't add spaces for CJK
" Don't add comment at next line
autocmd Filetype * set fo+=mB fo-=cro

set shiftwidth=2
set autoindent smartindent
set cindent
set ttimeout
set timeoutlen=500

set backspace=eol,start,indent  " Set Backspace behaviors

" set updatetime=4000
" autocmd CursorHold * normal! m'

" TAB and special Chars {{{

set tabstop=8 softtabstop=8
set expandtab

" Invisible chars
set nolist
set listchars=tab:»·,extends:>,precedes:<

" }}}

" }}}
" JUMP to anoterh file {{{

set isfname=@,48-57,/,.,-,_,+,,,#,$,%,~ " This affects filename recognition for gf (go to file)
set suffixesadd=.md                     " Enable reference markdown file without extension

" }}}
" SEARCH {{{

set ignorecase  " Search case without case sensation
set smartcase
set hlsearch    " Highlight all matched texts
set incsearch   " Show matched strings when typing

" }}}
" BUFFERS {{{

" Go to last cursor position {{{
augroup vimStartup
  au!
  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid, when inside an event handler
  " (happens when dropping a file on gvim) and for a commit message
  " (it's likely a different one than last time).
  autocmd BufReadPost *
        \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
        \ |   try | silent execute 'normal! g`"zv' | endtry
        \ | endif
augroup END

" }}}

" }}}
" FOLD {{{

set foldenable          " Allow fold
set foldmethod=indent   " Fold contents by indent
set foldlevel=2
set fillchars+=foldopen:▽,foldsep:│,foldclose:▶
let g:defaut_foldcolumn = ""
if has('nvim')
  let g:defaut_foldcolumn = "auto:3"
else
  let g:defaut_foldcolumn = 3
endif
let &foldcolumn = g:defaut_foldcolumn

" }}}
" ENCODING_PREFERENCE {{{

if has('multi_byte')
  set encoding=utf-8
  set fileencoding=utf-8
  " Try encodings by this order
  set fileencodings=utf-8,big5,ucs-bom,gbk,gb18030,euc-jp,latin1
endif

" }}}
" BACKUP {{{

" Allow backup
set backup
set backupext=.bak
set noswapfile

" Create backup dir if it doesn't exist
silent! call mkdir(expand('~/.vim/tmp'), "p", 0755)
set backupdir=~/.vim/tmp

" backup when write file
set writebackup

" }}}
" HIGHLIGHT {{{

syntax enable
set conceallevel=1

" Defualt highlight for matched parenthesis is so weird in many colorscheme
" Why the background color is lighter than my caret !?
" highlight MatchParen ctermfg=NONE ctermbg=darkgrey cterm=NONE
highlight LuaParen ctermfg=NONE ctermbg=darkgrey cterm=NONE

" Show trailing spaces
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" }}}
" MISC {{{

" Use Unix way to add newline
set ffs=unix,dos,mac

" Ignore these suffixes when find/complete
set suffixes=.bak,~,.o,.h,.info,.swp,.obj,.pyc,.pyo,.egg-info,.class

set wildignore=*.o,*.obj,*~,*.exe,*.a,*.pdb,*.lib "stuff to ignore when tab completing
set wildignore+=*.so,*.dll,*.swp,*.egg,*.jar,*.class,*.pyc,*.pyo,*.bin,*.dex
set wildignore+=*.zip,*.7z,*.rar,*.gz,*.tar,*.gzip,*.bz2,*.tgz,*.xz    " MacOSX/Linux
set wildignore+=*DS_Store*,*.ipch
set wildignore+=*.gem
set wildignore+=*.png,*.jpg,*.gif,*.bmp,*.tga,*.pcx,*.ppm,*.img,*.iso
set wildignore+=*.so,*.swp,*.zip,*/.Trash/**,*.pdf,*.dmg,*/.rbenv/**
set wildignore+=*/.nx/**,*.app,*.git,.git
set wildignore+=*.wav,*.mp3,*.ogg,*.pcm
set wildignore+=*.mht,*.suo,*.sdf,*.jnlp
set wildignore+=*.chm,*.epub,*.pdf,*.mobi,*.ttf
set wildignore+=*.mp4,*.avi,*.flv,*.mov,*.mkv,*.swf,*.swc
set wildignore+=*.ppt,*.pptx,*.docx,*.xlt,*.xls,*.xlsx,*.odt,*.wps
set wildignore+=*.msi,*.crx,*.deb,*.vfd,*.apk,*.ipa,*.bin,*.msu
set wildignore+=*.gba,*.sfc,*.078,*.nds,*.smd,*.smc
set wildignore+=*.linux2,*.win32,*.darwin,*.freebsd,*.linux,*.android

" }}}
