.PHONY: *

all: git vim tig
	mkdir -p ~/git

git:
	rm -f ~/.gitconfig
	ln -s `pwd`/gitconfig ~/.gitconfig

vim:
	# amix-vimrc
	if [ ! -d "$(HOME)/.vim_runtime" ]; then \
		git clone --depth=1 --origin my git@github.com:typebrook/vimrc.git ~/.vim_runtime && \
		cd ~/.vim_runtime && git remote add origin git@github.com:amix/vimrc.git && \
        sh ~/.vim_runtime/install_awesome_vimrc.sh; \
	fi
	# vim-plug
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	
	rm -f ~/.vim_runtime/my_configs.vim
	ln -s `pwd`/vimrc ~/.vim_runtime/my_configs.vim

tig:
	rm -f ~/.tigrc
	ln -s `pwd`/tigrc ~/.tigrc
	if [ ! -d "$(HOME)/git/tig" ]; then \
		git clone --depth=100 --origin my git@github.com:typebrook/tig ~/git/tig; \
		cd ~/git/tig && git remote add origin git@github.com:jonas/tig.git && \
	fi

zsh:
	curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash

wiki:
	# vimwiki
	if [ ! -d "$(HOME)/.vimwiki" ]; then \
		git clone git@github.com:typebrook/wiki.git ~/vimwiki; \
	fi

crontab:
	(crontab -l 2>/dev/null; cat tools/*.cron) | crontab -
