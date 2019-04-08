all: alias vim git tig

alias:
	rm -f ~/.bash_aliases
	ln -s `pwd`/alias ~/.bash_aliases

vim:
	# amix-vimrc
	if [ ! -d "$(HOME)/.vim_runtime" ]; then \
        git clone --depth=1 git@github.com:amix/vimrc.git ~/.vim_runtime && \
        sh ~/.vim_runtime/install_awesome_vimrc.sh; \
	fi
	# vim-plug
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	
	rm -f ~/.vim_runtime/my_configs.vim
	ln -s `pwd`/vimrc ~/.vim_runtime/my_configs.vim

wiki:
	# vimwiki
	if [ ! -d "$(HOME)/.vimwiki" ]; then \
        git clone --depth=1 git@github.com:typebrook/wiki.git ~/vimwiki; \
	fi

git:
	rm -f ~/.gitconfig
	ln -s `pwd`/gitconfig ~/.gitconfig

tig:
	rm -f ~/.tigrc
	ln -s `pwd`/tigrc ~/.tigrc

push:
	git commit -am "update"
	git push
