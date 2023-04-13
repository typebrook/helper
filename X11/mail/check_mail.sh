#! /bin/bash

IMAP_SERVER=$1
LOG_INFO=$2

NUMBER=$(
  curl -s -u $LOG_INFO $IMAP_SERVER -X 'STATUS INBOX (UNSEEN)' | \
  sed -E 's/^.+\(UNSEEN ([0-9]+)\).+$/\1/' | \
  tr -d '\r'
)

if [[ -n "$NUMBER" && $NUMBER -gt 0 ]]; then
  DISPLAY=:0 \
  DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/`id -u`/bus \
  notify-send "New Mail: $NUMBER" --expire-time=20000
else
  date
fi
