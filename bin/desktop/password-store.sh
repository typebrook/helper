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
  elif [[ $ARG1 == edit ]]; then
    # Edit an existing password
    alacritty --hold -e pass edit $ARG2 && \
	rofi -e Password Edited: $ARG2
  else
	# If pass fails, then it means password doesn't exists
	set pipefail

    pass $ARG1 | {
      # If command fails, just fail directly
      read PASSWORD; [[ -z $PASSWORD ]] && exit 1

      # Simply copy password into system clipboard
      echo $PASSWORD | xsel -ib

      # Show success message, and display extra contents
      rofi "${ROFI_ARGS[@]}" \
        -e "Copied: $ARG1 $(echo; echo; cat | sed '1{/^$/d}')"
    } || {
	  # Make sure user want to create a new password
      return_code=$(alacritty -e sh -c '
	    dialog --yesno "Password does not exist, Generate a new one?" 8 30;
		echo "$?"
	  ')
      [[ $return_code == 1 ]] && exit 1

	  # Generate a new password by ARG1
	  alacritty -e pass generate $ARG1 --clip && \

      # Show success message
	  rofi "${ROFI_ARGS[@]}" -e "Password Created and Copied: $ARG1"
	}

	# TODO: if return code is 2, it means gpg password is not cached
  fi
}
