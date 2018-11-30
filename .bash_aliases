# settings
alias al='vim ~/.bash_aliases'
alias sa='source ~/.bash_aliases'
alias vimrc='vim ~/.vimrc'
alias bashrc='vim ~/.bashrc'
alias tigrc='vim ~/.tigrc'

# cd to certain directories
alias ..='cd ..'
alias .='cd -'
alias cdd='cd ~/Downloads'
alias cdg='cd ~/git'
alias cds='cd ~/git/settings'

# git
alias g='git'
alias gls='git log -S'
alias gc='git clone'
alias check='git checkout'
alias checkout='git checkout'
alias stash='git stash'
alias commit='git commit'
alias branch='git branch'
alias pull='git pull'
alias fetch='git fetch'
alias merge='git merge'
alias push='git push'

# docker
alias dp='docker ps'
alias dpa='docker ps -a'

# ssh
alias keygen='ssh-keygen -t rsa -C "typebrook@gmail.com"'
alias topo='ssh typebrook@topo.tw'
alias ptt='ssh bbsu@ptt.cc'
alias geothings='ssh geothings@geobingan.info'
alias test='ssh geothings@test.geothings.tw'

# tig
alias t='tig'
alias ta='tig --all'
alias ts='tig status'
alias tg='tig grep'
alias tr='tig refs'
alias tl='tig log'
alias ty='tig stash'

# adb
alias debug='./gradlew app:installDebug && adb shell am start -n adb shell am start -n com.geothings.geobingan/.MainActivity_'

# misc
alias ll='ls -lh'
alias v='vim'
alias ai='sudo apt-get install'
alias hg='history|grep'
alias co='curl -O'
alias taiwan='curl -O http://download.geofabrik.de/asia/taiwan-latest.osm.pbf'
alias x='xdg-open'
alias f='free -h'
alias yl='youtube-dl'
alias raw='echo "https://raw.githubusercontent.com"'

# tmp
alias geo='cd ~/git/geoBingAnWeb'
alias cdo='cd ~/git/openmaptiles'
alias and='cd ~/git/geoBingAn.Android'
