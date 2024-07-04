" Avoid load this script twice
if get(s:, 'loaded', 0) != 0
  finish
else
  let s:loaded = 1
endif

" Get current dir
" let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:home = '~/helper/vim'

" Load script in current dir
" command! -nargs=1 LoadScript exec 'source '.s:home.'/'.'<args>'

" Add current dir into runtimepath
execute 'set runtimepath+='.s:home


"----------------------------------------------------------------------
" Locad Modules
"----------------------------------------------------------------------

" Basic configuration
source ~/helper/vim/init/basic.vim

" Key mappings
source ~/helper/vim/init/keymaps.vim

" Extra config for different contexts
source ~/helper/vim/init/config.vim

" Highlight
source ~/helper/vim/init/special_highlight.vim

if has('nvim')
  " For neovim
  source ~/.config/nvim/lazy.lua
else
  " For vim
  source ~/helper/vim/init/plugins.vim
  source ~/helper/vim/init/style.vim
endif
