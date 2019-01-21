all: apply-alias apply-vim apply-tig

apply-alias:
	rm -f ~/.bash_aliases
	ln -s `pwd`/alias ~/.bash_aliases
apply-vim:
	if [ ! -d "~/.vim_runtime" ]; then \
        git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime && \
        sh ~/.vim_runtime/install_awesome_vimrc.sh; \
	fi
	rm -f ~/.vim_runtime/my_configs.vim
	ln -s `pwd`/vimrc ~/.vim_runtime/my_configs.vim
apply-tig:
	rm -f ~/.tigrc
	ln -s `pwd`/tigrc ~/.tigrc
push:
	git commit -am "update"
	git push
