#! /bin/bash

LOG_FILE=~/log/context
context="$(cat ~/.task/context)"
count="$1"

if [ -z "$context" ] || [ "$context" = none ]; then 
  exit 1
fi

if [ -n "$1" ]; then
  # Update Log file
  while read -r ctx sec; do
    if [ "$ctx" = "$context" ]; then
      summary=$(( "$sec" + "$count" ))
      update=true
      break
    fi
  done <$LOG_FILE
  if [ "$update" = true ]; then
    sed -i -E "s/^$context.*/$context\t$summary" $LOG_FILE
  else
    echo -e "$context\t$summary" >>$LOG_FILE
  fi
else
  # Print times for each context
  while read -r ctx sec; do
    echo -ne "$ctx\t"
    date -u -d @"$sec" +%H:%M:%S
  done <$LOG_FILE
fi
