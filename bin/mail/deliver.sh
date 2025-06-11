#! /bin/bash

# Deliver incoming mail to proper mailbox
# TODO image/audio mail part
# TODO CJK Subject in index/pager mode: tofo or backslash

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
iso_date=$(date --iso=seconds -d @${epoch})
maildir=${HOME}/Maildir
mailbox=
# }}}
# FUNCTION: Set set_stdout {{{
set_stdout() {
  filename=${Subject// /_}
  path=${maildir}/${mailbox}${mailbox:+/}new/${iso_date//:/}.${filename//[^[:alnum:]_]/}
  mkdir -p $(dirname $path)

  exec 1>$path
}
# }}}
# FUNCTION: print mail {{{
print_mail() {
  if [ "$private" = true ]; then
    <<-MAIL cat
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
elif [[ "${FROM}" =~ riverbien ]]; then
  mailbox=river
elif [[ "${FROM}" =~ MAILER-DAEMON|accounts ]]; then
  mailbox=
elif [[ "${FROM}" =~ taiwandreamer|imtaiwanese18741130|recall ]]; then
  mailbox=recall
elif [[ "${TO}" =~ '+'|'=' ]]; then
  mailbox=${TO#*[+=]}       # remove chars before symbol of mailbox
  mailbox=${mailbox%@*}     # remove suffix for mail address
elif [[ "${FROM}${RETURN_PATH}" =~ notifications@github.com|noreply@github.com ]]; then
  mailbox=zd/github
elif [[ "${FROM}" =~ jgbsmart.com ]]; then
  mailbox=rent
elif [[ "${SUBJECT}" =~ 帳單|轉帳|對帳|付款|發票|消費|繳費|收據|費用|簽帳|Invoice|Billing ]]; then
  mailbox=pay
elif [[ "${TO}" =~ dmarc@topo.tw ]]; then
  mailbox=zd/dmarc
elif [[ "${LIST_ID}" =~ ^'Open Street Map Taiwan' ]]; then
  mailbox=FOSS/osm
elif [[ "${TO}" =~ talk-ja@openstreetmap.org ]]; then
  mailbox=zl/talk-ja
elif [[ "${LIST_ID}" =~ rjarry/aerc-discuss ]]; then
  mailbox=zl/aerc
elif [[ "${LIST_ID}" =~ mutt-users.mutt.org ]]; then
  mailbox=zl/mutt
elif [[ "${LIST_ID}" =~ archlinux.org ]]; then
  mailbox=zl/arch
elif [[ "${SUBJECT}" =~ 啟用 ]]; then
  mailbox=service
elif [[
  "${SUBJECT}" =~  電子報|快訊|newsletter ||
  "${FROM}${TO}" =~ substack|service@kucw.io
  ]]; then
  mailbox=news
elif [[ "${SUBJECT}" =~ 密碼|安全性警示|登入|存取|驗證|確認|login|verif|sign-in ]]; then
  mailbox=login
elif [[ "${TO}" = cloudflare@topo.tw ]]; then
  mailbox=SRV/cloudflare
elif [[
  "${SUBJECT}" =~ 通知|提及|未讀|更新|核對|嘟文|unread|summary|mention|introduc  ||
  "${FROM}" =~ iservice@narlabs.org.tw ||
  "${FROM}" =~ notification[s]?@|no-reply@hackmd.io
  ]]; then
  mailbox=update
elif [[
  "${SUBJECT}${FROM}" =~ 優惠|快訊|願望清單|期待|活動|eDM|invitation ||
  ${FROM} =~ cora.computer|noreply@steampowered.com ||
  -n "${LIST_ID}${LIST_UNSUBSCRIBE}${FEEDBACK_ID}${THREAD_INDEX}${X_MAILGUN_TAG}${X_SFMC_STACK}"
  ]]; then
  mailbox=promote
fi
# }}}

# deliver mail to mailbox
set_stdout && print_mail

# log to stderr
declare -i width_mailbox=$(wc -c <<<"${mailbox:-INBOX}")
spaces="$(printf %$(( 16 - ${width_mailbox} ))s)"
echo -e $(date '+%m/%d %H:%M' -d @${epoch}) "=> ${mailbox:-INBOX}" "$spaces" "${heading:-${SUBJECT}}" >&2

# vim:fdm=marker fdl=0
