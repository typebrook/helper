#! /bin/sh

REMOTE=${REMOTE:-vps}
SRC="$1"
DEST="$2"
DEST="${DEST:-$1}"

# If fail to sync file, then
if rsync -au "${SRC}" ${REMOTE}:"${DEST}"; then
  rm "${SRC}".retry 2>/dev/null
  true
else
  echo ${DEST} >${SRC}.retry
fi
