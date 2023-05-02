#! /bin/bash

# Restore mail in variable
MAIL="$(cat)"

# Only execute the following script when mail receiver is log@topo.tw
grep -qE "^X-Original-To: .*context@topo.tw[>]?$" <<<"$MAIL" || exit 0
# A little hacky way to check if mail is sent from me
sed -nE '/^Received: /p;/^$/q' <<<"$(MAIL)" | wc -l | xargs -i test {} -lt 2 || exit 0

# Write a log
cat <<<"$MAIL"  >>~/Downloads/context.log

# Save content to log file of current week
/home/pham/helper/bin/task/context $(awk -v RS= 'NR>1' <<<"$MAIL")

/home/pham/helper/bin/task/context | cut -f1-3 | /usr/bin/mail -r context@topo.tw -C "chat-version: 1.0" -s no-reply pham

cd ~/log && git add context/* && git commit -m 'Append time by mail'
