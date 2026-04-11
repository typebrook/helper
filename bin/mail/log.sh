#! /bin/bash
#  import email, sys
#  msg = email.message_from_file(sys.stdin)
#  for part in msg.walk():
#      if part.get_content_type() == 'text/plain':
#          print(part.get_payload(decode=True).decode(part.get_content_charset() or 'utf-8'))

# DEBUG {{{
exec &>>log.log
printf '%0.s>' {1..30}; echo
trap "set +x; printf '%0.s<' {1..30}; echo" EXIT
date --iso=seconds

export PS4='Line ${LINENO}: '
set -x
echo ENV:
env | tr '\n' ' '
# }}}
# shell opt/var {{{
shopt -s nocasematch extglob

if [ -n "$RECIPIENT" ]; then
  [[ "$SENDER$RECIPIENT" =~ .*log@topo.tw.* ]] || exit 0
  MAIL=$(python3 -c '
import sys
import email
from email import policy

# Read raw email from stdin
raw = sys.stdin.buffer.read()

# Parse with modern policy (handles encoding automatically)
msg = email.message_from_bytes(raw, policy=policy.default)

# Access headers
for header, value in msg.items():
  print(header + ": " + value)

# Get body as UTF-8
for part in msg.walk():
    if part.get_content_type() == "text/plain":
        print(part.get_content())
  ')
  HEADER="$(<<<${MAIL} sed -n '1,/^$/p')"
  echo -e "$HEADER" | grep -q '^Chat-Version: ' || exit 0
  replyto=$(<<<"$HEADER" awk '/^Message-I[Dd]:/{print $2}' )
  MESSAGE="$(<<<$MAIL tac | sed -n '/^$/!{p;q}')"
else
  MESSAGE="$(tail -1)"
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
  REPLY=$(<~/LOG awk -v query="${MESSAGE#/}" '
   /^## /{date="\n"$2" "$3; next}
   $0~query{
     if(date!=""){print date;date=""}
     print NR,$0
     leading_space=match($0, /[^[:space:]]|$/) - 1
     next
   }
   match($0, /[^[:space:]]|$/)-1 > leading_space { print; next }
   {leading_space=9999}
  ')
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
  smtp -s localhost:2525 pham@topo.tw <<-MAIL
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

