"======================================================================
"
" init-plugins.vim
"
" Created by skywind on 2018/05/31
" Last Modified: 2018/06/10 23:11
"
"======================================================================
" vim: set ts=4 sw=4 tw=78 noet :

call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf.vim'
nnoremap <leader>sf :Files<CR>
nnoremap <leader>sg :GFiles<CR>
nnoremap <leader>co :Colors<CR>
nnoremap <leader>b :Buffers<CR>

Plug 'tpope/vim-surround'

call plug#end()
