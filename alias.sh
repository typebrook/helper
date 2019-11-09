# settings
alias al="vim $0 && source $0"
alias all="source $0"
alias bashrc='vim ~/.bashrc && source ~/.bashrc'
alias zshrc='vim ~/.zshrc && source ~/.zshrc'
alias vimrc='vim ~/.vimrc'
alias tigrc="vim $SETTING_DIR/tigrc"
alias gitconfig='vim ~/.gitconfig'
alias log='cat log | grep "`date +"%b %d"`"'

# vim
alias v='vim'
alias vv='vim ~/vimwiki/index.md'
wiki() {
    cat ~/vimwiki/$1.md
}
alias ve='vim ~/.vim_runtime/my_configs.vim'
alias vr='vim -R'
alias cdv='cd ~/.vim_runtime' # amix/vimrc repo

# shell
alias src="source $HOME/.$(basename $SHELL)rc"
alias ll='ls -alh'
alias ai='sudo apt install' # apt install
alias si='sudo snap install' # snap install
alias ni='sudo npm install -g' # nodejs install
alias ss='sudo !!'
alias hg='history|grep'
alias rr='move_to_tmp'
move_to_tmp() {
    mv $1 /tmp
}

# cd to DIRs
alias ..='cd ..'
alias ld='cd -' # last directory
alias cdg='cd ~/git'
alias cdd='cd ~/Downloads'
alias cdD='cd ~/Documents'
alias cdV='cd ~/Videos'
alias cdP='cd ~/Pictures'

# about custom settings
alias cds='cd $SETTING_DIR'
alias cdss='cd $SETTING_DIR/scripts'
alias chs='cd $SETTING_DIR && tig status' # check setting changes

# about vimwiki
alias cdw='cd ~/vimwiki'
alias chw='cd ~/vimwiki && tig'
alias ww='cd ~/vimwiki && git add * && git commit -am "update" && git push'

# crontab
alias ce='crontab -e'

# ranger
alias r='_ranger-cd'
alias ranrc='vim ~/.config/ranger/rc.conf'
_ranger-cd() {
    tempfile="$(mktemp -t tmp.XXXXXX)"
    ranger --choosedir="$tempfile" "${@:-$(pwd)}"
    test -f "$tempfile" &&
    if [ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]; then
        cd -- "$(cat "$tempfile")"
    fi
    rm -f -- "$tempfile"
}

# disk
alias df='df -h'

# git
alias gc='git clone'
alias gc1='git clone --depth=1'
gcg() {
    git clone git@github.com:$1/$2.git
}
alias gls='git log -S'
alias cdgs='cd $(git submodule status | sed "s/^.//" | cut -d" "  -f2)' # cd to first submodule

# docker
alias dp='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dc='docker-compose run --rm'
alias dstop='docker stop'
alias ds='docker stop'
alias drm='docker rm'

# ssh
alias keygen='ssh-keygen -t rsa -C "typebrook@gmail.com"'
alias topo='ssh typebrook@topo.tw'
alias ptt='ssh bbsu@ptt.cc'
alias geothings='ssh geothings@geobingan.info'
alias geothings-test='ssh geothings@test.geothings.tw'

# tig
alias cdt='cd ~/git/tig'
alias t='tig'
alias ts='tig status'
alias ta='tig --all'
alias get-tig='curl -LO https://github.com/typebrook/tig/releases/download/tig-2.4.1/tig'
alias upload-tig="$SETTING_DIR/scripts/upload-github-release-asset.sh github_api_token=$(head -1 $SETTING_DIR/tokens/github-release) owner=typebrook repo=tig tag=tig-2.4.1 filename=$(which tig)"

# Android
alias debug='./gradlew app:installDebug && adb shell am start -n com.geothings.geobingan/.MainActivity_'
alias adb-default='adb shell dumpsys package domain-preferred-apps'
alias adb-list='adb shell dumpsys package d'
alias rmcache='rm -rf ~/.gradle/caches/modules-2/files-2.1/org.jetbrains.kotlin/kotlin-stdlib-jdk7/*'
alias adb-last-screenshot='adb pull /sdcard/Screenshots/`adb shell ls -t /sdcard/Screenshots/ | head -1` ~/Desktop'
alias adb-push='adb push /sdcard/Download/'

# gist
gist_list=~/gist/gist.list
alias gl='nl $gist_list'
alias gll='gist -l > $gist_list && nl $gist_list'
alias gi='_gistRead'
alias gd='_gistDelete'
_gistRead() {
    gist -r $(awk '{print $1}' $gist_list  | awk -v row="$1" -F '/' 'FNR==row {print $NF}') $2
}
_gistDelete() {
    deleted=~/gist/deleted/$(date +"%s")
    _gistRead $1 > $deleted && echo "backup at $deleted"
    gist --delete $(awk '{print $1}' $gist_list | awk -v row="$1" -F '/' 'FNR==row {print $NF}') && \
    gll
}

# curl
alias co='curl -O'
alias curl.code='curl -o /dev/null --silent -Iw "%{http_code}"'

# python
alias pip3='python3 -m pip'

# gdal
alias oo='ogr2ogr'
alias oi='ogrinfo'
alias oias='ogrinfo -al -so'

# sample file
alias sample-gpx='curl -O https://docs.mapbox.com/help/data/run.gpx'
alias sample-geojson='curl -O https://docs.mapbox.com/help/data/stations.geojson'
alias sample-geotiff='curl -O https://docs.mapbox.com/help/data/landsat.tif'
alias sample-csv='curl -O https://docs.mapbox.com/help/data/airports.csv'
alias sample-svg='curl -O https://docs.mapbox.com/help/data/bicycle-24.svg'
alias sample-mbtiles='curl -O https://docs.mapbox.com/help/data/trails.mbtiles'
alias sample-kml='curl -O https://docs.mapbox.com/help/data/farmers_markets.kml'

# data file
alias taiwan='curl -O http://download.geofabrik.de/asia/taiwan-latest.osm.pbf'
alias data-taiwan-town='curl -o town.zip -L http://data.moi.gov.tw/MoiOD/System/DownloadFile.aspx\?DATA\=CD02C824-45C5-48C8-B631-98B205A2E35A'
alias data-taiwan-village='curl -o village.zip -L http://data.moi.gov.tw/MoiOD/System/DownloadFile.aspx\?DATA\=B8AF344F-B5C6-4642-AF46-1832054399CE'
alias data-rudymap='curl -O https://raw.githubusercontent.com/alpha-rudy/taiwan-topo/master/styles/mapsforge_style/MOI_OSM.xml'
alias data-osm-diff="curl https://planet.openstreetmap.org/replication/minute/state.txt |\
                     sed -n 2p | cut -d'=' -f2 | sed -r 's/(.{1})(.{3})/00\1\/\2\//' |\
                     xargs -I {} echo -e https://planet.openstreetmap.org/replication/minute/'{}'.osc.gz |\
                     xargs curl -O"

# clipboard
alias xi='xsel -ib'
alias xo='xsel -ob'
alias xl='history | tail -1 | grep -oP "^\s*[0-9]+\s\s\K.*" | xsel -ib && xsel -ob '
alias xll='xo >> ~/vimwiki/working.md'
alias xc='xsel -ob | gcc -xc -'

# image
vertical() {
    convert $@ -append output.png
}

# misc
alias gr='_grepString'
_grepString() {
    grep -R $1 .
}
alias findn='find . -iname'
alias wcl='wc -l'
alias x='xdg-open'
alias f='free -h'
alias yl='youtube-dl'
alias yla='youtube-dl -x --audio-format mp3'
alias raw='echo "https://raw.githubusercontent.com" | xsel -ib  && xsel -ob'
alias editor='select-editor'
alias hp='http-prompt'
alias clocg='cloc --vcs=git'
alias tma='tmux a'
alias mm='mkvmerge -o out.webm -w 01.webm + 02.webm'
alias du='ncdu'
alias we='weechat'
mvt_decode() {
    python3 $SETTING_DIR/scripts/mvt_decode.py $1 | tr \' \" | sed 's/True/true/g' | jq .
}
big52utf8() {
    iconv -f BIG-5 -t UTF-8 $1 > $1.utf8
}

# tmp
alias cdo='cd ~/git/openmaptiles'
alias cdoo='cd ~/git/openmaptiles/styles/outdoor'
alias cdS='cd ~/git/StreetComplete'
alias cdW='cd ~/git/geoBingAnWeb'
alias and='cd ~/git/geoBingAn.Android'
alias cdG='cd ~/git/git'
alias cdp='cd ~/git/parse-style'
alias cdand='cd ~/git/sample'

repo='git@github.com'
hub='https://github.com'
typebrook='git@github.com:typebrook'
