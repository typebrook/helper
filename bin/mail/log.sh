#! /bin/bash

# Get time of receiving mail
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
# vars about message {{{
MAIL="$(decodemail ${tmp_mailbox})"

# Only execute the following script when mail receiver is log@topo.tw
grep -qE "^Delivered-To: log@topo.tw$" <<<"$MAIL" && \
grep -qE "^Subject: Message from Pham$" <<<"$MAIL" || \
exit 0

<<<"$MAIL" sed -n '/^$/,$ p' | sed -n 2p >>~/LOG
# }}}

#declare -i width_mailbox=$(wc -c <<<"${mailbox:-INBOX}")
#spaces="$(printf %$(( 16 - ${width_mailbox} ))s)"
#echo -e $(date '+%m/%d %H:%M' -d @${epoch}) "=> ${mailbox:-INBOX}" "$spaces" "${heading:-${SUBJECT}}" >&2

# vim:fdm=marker fdl=0
