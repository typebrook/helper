#! /usr/bin/env bash
# Get the first remote URL within git/https protocol on github.com
# Swap the protocol, and apply new protocol to every remaining remotes

target=''
extra=''

# For each remote
git remote -v \
| while read remote url etc; do
  # Set fetch/push URL seperately
  [[ $etc =~ push ]] && extra='--push' || extra=''

  if [[ $url =~ git@.*github.com ]]; then
    target=${target:-https}
    # git@ -> https://
    [[ $target == https ]] && sed -E 's#^git@(.+):(.+)$#https://\1/\2#' <<<$url | xargs git remote set-url $extra $remote
  elif [[ $url =~ https://.*github.com ]]; then
    target=${target:-git}
    # https:// -> git@
    [[ $target == git ]] && sed -E 's#^https://([^/]+)/(.+)$#git@\1:\2#' <<<$url | xargs git remote set-url $extra $remote
  fi
done

git remote -v
