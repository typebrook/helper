#! /bin/bash

LIST=~/.repos
[[ $1 == -n ]] && {
  COUNT_ONLY=true 
  count=0
}


# Only works when file ~/.repos exists and readable
if [ ! -r $LIST ]; then
  echo File ~/.repos not found/readable
  exit 1
fi


while read repo remote; do
  [[ "$repo" =~ ^[[:space:]]*#.* ]] && continue

  # In case repo is consists of variable like $HOME
  # Use eval to get git information
  eval cd $repo 2>/dev/null || {
    echo Repo $repo is inaccessible
    exit 1
  }

  # Changes in working dir, not yet to be a commit
  changes="$(git -c color.status=always status --short)"

  # Diff between from local repo and remote
  cherry="$(git cherry)"

  if [[ $COUNT_ONLY == true ]]; then
    # If '-n' is specified, only count repo with changes/local-diff
    [[ -n "$changes" || -n "$cherry" ]] && (( count++ ))
  else
    # Or, just print their status
    echo Check $repo
    [[ -n "$changes" ]] && echo "$changes"
    [[ -n "$cherry" ]] && echo -e "\e[31m[ahead]\e[0m"
  fi
done <$LIST


# If '-n' is specified, print number of repos with changes/local-diff
[[ $COUNT_ONLY == true ]] && echo $count

exit 0
