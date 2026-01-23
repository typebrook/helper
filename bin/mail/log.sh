#! /bin/bash

# shell opt/trap {{{
shopt -s nocasematch extglob

# update index for dovecot
trap 'doveadm force-resync ${mailbox:-/}' EXIT

# temp file for decodemail (GNU Mailutils)
tmp_mailbox=$(mktemp -d); mkdir -p ${tmp_mailbox}/{tmp,new,cur}
cat >${tmp_mailbox}/cur/mail
trap 'rm -rf ${tmp_mailbox}' EXIT
# }}}
# vars about message {{{
MAIL="$(decodemail ${tmp_mailbox})"

# Only execute the following script when mail receiver is log@topo.tw
grep -qE -e '^Delivered-To: log@topo.tw$' -e '^ChatVersion' <<<"$MAIL" \
|| exit 0

MESSAGE="$(<<<"$MAIL" sed -n '/^$/,$ p' | sed -n 2p)"
# }}}
# write message to log {{{

if [[ ! "$MESSAGE" =~ ^[/:#] ]]; then
  [[ "$MESSAGE" =~ ^\. ]] && MESSAGE="${MESSAGE#.} #todo"
  [[ "$MESSAGE" =~ ^\+ ]] && MESSAGE="${MESSAGE#+} #buy"

  echo "$MESSAGE" >>~/LOG
  exit 0
fi
# }}}
# special char for commands {{{
if [[ "$MESSAGE" =~ ^: ]]; then
  line_num=$(cut -d' ' -f2 <<<"$MESSAGE")
  case "$MESSAGE" in
    # mark specific line as #done
    :d* )
      time=$(<<<"$MESSAGE" cut -d" " -f3)
      case "$time" in
        [[:digit:]]* ) date=$(date --iso --date="-${time}days") ;;
        [[:alpha:]]* ) date=$(date --iso --date="last ${time}") ;;
        * ) date=$(date --iso) ;;
      esac
      sed -Ei "$line_num s/ #(todo|done[^ ]*)/ #done:${date}/" ~/LOG
      ;;
    # rewrite specific line
    :r* )
      content="$(cut -d' ' -f3- <<<"$MESSAGE")"
      sed -i "$line_num s/^.*$/$content/" ~/LOG
      ;;
    # append contents to specific line
    :a* )
      content="$(cut -d' ' -f3- <<<"$MESSAGE")"
      sed -i "$line_num s/\$/ $content/" ~/LOG
      ;;
    # substitute a word on specific line
    :s* )
      target="$(cut -d' ' -f3 <<<"$MESSAGE")"
      dest="$(cut -d' ' -f4- <<<"$MESSAGE")"
      sed -i "$line_num s/$target/$dest/" ~/LOG
      ;;
  esac
  exit 0
fi
# }}}
# Query something {{{

# special char for help
if [[ "$MESSAGE" =~ ^# ]]; then
  if [ "$MESSAGE" = '#t' ]; then
    REPLY="$(<LOG grep -Eo '#[^#: ]+' | sort | uniq -c | sort -n)"
  fi
else
  REPLY="$(<~/LOG nl --body-numbering=a | grep -i "${MESSAGE#/}")"
fi

smtp pham@topo.tw <<EOF
From: <log@topo.tw>
Content-Type: text/plain; charset="utf-8"
In-Reply-To: $(<<<"$MAIL" grep In-Reply-To: | head -1 | grep -o '<.*>')
Message-ID: $(date --iso=seconds)
Chat-Version: 1.0
Chat-Disposition-Notification-To: pham@topo.tw
Subject: Message from log@topo.tw

$REPLY
EOF
# }}}

# vim:fdm=marker fdl=0
