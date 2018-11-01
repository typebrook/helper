apply-alias:
	rm ~/.bash_aliases
	ln ./.bash_aliases ~/.bash_aliases
apply-vim:
	rm ~/.vim_runtime/my_configs.vim
	ln ./.vimrc ~/.vim_runtime/my_configs.vim
push:
	git commit -am "update"
	git push
