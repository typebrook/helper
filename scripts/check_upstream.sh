# check git repo $1 if upstream branch
# origin/master is ahead of local branch $2(default to dev)
check_upstream() {

    if [ ! -d $1 ]; then
        return 0
    fi

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

    cd ~/git/settings
    echo check $1 at $(date) >> ./log
}
