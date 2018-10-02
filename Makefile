sync-alias:
	cat ~/.bash_aliases > ./.bash_aliases
sync-vim:
	cat ~/.vimrc > ./.vimrc
apply-alias:
	cat ./.bash_aliases > ~/.bash_aliases
apply-vim:
	cat ./.vimrc > ~/.vimrc
push:
	git commit -am "update"
	git push
