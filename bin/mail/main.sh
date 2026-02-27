#! /bin/bash

# temp file for decodemail (GNU Mailutils)
tmp_mailbox=$(mktemp -d); mkdir -p ${tmp_mailbox}/{tmp,new,cur}
cat >${tmp_mailbox}/cur/mail
trap 'rm -rf ${tmp_mailbox}' EXIT

HEADER="$(decodemail ${tmp_mailbox} | sed '/^$/q')"
<<<$HEADER grep -E '^To: .*info@topo.tw.*$' && MAILBOX=fraud
<<<$HEADER grep -E '^List-Unsubscribe' && MAILBOX=promote
<<<$HEADER grep -E '^List-I[dD]: ' && MAILBOX=zl

MAILBOX=${MAILBOX:+.$MAILBOX/}

decodemail ${tmp_mailbox} | \
tee >(~/helper/bin/mail/log.sh) \
>~/Mail/${MAILBOX}new/$(date --iso=seconds)
