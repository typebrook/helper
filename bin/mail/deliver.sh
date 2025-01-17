#! /bin/bash

# Process each incoming mail
# TODO image/audio mail part

# message for logging delivery
log=$(grep -rlE 'From:\s+<?MDA' ~/Maildir/cur | head -1)
if [ -z $log ]; then
  log=~/Maildir/cur/deliver.log
  <<-HEADER cat >$log
	From: MDA
	Content-Type: text/plain; charset=UTF-8
	Subject: Delivery Log

	HEADER
fi

exec 2>>$log
shopt -s nocasematch extglob

# update index for dovecot
trap 'doveadm force-resync ${mailbox:-/}' EXIT

# temp file for decodemail (GNU Mailutils)
tmp_mailbox=$(mktemp -d); mkdir -p ${tmp_mailbox}/{tmp,new,cur}
cat >${tmp_mailbox}/cur/mail
trap 'rm -rf ${tmp_mailbox}' EXIT

# Restore mail into vars
MAIL="$(decodemail ${tmp_mailbox})"
# TODO process multi-line header field
header="$(<<<"$MAIL" sed '/^$/ q; /^[[:blank:]]/ d;')"
body="$(<<<"$MAIL" sed -n '/^$/,$ p' | sed '1d')"

# vars about output
date=$(date --iso=seconds)
maildir=${HOME}/Maildir
mailbox=

# Set set_stdout
set_stdout() {
  filename=${Subject// /_}
  path=${maildir}/${mailbox}${mailbox:+/}new/${date//:/}.${filename//[^[:alnum:]_]/}
  mkdir -p $(dirname $path)

  exec 1>$path
}

print_mail() {
  echo "$MAIL"
}

# save each field of header into vars
# TODO Use GNU MailUtils to save header
while read line; do
  [[ "${line}" =~ ^" "|^"	" ]] && ${field}+=" ${line##*( )}" && continue

  IFS=': ' read field value <<<"${line}"
  field="${field^^}"
  field="${field//-/_}"
  declare ${field}="${value}"
done <<<"$header"

# save to mailbox
if [[ "$SENDER" = pham@topo.tw && -n $CHAT_VERSION ]]; then
  heading="$(head -1 <<<"${body}")"

  if [[ "${heading}" =~ ^"." ]]; then
     mailbox=do
     heading=${heading#.}
  else
    mailbox=box
  fi

  print_mail() {
    <<-MAIL cat
		From: me
		Date: $(date --rfc-email)
		Message-ID: ${Message_ID}
		Self: true
		Subject: ${heading}

		$(sed 1d <<<"$body")
	MAIL
  }
elif [[ "${FROM}${RETURN_PATH}" =~ notifications@github.com|noreply@github.com ]]; then
  mailbox=DEV/github
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
elif [[ "${SUBJECT}" =~  電子報|快訊|newsletter ]]; then
  mailbox=news
elif [[ "${SUBJECT}" =~ login|verify|sign-in|密碼|安全性警示|登入|存取 ]]; then
  mailbox=login
elif [[ "${TO}" = cloudflare@topo.tw ]]; then
  mailbox=SRV/cloudflare
elif [[ "${SUBJECT}" =~ 未讀|快訊|更新|核對表|unread|summary|introduc ]]; then
  mailbox=update
elif [[ "${SUBJECT}${FROM}" =~ 願望清單|eDM ]]; then
  mailbox=MISC/promote
# This is for greenpeace
elif [[ ${TO} =~ tienling.chou@topo.tw ]]; then
  mailbox=update
fi

# deliver mail to mailbox
set_stdout && print_mail

# log to stderr
echo -e ${date} ${mailbox:-INBOX} '\t' "${heading:-${SUBJECT}}" >&2
