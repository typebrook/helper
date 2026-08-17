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

# parse_date <token> [last|next] -> ISO date (YYYY-MM-DD); empty if unrecognised.
# <dir> (default last) sets the sense of relative tokens: last=past, next=future.
#   YYYY-MM-DD          absolute date, as-is
#   MM-DD               nearest that month/day in <dir> (this year or adjacent)
#   today | now         today
#   tomorrow            +1 day
#   yesterday           -1 day
#   <N>                 N days away in <dir>            (e.g. 3)
#   <N>d <N>w <N>m <N>y  N days/weeks/months/years in <dir>  (e.g. 2w)
#   +<N> -<N> (+ opt unit)  explicit signed offset, ignores <dir>  (e.g. +3, -2w)
#   <weekday>           last/next occurrence of that weekday (e.g. wed)
parse_date() {
  local s=$1 dir=${2:-last} sign
  [ "$dir" = next ] && sign=+ || sign=-
  if [[ $s =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    printf '%s\n' "$s"
  elif [[ $s =~ ^[0-9]{2}-[0-9]{2}$ ]]; then
    local today y cand
    today=$(date --iso); y=${today%%-*}; cand="$y-$s"
    [ "$dir" = next ] && [[ "$cand" < "$today" ]] && cand="$((y+1))-$s"
    [ "$dir" = last ] && [[ "$cand" > "$today" ]] && cand="$((y-1))-$s"
    printf '%s\n' "$cand"
  elif [[ $s == today || $s == now ]]; then
    date --iso
  elif [[ $s == tomorrow ]]; then
    date --iso -d tomorrow
  elif [[ $s == yesterday ]]; then
    date --iso -d yesterday
  elif [[ $s =~ ^([+-]?)([0-9]+)([dwmy]?)$ ]]; then
    local sg=${BASH_REMATCH[1]} n=${BASH_REMATCH[2]} u=${BASH_REMATCH[3]}
    case "$u" in w) u=weeks;; m) u=months;; y) u=years;; *) u=days;; esac
    [ -n "$sg" ] || sg=$sign
    date --iso -d "${sg}${n} ${u}"
  elif [[ $s =~ ^[[:alpha:]]+$ ]]; then
    date --iso -d "$dir $s"
  fi
}

if [ -n "$RECIPIENT" ]; then
  [[ "$SENDER$RECIPIENT" =~ .*log@topo.tw.* ]] || { cat > /dev/null; exit 0; }
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
  DATE=$(parse_date "$datestring")
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
      date=$(parse_date "$content"); date=${date:-$(date --iso)}
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
# calendar event {{{
# HELP: "<TEXT> #cal:YYYY-MM-DD" to add all-day CalDAV event on that date
# HELP: "<TEXT> #cal:wed" to add all-day event on next Wednesday (also tomorrow, 3, 2w, 12-25 ...)
if [[ "$MESSAGE" =~ \#cal:([[:alnum:]+-]+) ]]; then
  caltoken=${BASH_REMATCH[1]}
  caldate=$(parse_date "$caltoken" next)
  if [ -z "$caldate" ]; then
    calnote="Cal FAILED (bad date: ${caltoken})"
  else
    dtstart=${caldate//-/}
    dtend=$(date -d "${caldate} +1 day" +%Y%m%d)
    # SUMMARY = message minus the #cal tag, trimmed, then ICS-escaped
    summary="$(sed -E 's/[[:space:]]*#cal:[[:alnum:]+-]+//' <<<"$MESSAGE")"
    summary="${summary#"${summary%%[![:space:]]*}"}"
    summary="${summary%"${summary##*[![:space:]]}"}"
    esc=${summary//\\/\\\\}; esc=${esc//;/\\;}; esc=${esc//,/\\,}
    uid=$(cat /proc/sys/kernel/random/uuid)
    ics=$(printf 'BEGIN:VCALENDAR\r\nVERSION:2.0\r\nPRODID:-//log.sh//cal//EN\r\nBEGIN:VEVENT\r\nSUMMARY:%s\r\nDTSTART;VALUE=DATE:%s\r\nDTEND;VALUE=DATE:%s\r\nDTSTAMP:%s\r\nUID:%s\r\nEND:VEVENT\r\nEND:VCALENDAR\r\n' \
      "$esc" "$dtstart" "$dtend" "$(date -u +%Y%m%dT%H%M%SZ)" "$uid")
    code=$(curl -s -o /dev/null -w '%{http_code}' -X PUT \
      -H 'Content-Type: text/calendar; charset=utf-8' \
      --data-binary "$ics" \
      "http://127.0.0.1:8010/dav/user/calendars/calendar/${uid}.ics")
    echo "cal PUT $code uid=$uid"
    if [[ "$code" == 20* ]]; then
      calnote="Cal: ${summary} @ ${caldate}"
    else
      calnote="Cal FAILED (HTTP ${code})"
    fi
  fi
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
[ -n "$calnote" ] && REPLY="${REPLY:+$REPLY
}$calnote"
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

