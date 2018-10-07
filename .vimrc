"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Config from amix
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set runtimepath+=~/.vim_runtime

source ~/.vim_runtime/vimrcs/basic.vim
source ~/.vim_runtime/vimrcs/filetypes.vim
source ~/.vim_runtime/vimrcs/plugins_config.vim
source ~/.vim_runtime/vimrcs/extended.vim

try
source ~/.vim_runtime/my_configs.vim
catch
endtry

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Custom Config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set cursorline
set number
set relativenumber


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Make Alt key works on Gnome terminal
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Solution is here: https://stackoverflow.com/questions/6778961
let c='a'
while c <= 'z'
  exec "set <A-".c.">=\e".c
  exec "imap \e".c." <A-".c.">"
  let c = nr2char(1+char2nr(c))
endw
set timeout ttimeoutlen=50
