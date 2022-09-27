#! /bin/bash

# Use rofi to quickly access password by command 'pass'
# xsel needed !!

ROFI_ARGS=( "-font" "Hack 22" )

find ~/.password-store -name '*gpg' -printf %P\\n | \
sed 's/.gpg$//' | \
rofi -dmenu "${ROFI_ARGS[@]}" | {
  # Get arguments for command 'pass'
  read ARG1 ARG2

  if [[ -z $ARG1 ]]; then
    exit 1
  elif [[ $ARG1 =~ gen ]]; then
    # Generate a new password by ARG2
    alacritty --hold -e pass --clip generate $ARG2
  else
    pass $ARG1 | {
      # If command fails, just fail directly
      read PASSWORD; [[ -z $PASSWORD ]] && exit 1

      # Simply copy password into system clipboard
      echo $PASSWORD | xsel -ib

      # Show success message, and display extra contents
      rofi -e "Copied: $ARG1 $(echo; echo; cat | sed '1{/^$/d}')" \
      "${ROFI_ARGS[@]}" 
  }
  fi
}
