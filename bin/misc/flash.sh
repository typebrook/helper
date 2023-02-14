#! /bin/bash

while true; do
  CARDS="$(cat ~/log/flashcards.md | shuf | head -5)"
  CARD="$(<<<"$CARDS" sed -n 3p)"

  # Print the Question
  <<<"$CARD" tr -s '\t' | cut -f1
  echo
  tput bold; tput setaf 1
  <<<"$CARDS" tr -s '\t' | cut -f2 | tr '\n' '\t'
  tput sgr0
  echo 
  echo
  echo ----
  echo

  # Get the User Input
  read -er INPUT

  # Print the Answer
  ANSER=$(<<<"$CARD" tr -s '\t' | cut -f2)
  echo
  echo ----
  echo

  # If answer correctly, print the checked box
  if [[ "$INPUT" == "$ANSER" ]]; then
    tput setaf 2
    echo '☑'
    tput setaf 7
  else
    echo $ANSER
  fi

  echo
  read
  tput clear
done
