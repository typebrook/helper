#! /bin/bash

# Process each incoming mail
# TODO image/audio mail part

exec 2>>~/Downloads/delivery.log

shopt -s nocasematch

# update index for dovecot
trap 'doveadm force-resync ${mailbox:-/}' EXIT

# Restore mail into variables
MAIL="$(tr -d '\r')"
header="$(<<<"$MAIL" sed '/^$/ q; /^[[:blank:]]/ d;')"
body="$(<<<"$MAIL" sed -n '/^$/,$ p' | sed '1d')"

# vars about output
date=$(date --iso=seconds)
maildir=${HOME}/Maildir
mailbox=

# Set set_stdout
set_stdout() {
  name=${Subject// /_}

  # process encoded string (RFC2047)
  if [[ $name =~ ^=?utf-8?B? ]]; then
    shopt -s lastpipe; set +m
    echo "$name" | cut -d '?' -f4 | base64 -d | read name
  fi

  path=${maildir}/${mailbox}${mailbox:+/}new/${date//:/}.${name//[^[:alnum:]_]/}
  mkdir -p $(dirname $path)

  exec 1>$path
}

print_mail() {
  echo "$MAIL"
}

# save each field of header into vars
# TODO Use GNU MailUtils to save header
while IFS=: read field value; do
  declare ${field//-/_}="${value# }"
done <<<"$header"

# save to mailbox
if [[ "$SENDER" = pham@topo.tw && -n $Chat_Version ]]; then
  mailbox=box

  print_mail() {
    <<-MAIL cat
		From: me
		Date: $(date --rfc-email)
		Message-ID: ${Message_ID}
		Subject: $(head -1 <<<"$body")

		$(sed 1d <<<"$body")
	MAIL
  }
elif [[ "$List_ID" =~ ^~rjarry/aerc-discuss ]]; then
  mailbox=list/aerc
elif [[ "$List_ID" =~ '<mutt-users.mutt.org>' ]]; then
  mailbox=list/mutt
elif [[ "$Subject" =~ 'login|verify|sign-in|密碼|安全性警示|登入' ]]; then
  mailbox=login
elif [[ "$To" = cloudflare@topo.tw ]]; then
  mailbox=service
elif [[ "$TO" = ithelp@topo.tw ]]; then
  mailbox=promote
fi

set_stdout && print_mail
