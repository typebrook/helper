.PHONY: *

all: git vim tig gpg
	mkdir -p ~/git

git:
	rm -f ~/.gitconfig
	ln -s `pwd`/gitconfig ~/.gitconfig

vim:
	# amix-vimrc
	if [ ! -d "$(HOME)/.vim_runtime" ]; then \
		git clone --depth=1 --origin my git@github.com:amix/vimrc.git ~/.vim_runtime && \
		cd ~/.vim_runtime && sh ~/.vim_runtime/install_awesome_vimrc.sh
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
		cd ~/git/tig && git remote add origin git@github.com:jonas/tig.git; \
	fi

zsh:
	curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash

fzf:
	if [ ! -d "$(HOME)/.fzf" ]; then \
		git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; \
		~/.fzf/install; \
	fi

wiki:
	# vimwiki
	if [ ! -d "$(HOME)/.vimwiki" ]; then \
		git clone git@github.com:typebrook/wiki.git ~/vimwiki; \
	fi

crontab:
	(crontab -l 2>/dev/null; cat tools/cron/* | sed '/^#/ d') | crontab -

libinput:
	sudo ln -sf `pwd`/misc/libinput/* /etc/X11/xorg.conf.d/

task:
	ln -sf $(HOME)/.task/taskrc $(HOME)/.taskrc
	if [ ! -d "$(HOME)/.task/.git" ]; then \
		if [ -d "$(HOME)/.task" ]; then rm -rf "$(HOME)/.task"; fi; \
		git clone --depth 1 https://github.com/typebrook/task.git ~/.task; \
	fi

gpg:
	sudo ln -sf `pwd`/gpg-agent ~/.gnupg/gpg-agent.conf
	gpgconf --reload gpg-agent

mutt:
	mkdir -p ~/.config/mutt
	ln -s `pwd`/muttrc ~/.config/mutt/muttrc
