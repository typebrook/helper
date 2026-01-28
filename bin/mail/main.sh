#! /bin/bash

# temp file for decodemail (GNU Mailutils)
tmp_mailbox=$(mktemp -d); mkdir -p ${tmp_mailbox}/{tmp,new,cur}
cat >${tmp_mailbox}/cur/mail
trap 'rm -rf ${tmp_mailbox}' EXIT

decodemail ${tmp_mailbox} | \
sed '/^$/q' | \
grep -E '^To: .*info@topo.tw.*$' && \
SPAM=fraud/

decodemail ${tmp_mailbox} | \
tee >(~/helper/bin/mail/log.sh) \
>~/Mail/${SPAM}new/$(date +%s)
