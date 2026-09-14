#!/usr/bin/env bash
# Fetch INBOX and raise a desktop notification for each mail that just arrived.
#
# Two callers share this script so a message is only ever announced once:
#   - goimapnotify's onNewMail hook, fired by IMAP IDLE (see goimapnotify.yaml)
#   - mail-notify.timer / the cron entry, every 10 minutes, as a safety net for
#     IDLE events that were missed while the machine was asleep or offline
#
# goimapnotify doesn't pass the subject to hooks, so the subject is read off the
# message files mbsync just wrote into ~/Maildir/new.

set -uo pipefail

# cron hands us almost no environment, and both notify-send (session bus) and
# pass/gpg-agent (agent socket) need these. Harmless when already set.
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"

MAILDIR="$HOME/Maildir/new"
# Hardcoded, not $XDG_STATE_HOME: profile sets that for interactive shells only,
# so honouring it would give the timer and a hand-run a state file each and
# announce every message twice.
STATE_DIR="$HOME/.local/state/mail-notify"
STATE="$STATE_DIR/announced"
MAX_NOTIFY=5

mkdir -p "$STATE_DIR"

# Both callers can fire at once; serialise them so they don't race on the state
# file and double-announce the same message.
exec 9>"$STATE_DIR/lock"
flock 9 || exit 0

# A fetch failure (offline, laptop lid just opened) is not fatal: whatever is
# already on disk still gets announced, and the next run retries.
mbsync topo-fetch >/dev/null 2>&1

# Pull the Subject header out of an RFC 5322 message, joining folded
# continuation lines, then decode any MIME encoded-words.
subject_of() {
  awk '
    /^\r?$/                 { exit }
    tolower($0) ~ /^subject:/ {
      sub(/^[Ss][Uu][Bb][Jj][Ee][Cc][Tt]:[ \t]*/, ""); s = $0; f = 1; next
    }
    f && /^[ \t]/           { sub(/^[ \t]+/, " "); s = s $0; next }
    f                       { exit }
    END                     { sub(/\r$/, "", s); print s }
  ' "$1" | perl -CS -MEncode -pe '$_ = Encode::decode("MIME-Header", $_)'
}

# Current contents of new/. Messages leave when they are read, which prunes the
# state file on its own.
current=$(find "$MAILDIR" -maxdepth 1 -type f -printf '%f\n' 2>/dev/null | sort)

# First ever run: adopt whatever is sitting in new/ without announcing a backlog.
if [ ! -f "$STATE" ]; then
  printf '%s\n' "$current" >"$STATE"
  exit 0
fi

arrived=$(comm -13 "$STATE" <(printf '%s\n' "$current"))
printf '%s\n' "$current" >"$STATE"

[ -n "$arrived" ] || exit 0

count=0
while IFS= read -r name; do
  [ -n "$name" ] || continue
  count=$((count + 1))
  [ "$count" -le "$MAX_NOTIFY" ] || continue
  subject=$(subject_of "$MAILDIR/$name")
  notify-send --app-name=mail --icon=mail-unread "New Mail" "${subject:-(no subject)}"
done <<<"$arrived"

if [ "$count" -gt "$MAX_NOTIFY" ]; then
  notify-send --app-name=mail --icon=mail-unread \
    "New Mail" "…and $((count - MAX_NOTIFY)) more"
fi
