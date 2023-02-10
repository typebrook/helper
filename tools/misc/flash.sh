#! /bin/bash

CARD="$(cat ~/log/flashcards.md | shuf | head -1)"

# Print the Question
<<<"$CARD" tr -s '\t' | cut -f1
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
else
  tput setaf 1
  echo $ANSER
fi

# Quit when getting Line Feed
read
