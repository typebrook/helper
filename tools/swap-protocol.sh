#! /usr/bin/env bash

target=''
extra=''

git remote -v \
| while read remote url etc; do
  [[ $etc =~ push ]] && extra='--push'
  if [[ -z $target || $target == https ]] && [[ $url =~ git@.*github.com ]]; then
    target=${target:-https}
    sed -E 's#git@(.+):(.+)#https://\1/\2#' <<<$url | xargs git remote set-url $extra $remote
  elif [[ -z $target || $target == git ]] && [[ $url =~ https://.*github.com ]]; then
    target=${target:-git}
    sed -E 's#https://([^/]+)/(.+)#git@\1:\2#' <<<$url | xargs git remote set-url $extra $remote
  fi
done
