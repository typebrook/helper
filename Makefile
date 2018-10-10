sync-alias:
	cat ~/.bash_aliases > ./.bash_aliases
sync-vim:
	cat ~/.vim_runtime/my_configs.vim > ./.vimrc
apply-alias:
	cat ./.bash_aliases > ~/.bash_aliases
apply-vim:
	cat ./.vimrc > ~/.vim_runtime/my_configs.vim
push:
	git commit -am "update"
	git push
