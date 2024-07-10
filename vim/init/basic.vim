"======================================================================
" init-basic.vim - Need vim tiny compatible
"
" Used for general usecases. No keymap and personal preference
"======================================================================

" Vimscript file settings ---------------------- {{{

" Usage: type --- for foldmark
augroup filetype_vim
    autocmd!
    execute "autocmd FileType vim :inoreabbrev <buffer> --- ----------------{".."{{"
    autocmd FileType vim setlocal foldmethod=marker foldlevel=0
augroup END

" }}}
" GERERNAL ----------------{{{

let mapleader = ","	    " Always use comma as leader key
set nocompatible	  " Disable vi compatible, today is 20XX
set path=.,**		    " Allow :find with completion
set mouse=		      " Disable mouse selection
set winaltkeys=no	    " Allow alt key for mapping

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

" }}}
" VISUAL ----------------{{{

" colorscheme desert

" Editing Area
set wrap		                " enable wrap by default
set scrolloff=3		          " Leave some buffer when scrolling down
set showmatch		            " Show pairing brackets
set display=lastline
set lazyredraw
set formatoptions+=m        " 遇到Unicode值大於255的文本，不必等到空格再折行
set formatoptions+=B        " 合併兩行中文時，不在中間加空格
set whichwrap=b,s

" Side column
set signcolumn=yes number relativenumber

" Cursor
set cursorline
set guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20
set matchtime=2

" In most of the cases, it is overrides by lightline.vim
set statusline=\ %F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c
set laststatus=2    	      " Always show the status line
set ruler		                " Show cursor position
set wildmenu wildoptions=pum,fuzzy

" Format of error message
set errorformat+=[%f:%l]\ ->\ %m,[%f:%l]:%m

" }}}
" EDIT ----------------{{{

set backspace=eol,start,indent " Set Backspace behaviors
set autoindent smartindent
set shiftwidth=2
set cindent
set ttimeout
set ttimeoutlen=50
" set updatetime=1000
" autocmd CursorHold * normal! m'

imap <C-c> <Esc>l

" TAB ----------------{{{

set expandtab
set softtabstop=-1

" 顯示分隔符號
set list
set listchars=tab:▷▷,extends:>,precedes:<

" }}}

" }}}
" JUMP to anoterh file ----------------{{{

set isfname=@,48-57,/,.,-,_,+,,,#,$,%,~ " This affects filename recognition for gf (go to file)
set suffixesadd=.md			" Enable reference markdown file without extension

" }}}
" SEARCH ----------------{{{

set ignorecase      " Search case without case sensation
set smartcase
set hlsearch        " Hilight all matched texts
set incsearch       " Show matched strings when typing

" }}}
" BUFFERS ----------------{{{

" Go to last cursor position ----------------{{{
augroup vimStartup
  au!
  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid, when inside an event handler
  " (happens when dropping a file on gvim) and for a commit message
  " (it's likely a different one than last time).
  autocmd BufReadPost *
        \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
        \ |   exe "normal! g`\"zv"
        \ | endif
augroup END

" }}}

" }}}
" ENCODING_PREFERENCE ----------------{{{

if has('multi_byte')
  set encoding=utf-8
  set fileencoding=utf-8
  " Try encodings by this order
  set fileencodings=utf-8,big5,ucs-bom,gbk,gb18030,euc-jp,latin1
endif

" }}}
" FOLD ----------------{{{

set foldenable          " Allow fold
set foldmethod=indent   " Fold contents by indent
set foldlevel=2

" }}}
" BACKUP ----------------{{{

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
" HIGHLIGHT ----------------{{{

syntax enable
set conceallevel=1

function! GetHighlightGroupName()
  let l:syntaxID = synID(line('.'), col('.'), 1)
  let l:groupName = synIDattr(l:syntaxID, 'name')
  echo "Highlight Group Name: " . l:groupName
endfunction
nnoremap <leader>H :call GetHighlightGroupName()<CR>

" Defualt highlight for matched parenthesis is so weird in many colorscheme
" Why the background color is lighter than my caret !?
" highlight MatchParen ctermfg=NONE ctermbg=darkgrey cterm=NONE
highlight LuaParen ctermfg=NONE ctermbg=darkgrey cterm=NONE

" Show trailing spaces
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" Persist visualized lines
" define line highlight color
highlight MultiLineHighlight ctermbg=LightYellow guibg=LightYellow ctermfg=Black guifg=Black
" highlight the current line
nnoremap <silent> <leader>gh :call matchadd('MultiLineHighlight', '\%'.line('.').'l')<CR>
" clear all the highlighted lines
nnoremap <silent> <leader>gH :call clearmatches()<CR>

" }}}
" MISC ----------------{{{

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
