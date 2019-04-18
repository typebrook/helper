check_upstream() {

    head='dev'
    if [ $# -eq 2 ]
    then
        head=$2
    fi

    cd ~/$1
    git fetch origin && \
    git rev-list $head | grep $(git rev-parse origin/master) > /dev/null

    if [ $? -ne 0 ]
    then
        echo "New commit at" $1
    fi
}

cd ~/git/settings && git pull --quiet &
cd ~/vimwiki && git pull --quiet &
check_upstream git/tig &
check_upstream .vim_runtime &
