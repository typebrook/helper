#!/usr/bin/env bash
# goimapnotify onNewMail hook for the "topo" account.
#
# goimapnotify doesn't pass the subject to hooks, so we fetch the mail, grab the
# newest message that landed in ~/Maildir/new, and read its Subject header.
mbsync topo-fetch

# Newest file just delivered to the maildir.
newest=$(find ~/Maildir/new -maxdepth 1 -type f -printf '%T@ %p\n' 2>/dev/null \
         | sort -nr | head -1 | cut -d' ' -f2-)
[ -n "$newest" ] || exit 0

subject=$(grep -m1 -i '^Subject:' "$newest" | sed 's/^[Ss]ubject:[[:space:]]*//' \
          | perl -CS -MEncode -pe '$_=Encode::decode("MIME-Header",$_)')
notify-send "New Mail" "${subject:-(no subject)}"
