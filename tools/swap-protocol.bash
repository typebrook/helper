#! /usr/bin/env bash

target=''
extra=''

# For each remote
git remote -v \
| while read remote url etc; do
  [[ $etc =~ push ]] && extra='--push' || extra=''
  if [[ $url =~ git@.*github.com ]]; then
    target=${target:-https}
    [[ $target == https ]] && sed -E 's#^git@(.+):(.+)$#https://\1/\2#' <<<$url | xargs git remote set-url $extra $remote
  elif [[ $url =~ https://.*github.com ]]; then
    target=${target:-git}
    [[ $target == git ]] && sed -E 's#^https://([^/]+)/(.+)$#git@\1:\2#' <<<$url | xargs git remote set-url $extra $remote
  fi
done

git remote -v
