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
" command! -nargs=1 LoadScript exec 'so '.s:home.'/'.'<args>'

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

" 加载扩展配置
source ~/.vim/vim-init/init/init-config.vim

" 设定 tabsize
source ~/.vim/vim-init/init/init-tabsize.vim

" Plugins
source ~/.vim/vim-init/init/init-plugins.vim
