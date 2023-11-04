" Avoid load this script twice
if get(s:, 'loaded', 0) != 0
  finish
else
  let s:loaded = 1
endif

" Get current dir
" let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:home = '~/.vim/vim-init'

" Load script in current dir
" command! -nargs=1 LoadScript exec 'source '.s:home.'/'.'<args>'

" Add current dir into runtimepath
execute 'set runtimepath+='.s:home


"----------------------------------------------------------------------
" Locad Modules
"----------------------------------------------------------------------

" Basic configuration
source ~/.vim/vim-init/init/init-basic.vim

" Key mappings
source ~/.vim/vim-init/init/init-keymaps.vim

" UI
" source ~/.vim/vim-init/init/init-style.vim

" Extra config for different contexts
" source ~/.vim/vim-init/init/init-config.vim

" Set tabsize
source ~/.vim/vim-init/init/init-tabsize.vim

if has('nvim')
  " Neovim
  source ~/.config/nvim/nvim.lua
else
" Plugin
  source ~/.vim/vim-init/init/init-plugins.vim
endif

" Temp
let g:NERDTreeWinPos = "right"
let NERDTreeShowHidden=0
let NERDTreeQuitOnOpen=1
let NERDTreeIgnore = ['\.pyc$', '__pycache__']
let g:NERDTreeWinSize=35
map <leader>nn :NERDTreeToggle<cr>
map <leader>nb :NERDTreeFromBookmark<Space>
map <leader>nf :NERDTreeFind<cr>
