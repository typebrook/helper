#! /bin/bash

# Deliver incoming mail to proper mailbox
# TODO image/audio mail part

epoch=$(date +%s)
mail_date="$(date --rfc-email -d @${epoch})"

# shell opt/trap {{{
shopt -s nocasematch extglob

# update index for dovecot
trap 'doveadm force-resync ${mailbox:-/}' EXIT

# temp file for decodemail (GNU Mailutils)
tmp_mailbox=$(mktemp -d); mkdir -p ${tmp_mailbox}/{tmp,new,cur}
cat >${tmp_mailbox}/cur/mail
trap 'rm -rf ${tmp_mailbox}' EXIT
# }}}
# log each delivery {{{
log=~/Maildir/cur/deliver.log.${epoch}
trap 'doveadm force-resync /' EXIT

# add a new log file, or reuse existing log file
outdated_log=$(grep -rlE 'From:\s+<?MDA' ~/Maildir/cur | head -1)
if [ -z "$outdated_log" ]; then
  <<-HEADER cat >${log}
	From: MDA <pham@topo.tw>
	Date: ${mail_date}
	Message-ID: <$log>
	Content-Type: text/plain; charset=UTF-8
	Subject: Delivery Log

	HEADER
else
  mv "$outdated_log" $log
  sed -i "1,/^$/ {s#^Date: .*#Date: ${mail_date}#; s#^Message-ID: .*#Message-ID: <${log}>#}" $log
fi

# Set stderr after process $log properly
exec 2>>$log
# }}}
# vars about message {{{
MAIL="$(decodemail ${tmp_mailbox})"
# TODO process multi-line header field
header="$(<<<"$MAIL" sed '/^$/ q; /^[[:blank:]]/ d;')"
body="$(<<<"$MAIL" sed -n '/^$/,$ p' | sed '1d')"

# vars about output
date=$(date --iso=seconds)
maildir=${HOME}/Maildir
mailbox=
# }}}
# FUNCTION: Set set_stdout {{{
set_stdout() {
  filename=${Subject// /_}
  path=${maildir}/${mailbox}${mailbox:+/}new/${date//:/}.${filename//[^[:alnum:]_]/}
  mkdir -p $(dirname $path)

  exec 1>$path
}
# }}}
# FUNCTION: print mail {{{
print_mail() {
  if [ "$private" = true ]; then
    <<-MAIL cat
		From: me <pham@topo.tw>
		Date: ${mail_date}
		Message-ID: ${Message_ID}
		Content-Type: text/plain; charset=UTF-8
		Self: true
		Subject: ${heading}

		$(sed 1d <<<"$body")
	MAIL
  else
    echo "$MAIL"
  fi
}
# }}}
# FUNCTION: save as private message {{{
private_message() {
  heading="$(head -1 <<<"${body}")"

  if [[ "${heading}" =~ ^"." ]]; then
    mailbox=act
    heading=${heading#.}
  else
    mailbox=box
  fi

  private=true
}
# }}}

# save each header field into vars {{{
# TODO Use GNU MailUtils to save header
while read line; do
  [[ "${line}" =~ ^" "|^"	" ]] && ${field}+=" ${line##*( )}" && continue

  IFS=': ' read field value <<<"${line}"
  field="${field^^}"
  field="${field//-/_}"
  declare ${field}="${value}"
done <<<"$header"
# }}}
# decide mailbox by vars {{{
if [[ "$SENDER" = pham@topo.tw && -n $CHAT_VERSION ]]; then
  private_message
elif [[ "${TO}" =~ '+'|'=' ]]; then
  mailbox=${TO#*[+=]}       # remove chars before symbol of mailbox
  mailbox=${mailbox%@*}     # remove suffix for mail address
elif [[ "${FROM}${RETURN_PATH}" =~ notifications@github.com|noreply@github.com ]]; then
  mailbox=DEV/github
elif [[ "${FROM}" =~ jgbsmart.com ]]; then
  mailbox=rent
elif [[ "${SUBJECT}" =~ 帳單|轉帳|對帳|付款|發票|消費|繳費|收據|費用|Invoice|Billing ]]; then
  mailbox=pay
elif [[ "${TO}" =~ dmarc@topo.tw ]]; then
  mailbox=DEV/dmarc
elif [[ "${LIST_ID}" =~ ^'Open Street Map Taiwan' ]]; then
  mailbox=FOSS/osm
elif [[ "${TO}" =~ talk-ja@openstreetmap.org ]]; then
  mailbox=LIST/talk-ja
elif [[ "${LIST_ID}" =~ ^~rjarry/aerc-discuss ]]; then
  mailbox=LIST/aerc
elif [[ "${LIST_ID}" =~ mutt-users.mutt.org ]]; then
  mailbox=LIST/mutt
elif [[
        "${SUBJECT}" =~  電子報|快訊|newsletter ||
        "${FROM}${TO}" =~ substack|service@kucw.io \
  ]]; then
  mailbox=news
elif [[ "${SUBJECT}" =~ 密碼|安全性警示|登入|存取|驗證|login|verify|sign-in ]]; then
  mailbox=login
elif [[ "${TO}" = cloudflare@topo.tw ]]; then
  mailbox=SRV/cloudflare
elif [[
        "${SUBJECT}" =~ 未讀|更新|核對表|嘟文|unread|summary|introduc  ||
        "${FROM}" =~ no-reply@hackmd.io \
  ]]; then
  mailbox=update
elif [[
        "${SUBJECT}${FROM}" =~ 優惠|快訊|願望清單|期待|eDM ||
        -n "${LIST_ID}${LIST_UNSUBSCRIBE}" ||
        ${TO} =~ tienling.chou@topo.tw \
  ]]; then
  mailbox=MISC/promote
fi
# }}}

# deliver mail to mailbox
set_stdout && print_mail

# log to stderr
echo -e ${date} ${mailbox:-INBOX} '\t' "${heading:-${SUBJECT}}" >&2

# vim:fdm=marker fdl=0
