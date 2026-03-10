#! /bin/bash

# DEBUG {{{
exec &>>log.log
printf '%0.s>' {1..30}; echo
trap "set +x; printf '%0.s<' {1..30}; echo" EXIT
date --iso=seconds

export PS4='Line ${LINENO}: '
set -x
# }}}
# shell opt/var {{{
shopt -s nocasematch extglob

if [ -n "$SENDER" ]; then
  trap 'rm -rf ${tmp_mailbox}' EXIT
  tmp_mailbox=$(mktemp -d); mkdir -p ${tmp_mailbox}/{tmp,new,cur}
  cat >${tmp_mailbox}/cur/mail
  HEADER=$(decodemail ${tmp_mailbox} | sed '/^$/q')
  [ "$RECIPIENT" = 'log@topo.tw' ] || exit 0
  echo -e "$HEADER" | grep -o '^Chat-Version: ' || exit 0
  export replyto=$(<<<"$HEADER" awk '/^Message-I[Dd]:/{print $2}' )
  MESSAGE="$(sed -n '/^$/,$ p' | sed -n 2p)"
else
  MESSAGE="$(cat)"
fi
#echo "$MAIL" >~/log.mail

# MESSAGE: the first line of mail body
#MESSAGE="$(<<<"$MAIL" sed -n '/^$/,$ p' | sed -n 2p)"
echo MESSAGE: $MESSAGE

# DATE: parse @<DATE> as ISO 8601 format
if [[ "$MESSAGE" =~ ^@ ]]; then
  datestring=${MESSAGE%% *}; datestring=${datestring#@}
  # parse token as N days before
  [[ $datestring =~ ^[[:digit:]]+$ ]] && DATE=$(date --iso -d "-$datestring days")
  # parse token as last X weekday
  [[ $datestring =~ ^[[:alpha:]]+$ ]] && DATE=$(date --iso -d "last $datestring")
  echo DATE: $DATE
fi
# }}}
# special char for commands {{{
if [[ "$MESSAGE" =~ ^: ]]; then
  case "$MESSAGE" in
    # HELP: ":! <LINE> <COMMAND>" to execute a command
    :!* | ::* )
      command="$(<<<$MESSAGE cut -b3-)"
      REPLY="$(<LOG bash -c "$command")"
      ;;
    *)
      line_num=$(cut -d' ' -f2 <<<"$MESSAGE")
      content="$(cut -d' ' -f3- <<<"$MESSAGE")"
    ;;&
    # HELP: ":d <LINE> 3" to tag as #done:<3-DAYS-BEFORE>
    # HELP: ":d <LINE> wed" to tag as #done:<LAST-WEDNESDAY >
    :d* )
      time="$content"
      case "$time" in
        [[:digit:]]* ) date=$(date --iso --date="-${time}days") ;;
        [[:alpha:]]* ) date=$(date --iso --date="last ${time}") ;;
        * ) date=$(date --iso) ;;
      esac
      sed -Ei "$line_num s/ #(todo|done[^ ]*)/ #done:${date}/" ~/LOG
      ;;&
    # HELP: ":r <LINE> <CONTENT>" to rewrite specific line
    :r* )
      sed -i "$line_num s/^.*$/$content/" ~/LOG
      ;;&
    # HELP: ":a <LINE> <CONTENT>" to append contents
    :a* )
      sed -i "$line_num s/\$/ $content/" ~/LOG
      ;;&
    # HELP: ":s <TARGET> <DEST>" to substitute a word
    :s* )
      target="$(cut -d' ' -f3 <<<"$MESSAGE")"
      dest="$(cut -d' ' -f4- <<<"$MESSAGE")"
      sed -i "$line_num s/$target/$dest/" ~/LOG
      ;;&
    # HELP: ":o <LINE> <MESSAGE>" to add a list item
    :o* )
      content="- $content"
      sed -Ei "${line_num}"'a\'"$content" ~/LOG
      ;;&
    * )
      exit 0
      ;;
  esac
fi
# }}}
# query something {{{

# special char for metadata
if [ "$MESSAGE" = '#t' ]; then
  # HELP: "#t" to list all tags
  REPLY="$(<LOG grep -Eo '#[^#: ]+' | sort | uniq -c | sort -n)"
elif [ "$MESSAGE" = '#c' ]; then
  # HELP: "#c" to list all commands
  REPLY="$(<$0 sed -En '/^ *# HELP: / {s/[^:]+:(.*)/\1\n/; p}')"
elif [[ "$MESSAGE" =~ ^/ ]]; then
  # HELP: "/<WORD>" to search by string
  REPLY=$(<~/LOG awk -v query="${MESSAGE#/}" '/^## /{date="\n"$2" "$3} $0~query{if(date!=""){print date;date=""}print NR,$0}')
  REPLY=${REPLY:-Nothing Found}
elif [[ "$MESSAGE" =~ ^@[[:alnum:]]+$ && -n "$DATE" ]]; then
  # HELP: "@<DATE>" to print records by date
  REPLY="$(<~/LOG sed -n "/^## $DATE/,/^$/p")"
fi
# }}}
# write message to log {{{

# HELP: "@<TIME>" to specify date of message
if [ -z "$REPLY" ]; then
  # write message to a specific date
  if [ -n "$DATE" ]; then
    line_num=$(<~/LOG awk '/^## '$DATE'/,$0==""{print NR}' | tail -1)
    sed -i "${line_num}i $(<<<$MESSAGE cut -d' ' -f2-)" ~/LOG
  elif [ -n "$MESSAGE" ]; then
    # HELP: "." to add tag #todo
    [[ "$MESSAGE" =~ ^\. ]] && MESSAGE="${MESSAGE#.} #todo"
    # HELP: "+" to add tag #buy
    [[ "$MESSAGE" =~ ^\+ ]] && MESSAGE="${MESSAGE#+} #buy"

    echo "$MESSAGE" >>~/LOG
  fi

  REPLY="Line: $(wc -l ~/LOG | cut -d' ' -f1)"
fi
# }}}
# reply to sender {{{
echo replyto=$replyto
if [ -n "$REPLY" ] && [ -n "${replyto}" ]; then
  id=$(date --iso=seconds)
  smtp pham@topo.tw <<-MAIL
	From: <log@topo.tw>
	Content-Type: text/plain; charset="utf-8"
	In-Reply-To: ${replyto}
	Message-ID: ${id}
	Chat-Version: 1.0
	Chat-Disposition-Notification-To: pham@topo.tw
	Subject: Message from log@topo.tw

	${REPLY}
	MAIL
fi
# }}}
# vim:fdm=marker fdl=0
