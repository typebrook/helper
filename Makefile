apply-alias:
	rm -f ~/.bash_aliases
	ln -s `pwd`/.bash_aliases ~/.bash_aliases
apply-vim:
	rm -f ~/.vim_runtime/my_configs.vim
	ln -s `pwd`/.vimrc ~/.vim_runtime/my_configs.vim
apply-tig:
	rm -f ~/.tigrc
	ln -s `pwd`/.tigrc ~/.tigrc
push:
	git commit -am "update"
	git push
