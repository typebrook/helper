#! /bin/bash

# debug {{{
set -x
export PS4='+${LINENO} ^$?> '
exec &>/tmp/mail.log
env
# }}}
# make temp file for decodemail (GNU Mailutils) {{{
tmp_mailbox=$(mktemp -d); mkdir -p ${tmp_mailbox}/{tmp,new,cur}
cat >${tmp_mailbox}/cur/mail
#trap 'rm -rf ${tmp_mailbox}' EXIT
# }}}
# decide mailbox to deliver {{{
HEADER=$(decodemail ${tmp_mailbox} | sed '/^$/q')
SUBJECT=$(<<<"$HEADER" sed -n '/^Subject:/{s/^Subject: //;p}')
echo SUBJECT=$SUBJECT
[ "$RECIPIENT" = 'info@topo.tw' ] && MAILBOX=fraud
<<<$HEADER grep -E '^List-Unsubscribe' && MAILBOX=promote
<<<$HEADER grep -E '^List-I[dD]: ' && MAILBOX=zl
MAILBOX=${MAILBOX:+.$MAILBOX/}
#}}}
# functions {{{
function log_or_not {
  [ "$RECIPIENT" = 'log@topo.tw' ] || return 0
  echo -e "$HEADER" | grep -o '^Chat-Version: ' || return 0
  export replyto=$(<<<"$HEADER" awk '/^In-Reply-To/{print $2}' )

  sed -n '/^$/,$ p' | sed -n 2p | $(dirname $0)/log.sh
}
# }}}
# deliver mail to maildir {{{
mail_name=~/Mail/${MAILBOX}new/$(date --iso=seconds)-$(<<<$SUBJECT tr '[:upper:]' '[:lower:]' | tr ' ' _ | cut -b -30)
echo mail_name $mail_name

decodemail ${tmp_mailbox} | \
tee >(log_or_not) | \
cat >$mail_name
# }}}

# vim:fdm=marker fdl=0
