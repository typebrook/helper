" Avoid load this script twice
if get(s:, 'loaded', 0) != 0
	finish
else
	let s:loaded = 1
endif

" Get current dir
" let s:home = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:home = '~/.vim/vim-init'
execute 'cd '.s:home

" Load script in current dir
command! -nargs=1 LoadScript exec 'so '.s:home.'/'.'<args>'

" Add current dir into runtimepath
execute 'set runtimepath+='.s:home


"----------------------------------------------------------------------
" Locad Modules
"----------------------------------------------------------------------

" Basic configuration
LoadScript init/init-basic.vim

" Key mappings
LoadScript init/init-keymaps.vim

" UI
" LoadScript init/init-style.vim

" 加载扩展配置
" LoadScript init/init-config.vim

" 设定 tabsize
LoadScript init/init-tabsize.vim

" Plugins
LoadScript init/init-plugins.vim
