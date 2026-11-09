#! /bin/sh
# Deliver the incoming message to ~/Maildir/INBOX (Dovecot's INBOX).
#
# De-duplicate by Message-ID: if a message with the same Message-ID is
# already in INBOX, drop it. This prevents sender retransmissions (e.g.
# DMARC aggregate reports that Google resends when it doesn't register a
# clean final ack) from piling up as duplicates.
#
# The message is written to tmp/ and renamed into new/, as Maildir
# requires. A lock serialises the dedup check against concurrent
# deliveries. Always exit 0 so delivery is acknowledged and the sender
# stops retrying.

box="$HOME/Maildir/INBOX"
mkdir -p "$box/tmp" "$box/new" "$box/cur" || exit 1

# unique name without ':' (reserved for the ':2,<flags>' info suffix)
name="$(date +%s).M$(date +%6N)P$$.$(hostname)"
tmp="$box/tmp/$name"
trap 'rm -f "$tmp"' EXIT

cat > "$tmp"

msgid=$(sed -n '/^$/q; s/^Message-[Ii][Dd]:[[:space:]]*//p' "$tmp" | head -n1 | tr -d '\r')

{
	flock 9

	if [ -n "$msgid" ] && grep -hi '^message-id:' "$box"/new/* "$box"/cur/* 2>/dev/null | grep -Fq -- "$msgid"; then
		exit 0
	fi

	mv "$tmp" "$box/new/$name"
} 9>>"$box/.deliver.lock"

exit 0
