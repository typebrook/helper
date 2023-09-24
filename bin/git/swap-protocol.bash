#! /usr/bin/env bash

# Swap protocol for every git remotes, for example:
#   git@gitlab.com:me/repo ->
#   https://gitlab.com/me/repo

login=${1:-git}
extra=''

# For each remote
git remote -v \
| while read remote url etc; do
  # Set fetch/push URL seperately
  [[ $etc =~ push ]] && extra='--push' || extra=''

  if [[ $url =~ : ]]; then
    # git@ -> https://
    <<<$url sed -E 's#^.+@(.+):(.+)$#https://\1/\2#' | xargs git remote set-url ${extra} ${remote}
  elif [[ $url =~ ^http ]]; then
    # http[s]:// -> git@
    <<<$url sed -E "s#^https?://([^/]+)/(.+)\$#${login}@\1:\2#" | xargs git remote set-url ${extra} ${remote}
  fi
done

# Print current remotes
git remote -v
