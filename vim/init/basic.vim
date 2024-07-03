"======================================================================
"
" init-basic.vim - Need vim tiny compatible
"
" Used for general usecases. No keymap and personal preference
"
" Use '*' to search for:
" VIM_BEHAVIOR
" VISUAL
" EDIT
" JUMP
" SEARCH
" BUFFERS
" TABSIZE
" ENCODING_PREFERENCE
" FOLDING
" BACKUP
" MISC
"======================================================================


"----------------------------------------------------------------------
" VIM_BEHAVIOR
"----------------------------------------------------------------------

let mapleader = ","	    " Always use comma as leader key
set nocompatible	    " Disable vi compatible, today is 20XX
set path=.,**		    " Allow :find with completion
set mouse=		    " Disable mouse selection
set winaltkeys=no	    " Allow alt key for mapping
set cursorline
set whichwrap=b,s
" set autochdir		    " Automatically cd to current file

" Turn persistent undo on
" means that you can undo even when you close a buffer/VIM
set undofile
set undodir=~/.vim/.undodir
set conceallevel=1

" Apply plugin and indent by filetype
filetype plugin indent on


"----------------------------------------------------------------------
" VISUAL
"----------------------------------------------------------------------

" colorscheme desert	        " I like desert!
" In most of the cases, it is overrides by lightline.vim
set statusline=\ %F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c
set showmatch		        " Show pairing brackets

set number relativenumber   " Use relativenumber
set wrap		    " Disable wrap by default
set scrolloff=3		    " Leave some buffer when scrolling down
set ruler		    " Show cursor position
set laststatus=2    	    " Always show the status line
set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20


"----------------------------------------------------------------------
" EDIT
"----------------------------------------------------------------------

set backspace=eol,start,indent " Set Backspace behaviors
set autoindent		    " If current line has indent, automatically set indent for next line
set cindent
set ttimeout
set ttimeoutlen=50
" set updatetime=1000
" autocmd CursorHold * normal! m'

imap <C-c> <Esc>l
" Change IM to US when exit to Normal mode
autocmd InsertLeave * :silent !fcitx-remote -c &>/dev/null || true


"----------------------------------------------------------------------
" JUMP
"----------------------------------------------------------------------

set isfname=@,48-57,/,.,-,_,+,,,#,$,%,~ " This affects filename recognition for gf (go to file)
set suffixesadd=.md			" Enable reference markdown file without extension


"----------------------------------------------------------------------
" SEARCH
"----------------------------------------------------------------------
set ignorecase		    " Search case without case sensation
set smartcase
set hlsearch		    " Hilight all matched texts
set incsearch		    " Show matched strings when typing

"----------------------------------------------------------------------
" BUFFERS
"----------------------------------------------------------------------

" Set to auto read when a file is changed from the outside
" Unnamed buffer like CmdWindows should prevent this
set autoread
autocmd FocusGained,BufEnter .* checktime

let g:quitVimWhenPressingCtrlC = 1
function! ToggleQuit()
    let g:quitVimWhenPressingCtrlC = g:quitVimWhenPressingCtrlC ? 0 : 1
    let message = g:quitVimWhenPressingCtrlC ? "Unlock" : "Lock"
    echo message
endfunction

nnoremap gl :call ToggleQuit()<CR>

" Simply exit when closing the last buffer

function! Bye()
  if len(getbufinfo({'buflisted': 1})) == 1 && len(getwininfo()) == 1
    if g:quitVimWhenPressingCtrlC
      :silent! quit
    else
      :echo "Press gl to allow quit with <C-c>"
    endif
  else
    :bdelete
  endif
endfunction

" Ctrl-C rules!!!
nnoremap <silent> <C-c> :call Bye()<CR>

" Don't unload a buffer when no longer shown in a window
" This allows you open a new buffer and leaves current buffer modified
set hidden


" Put these in an autocmd group, so that you can revert them with:
" ":augroup vimStartup | au! | augroup END"
augroup vimStartup
au!

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid, when inside an event handler
" (happens when dropping a file on gvim) and for a commit message
" (it's likely a different one than last time).
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif
augroup END

" Set filetype for beancount
autocmd BufRead,BufNewFile *.bean call PrepareBean()
function PrepareBean()
    set filetype=beancount
    silent !setsid fava ~/bean/main.bean &>/dev/null
    autocmd VimLeave * silent !killall fava
endfunction

" Set filetype for index.html
autocmd BufWrite *.html,*.js,*.css call ReloadServer()
function ReloadServer()
    silent !browser-sync reload &>/dev/null
endfunction

" Hide the first line of a file if editing password file
" TODO a better way to determine a file is related to password-store, now use
" files under /dev/shm as filter
autocmd BufRead /dev/shm/*.txt call SetPasswordFile()
function SetPasswordFile()
    setlocal foldminlines=0
    setlocal foldmethod=manual
    function s:custom()
      return "Password"
    endfunction
    setlocal foldtext=s:custom()
    norm! ggzfl
endfunction


"----------------------------------------------------------------------
" TABSIZE
"----------------------------------------------------------------------
set expandtab
set shiftwidth=2
set autoindent
set tabstop=4
set softtabstop=0
set smartindent


"----------------------------------------------------------------------
" ENCODING_PREFERENCE
"----------------------------------------------------------------------
if has('multi_byte')
	set encoding=utf-8
	set fileencoding=utf-8
	" Try encodings by this order
	set fileencodings=utf-8,big5,ucs-bom,gbk,gb18030,euc-jp,latin1
endif


"----------------------------------------------------------------------
" FOLDING
"----------------------------------------------------------------------
set foldenable          " Allow fold
set foldmethod=indent   " Fold contents by indent
set foldlevel=2         " Expand all by default


"----------------------------------------------------------------------
" BACKUP
"----------------------------------------------------------------------

" Allow backup
set backup
set backupext=.bak
set noswapfile

" Create backup dir if it doesn't exist
silent! call mkdir(expand('~/.vim/tmp'), "p", 0755)
set backupdir=~/.vim/tmp

" backup when write file
set writebackup

"----------------------------------------------------------------------
" MISC
"----------------------------------------------------------------------

" 顯示括號匹配的時間
set matchtime=2

" 顯示最後一行
set display=lastline

" 允許下方顯示目錄
set wildmenu wildoptions=pum,fuzzy

" Improve performance
set lazyredraw

" Format of error message
set errorformat+=[%f:%l]\ ->\ %m,[%f:%l]:%m

" 顯示分隔符號
set listchars=tab:\|\ ,trail:.,extends:>,precedes:<

" 遇到Unicode值大於255的文本，不必等到空格再折行
set formatoptions+=m

" 合併兩行中文時，不在中間加空格
set formatoptions+=B

" Use Unix way to add newline
set ffs=unix,dos,mac


"----------------------------------------------------------------------
" Ignore these suffixes when find/complete
"----------------------------------------------------------------------
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
