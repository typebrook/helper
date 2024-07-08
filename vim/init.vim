" Avoid load this script twice
if get(s:, 'loaded', 0) != 0
  finish
else
  let s:loaded = 1
endif

" Get current dir
" let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:home = '~/helper/vim'
execute 'cd '.s:home

" Load script in current dir
" command! -nargs=1 LoadScript exec 'source '.s:home.'/'.'<args>'

" Add current dir into runtimepath
execute 'set runtimepath+='.s:home

"----------------------------------------------------------------------
" Locad Scripts
"----------------------------------------------------------------------

" Basic configuration
source init/basic.vim

" Key mappings
source init/keymaps.vim

" Extra config for different contexts
source init/config.vim

if has('nvim')
  " For neovim
  source lazy.lua
else
  " For vim
  source init/plugins.vim
  source init/style.vim
endif
