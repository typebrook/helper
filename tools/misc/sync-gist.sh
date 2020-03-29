#! /bin/bash

set -o pipefail
set -e

repo=~/gist/b0d2e7e67aa50298fdf8111ae7466b56

while read -r commit; do

  cd $repo
  git checkout $commit
  message="$(git show $commit | sed -n '1,4 d; /^diff/ q; s/^    //p')"

  cd ~/git/Bash-Snippets
  cp $repo/gist gist/gist
  git add gist/gist && git commit -m "$message"
done

cd $repo
git checkout master

