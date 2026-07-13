#! /bin/sh
# Append the incoming message to ~/mbox.
#
# De-duplicate by Message-ID: if a message with the same Message-ID has
# already been delivered, skip the append. This prevents sender
# retransmissions (e.g. DMARC aggregate reports that Google resends when
# it doesn't register a clean final ack) from piling up as duplicates.
#
# A lock serialises concurrent deliveries so parallel appends can't
# interleave and corrupt the mbox. Always exit 0 so delivery is
# acknowledged and the sender stops retrying.

mbox="$HOME/mbox"

tmp=$(mktemp "${TMPDIR:-/tmp}/mbox.XXXXXX") || exit 1
trap 'rm -f "$tmp"' EXIT

cat > "$tmp"

msgid=$(sed -n '/^$/q; s/^Message-[Ii][Dd]:[[:space:]]*//p' "$tmp" | head -n1 | tr -d '\r')

{
	flock 9

	if [ -n "$msgid" ] && grep -i '^message-id:' "$mbox" 2>/dev/null | grep -Fq -- "$msgid"; then
		exit 0
	fi

	{
		echo
		echo "From $SENDER $(date)"
		cat "$tmp"
	} >> "$mbox"
} 9>>"$mbox"

exit 0
