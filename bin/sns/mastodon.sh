#! /bin/bash

# Restore mail in variable
MAIL="$(cat)"

# Only execute the following script when mail receiver is mastodon@topo.tw
grep -qE "^X-Original-To: .*mastodon@topo.tw[>]?$" <<<"$MAIL" || exit 0
# A little hacky way to check if mail is sent from me
sed -nE '/^Received: /p;/^$/q' <<<"$(MAIL)" | wc -l | xargs -i test {} -lt 2 || exit 0

# Leave log
date >>~/Downloads/mastodon.log
echo $$ >>~/Downloads/mastodon.log
awk -v RS= 'NR>1' <<<"$MAIL"  >>~/Downloads/mastodon.log

# Use toot to send message on g0v.social
awk -v RS= 'NR>1' <<<"$MAIL" | toot post >>/tmp/mastodon.log
