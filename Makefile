.ONESHELL:
.PHONY: *

all: git tig vim gpg
	mkdir -p ~/git

other: zsh fzf log pass mutt tmux

git:
	rm -f ~/.gitconfig
	ln -s `pwd`/gitconfig ~/.gitconfig
	mkdir -p ~/git

tig:
	ln -sf `pwd`/tigrc ~/.tigrc

vim:
	ln -sf `pwd`/init.vim ~/.vimrc
	ln -sf `pwd`/init.vim ~/.config/nvim/init.vim
	ln -sf `pwd`/nvim.lua ~/.config/nvim/nvim.lua
	# vim-plug
	# curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

gpg:
	ln -sf `pwd`/misc/gpg-agent ~/.gnupg/gpg-agent.conf
	gpgconf --reload gpg-agent

zsh:
	ln -sf `pwd`/zsh/zshenv ~/.zshenv
	mkdir -p ~/.config/zsh
	ln -sf `pwd`/zsh/zshrc ~/.config/zsh/.zshrc

fzf:
	if [ ! -d "$(HOME)/.fzf" ]; then 
		git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; 
		~/.fzf/install; 
	fi

log:
	# vimwiki
	if [ ! -d "$(HOME)/.vimwiki" ]; then 
		git clone vps:~/log ~/log; 
	fi

pass:
	if [ ! -d "$(HOME)/.password-store" ]; then
		git clone ssh://vps/~/.password-store ~/.password-store;
	fi

~/.local/share/application:
	mkdir -p $@

mutt: ~/.local/share/application
	ln -sf `pwd`/mutt -T ~/.config/mutt
	ln -sf `pwd`/mutt/mutt.desktop $<
	pass mail/mutt.hooks >mutt/hooks.topo

tmux:
	ln -sf `pwd`/misc/tmux.conf ~/.tmux.conf

crontab:
	(crontab -l 2>/dev/null; cat bin/cron/* | sed '/^#/ d') | crontab -

# Swap Ctrl-Caps in X11
libinput:
	sudo ln -sf `pwd`/misc/libinput/* /etc/X11/xorg.conf.d/

# Swap Ctrl-Caps in tty2~6
console:
	sudo ln -sf `pwd`/misc/vconsole.conf /etc/vconsole.conf
	sudo systemctl restart systemd-vconsole-setup.service


task:
	ln -sf $(HOME)/.task/taskrc $(HOME)/.taskrc
	if [ ! -d "$(HOME)/.task/.git" ]; then 
		if [ -d "$(HOME)/.task" ]; then rm -rf "$(HOME)/.task"; fi; 
		git clone --depth 1 vps:~/.task ~/.task;
	fi

blog:
	if [ ! -d "$(HOME)/blog" ]; then
		git clone ssh://vps/~/blog $(HOME)/blog;
	fi

theme:
	ln -sf `pwd`/X11/themes -T ~/.themes

openbox: theme
	ln -sf `pwd`/X11/openbox/rc.xml ~/.config/openbox/

rofi:
	ln -sf `pwd`/X11/rofi/config.rasi ~/.config/rofi/config.rasi

archcraft:
	ls -sf `pwd`/bin/desktop/takeshot /usr/local/bin/takeshot

urlview:
	ln -sf `pwd`/misc/urlview ~/.urlview

alacritty:
	ln -sf `pwd`/X11/alacritty ~/.config/alacritty

mpd:
	ln -sf `pwd`/mpd/ncmpcpp ~/.config/ncmpcpp
	rm -rf ~/.ncmpcpp
