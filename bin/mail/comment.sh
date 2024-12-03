#! /bin/bash

output_dir=${output_dir:-/srv/http}

# Restore mail into variable
MAIL="$(tr -d '\r')"
headers="$(<<<"$MAIL" sed '/^$/ q')"
contents="$(<<<"$MAIL" sed -n '/^$/,$ p' | sed '1d')"

# enable execute last command in pipe under current shell
shopt -s lastpipe; set +m;

# get route (target page of comment) and id
<<<"$MAIL" sed -En '/^To: comment+/ {s/^To: comment\+([^+]+)\+?(.*)@.*$/\1 \2/p; q}; /^$/q' \
| read route id

# sender want comment on some page, but find no route for this
if [ $route = "" ]; then
  echo 'rcpt "comment+<ROUTE>" not matched' >&2
  exit 1
fi

output=$output_dir/${route#/}.comment
exec 1>>$output

# check mail includes multiple part
<<<"$headers" grep '^Content-Type:.*mixed' >/dev/null
if [ $? -eq 0 ]; then
  boundary="$(<<<"$headers" sed -En 's/^Content-Type:.*boundary="(.*)".*$/\1/p')"
  if [ $boundary = "" ]; then
    echo 'cannot get boundary from mail header' >&2
    exit 1
  fi

  # print content of first mail part
  pattern="\\@^--${boundary}\$@"
  <<<"$contents" sed -n "${pattern},${pattern} p" | sed -n "1,4d; ${pattern} q; p"
else
  # print content
  <<<"$contents" sed '/^$/,$ p'
fi
