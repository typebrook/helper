#! /bin/bash

MAIL="$(cat)"

# Only execute the following script when mail receiver is mastodon@topo.tw
grep -qE "^To: .*mastodon@topo.tw[>]?$" <<<"$MAIL" || exit 0

date >>~/Downloads/mastodon.log
echo $$ >>~/Downloads/mastodon.log
awk -v RS= 'NR>1' <<<"$MAIL"  >>~/Downloads/mastodon.log

#awk -v RS= 'NR>1' <<<"$MAIL" | toot post >/tmp/mastodon.log
