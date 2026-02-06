#! /bin/bash

# shell opt/trap {{{
shopt -s nocasematch extglob
MAIL="$(cat)"

# Only execute the following script when mail receiver is log@topo.tw
grep -qE -e '^Delivered-To: log@topo.tw$' -e '^ChatVersion' <<<"$MAIL" \
|| exit 0

MESSAGE="$(<<<"$MAIL" sed -n '/^$/,$ p' | sed -n 2p)"
# }}}
# special char for commands {{{
if [[ "$MESSAGE" =~ ^[[:alpha:]]" " ]]; then
  line_num=$(cut -d' ' -f2 <<<"$MESSAGE")
  case "$MESSAGE" in
    # HELP: ":d <LINE> 3" to tag as #done:<3-DAYS-BEFORE>
    # HELP: ":d <LINE> wed" to tag as #done:<LAST-WEDNESDAY >
    :d* )
      time=$(<<<"$MESSAGE" cut -d" " -f3)
      case "$time" in
        [[:digit:]]* ) date=$(date --iso --date="-${time}days") ;;
        [[:alpha:]]* ) date=$(date --iso --date="last ${time}") ;;
        * ) date=$(date --iso) ;;
      esac
      sed -Ei "$line_num s/ #(todo|done[^ ]*)/ #done:${date}/" ~/LOG
      ;;
    # HELP: ":r <LINE> <CONTENT>" to rewrite specific line
    :r* )
      content="$(cut -d' ' -f3- <<<"$MESSAGE")"
      sed -i "$line_num s/^.*$/$content/" ~/LOG
      ;;
    # HELP: ":a <LINE> <CONTENT>" to append contents
    :a* )
      content="$(cut -d' ' -f3- <<<"$MESSAGE")"
      sed -i "$line_num s/\$/ $content/" ~/LOG
      ;;
    # HELP: ":s <TARGET> <DEST>" to substitute a word
    :s* )
      target="$(cut -d' ' -f3 <<<"$MESSAGE")"
      dest="$(cut -d' ' -f4- <<<"$MESSAGE")"
      sed -i "$line_num s/$target/$dest/" ~/LOG
      ;;
  esac
  exit 0
fi
# }}}
# reply something from query {{{

# special char for metadata
if [[ "$MESSAGE" =~ ^# ]]; then
  # HELP: "#t" to list all tags
  if [ "$MESSAGE" = '#t' ]; then
    REPLY="$(<LOG grep -Eo '#[^#: ]+' | sort | uniq -c | sort -n)"
  elif [ "$MESSAGE" = '#c' ]; then
    REPLY="$(<$0 sed -En '/^ *# HELP: / {s/[^:]+:(.*)/\1\n/; p}')"
  fi
elif [[ "$MESSAGE" =~ ^/ ]]; then
  # HELP: "/<WORD>" to search by string
  REPLY="$(<~/LOG nl --body-numbering=a | grep -i "${MESSAGE#/}")"
fi

if [ -n "$REPLY" ]; then
  smtp pham@topo.tw <<-MAIL
	From: <log@topo.tw>
	Content-Type: text/plain; charset="utf-8"
	In-Reply-To: $(<<<"$MAIL" grep In-Reply-To: | head -1 | grep -o '<.*>')
	Message-ID: $(date --iso=seconds)
	Chat-Version: 1.0
	Chat-Disposition-Notification-To: pham@topo.tw
	Subject: Message from log@topo.tw

	$REPLY
	MAIL
  exit 0
fi
# }}}
# write message to log {{{

# HELP: "@<TIME>" to specify date of message
if [[ "$MESSAGE" =~ ^@[[:alnum:]]+" ".+$ ]]; then
  datestring=${MESSAGE%% *}; datestring=${datestring#@}
  # parse token as N days before
  [[ $datestring =~ ^[[:digit:]]+$ ]] && DATE=$(date --iso -d "-$datestring days")
  # parse token as last X weekday
  [[ $datestring =~ ^[[:alpha:]]+$ ]] && DATE=$(date --iso -d "last $datestring")

  [ -z "$DATE" ] && echo fail to parse date >>~/log.log && break

  line_num=$(grep -n "^## $DATE" | cut -d: -f1)
  sed -i "${line_num}i $(cut -d' ' -f2-)" ~/LOG
elif [[ ! "$MESSAGE" =~ ^[/:#]|^@[[:alnum:]]+" ".+$ ]]; then
  # HELP: "." to add tag #todo
  [[ "$MESSAGE" =~ ^\. ]] && MESSAGE="${MESSAGE#.} #todo"
  # HELP: "+" to add tag #buy
  [[ "$MESSAGE" =~ ^\+ ]] && MESSAGE="${MESSAGE#+} #buy"

  echo "$MESSAGE" >>~/LOG
fi
# }}}

# vim:fdm=marker fdl=0
