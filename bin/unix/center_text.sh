#! /bin/bash

echo '\e[5 q'

while read -r -e text; do
  tput cuu1 civis

  width="$(tput cols)"
  left=$(( ($width - ${#text}) /2 ))
  right=$(( $width - $left - ${#text} ))

  echo -en '\r'
  eval "printf ' %.0s' {1..$left}"
  echo -n $text
  eval "printf ' %.0s' {1..$right}"
done
