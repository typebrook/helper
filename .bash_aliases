# settings
alias al='vim ~/.bash_aliases && source ~/.bash_aliases'
alias sa='source ~/.bash_aliases'
alias vimrc='vim ~/.vimrc'
alias bashrc='vim ~/.bashrc'
alias tigrc='vim ~/.tigrc'

# vim
alias v='vim'
alias vr='vim -R'

# shell
alias ll='ls -lh'
alias ai='sudo apt-get install'
alias si='sudo snap install'
alias ss='sudo !!'
alias hg='history|grep'
alias r='ranger'

# cd to certain directories
alias ..='cd ..'
alias cdd='cd ~/Downloads'
alias cdg='cd ~/git'
alias cds='cd ~/git/settings'
alias r='ranger'

# git
alias g='git'
alias gls='git log -S'
alias gc='git clone'
alias check='git checkout'
alias checkout='git checkout'
alias stash='git stash'
alias commit='git commit'
alias ca='git commit --amend'
alias branch='git branch'
alias pull='git pull'
alias fetch='git fetch'
alias merge='git merge'
alias push='git push'
alias remote='git remote'
alias rebase='git rebase'

# docker
alias dp='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dc='docker-compose run --rm'

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

# Android
alias debug='./gradlew app:installDebug && adb shell am start -n adb shell am start -n com.geothings.geobingan/.MainActivity_'
alias adbdefault='adb shell dumpsys package domain-preferred-apps'
alias adblist='adb shell dumpsys package d'
alias rmcache='rm -rf ~/.gradle/caches/modules-2/files-2.1/org.jetbrains.kotlin/kotlin-stdlib-jdk7/*'

# gist
gist_list=~/gist/gist.list
alias gl='nl $gist_list'
alias gll='gist -l > $gist_list && nl $gist_list'
alias gi='_gistRead'
_gistRead() { 
    gist -r $(awk '{print $1}' $gist_list  | awk -v row="$1" -F '/' 'FNR==row {print $NF}') $2
}
alias note='gist -r 5dd936e91d9ae75ad77084da762f5c11 note > ~/gist/note && \
            vim ~/gist/note && \
            gist -u 5dd936e91d9ae75ad77084da762f5c11 ~/gist/note'
alias todo='gist -r 5dd936e91d9ae75ad77084da762f5c11 todo > ~/gist/todo && \
            vim ~/gist/todo && \
            gist -u 5dd936e91d9ae75ad77084da762f5c11 ~/gist/todo'

# misc
alias co='curl -O'
alias taiwan='curl -O http://download.geofabrik.de/asia/taiwan-latest.osm.pbf'
alias x='xdg-open'
alias f='free -h'
alias yl='youtube-dl'
alias raw='echo "https://raw.githubusercontent.com"'
alias editor='select-editor'

# tmp
alias cdo='cd ~/git/openmaptiles'
alias and='cd ~/git/geoBingAn.Android'
alias gdal='docker-compose run --rm gdal'
alias mm='mkvmerge -o out.webm -w 01.webm + 02.webm'
