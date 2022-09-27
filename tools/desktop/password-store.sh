#! /bin/bash

find ~/.password-store -name '*gpg' -printf %P\\n | \
sed 's/.gpg$//' | \
rofi -dmenu -font 'Hack 22' | {
  read ARG1 ARG2
  if [[ $ARG1 =~ gen ]]; then
	# Generate a new password by ARG2
    alacritty --hold -e pass generate $ARG2
  else
	pass $ARG1 | {
	  read PASSWORD
	  echo $PASSWORD | xsel -ib

	  rofi -e "Password Copied: $ARG1 $(echo; echo; cat | sed '1{/^$/d}')" \
		   -font 'Hack 22'
	}
  fi
}
