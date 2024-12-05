#! /bin/bash

# Save incoming mail as comment
# Usage:
#   echo '|<PATH_TO_THIS_SCRIPT>' >>~/.forward

set -x
exec 2>>/dev/pts/1
env >&2

while [[ "$1" =~ ^-- && ! "$1" == "--" ]]; do
  case $1 in
    --mailto ) shift; mailto=$1 ;;
    --output_dir ) shift; output_dir=$1 ;;
  esac
  shift
done

mailto=${mailto:-`whoami`@${HOSTNAME:?HOSTNAME is not specified}}
[ -z "$mailto" ] && echo --mailto is not specified}
[ -z "$output_dir" ] && echo --output_dir is not specified}
markdown_bin=${markdown:-markdown}
[ -x $(which $markdown_bin) ] || markdown_bin=cat

# Check mail is for comment {{{

# Restore mail into variable
MAIL="$(tee /tmp/mail | tr -d '\r')"
header="$(<<<"$MAIL" sed '/^$/ q')"
body="$(<<<"$MAIL" sed -n '/^$/,$ p' | sed '1d')"

# determine mail is for comment by pattern
pattern='^Subject: .*comment on (https?://)?([^/]+/)?([^ ]+)$'
<<<"$header" grep -E "$pattern" >/dev/null || exit 0

# }}}
# Process header fields {{{

# enable execute last command in pipe under current shell
shopt -s lastpipe; set +m;

# save each field of header into variables
<<<"$header" grep '^[a-zA-Z]' \
| while read field value; do
  declare field=$(<<<$field tr [:lower:] [:upper:] | tr '-' '_' | tr -d ':')
  declare $field="${value}"
done
DATE=${DATE:+$(date --rfc-3339 seconds --date "$DATE")}

# }}}
# Get path of output file {{{

path=$(<<<"$header" sed -En "\\|${pattern}| {s//\\3/p; q}")

# sender want comment on some page, but find no path for this
if [ $path = "" ]; then
  echo 'Cannot get target of comment from mail' >&2
  exit 1
fi

# get output path
[[ "$path" =~ '/$' ]] && path+=index
path=${path#/}
path=${path/.html}
output=$output_dir/${path}.comment.html

# }}}
# Get comment from mail body {{{

# check mail includes multiple part
if [[ "$CONTENT_TYPE" =~ mixed ]]; then
  boundary="$(<<<"$CONTENT_TYPE" sed -En 's/^.*boundary="(.*)".*$/\1/p')"
  if [ $boundary = "" ]; then
    echo 'cannot get boundary from mail header' >&2
    exit 1
  fi

  # print content of first mail part
  boundaryPat="\\|^--${boundary}\$|"
  body="$(<<<"$body" sed -n "${boundaryPat},${boundaryPat} p" | sed -n "1,4d; ${boundaryPat} q; p")"
fi

# }}}
# Write comment to output file {{{

# add basic html layout for output file if necessary
if [ ! -f $output ] || ! xmllint --html --nofixup-base-uris $output &>/dev/null; then
  echo -e '<ul>\n</ul>' >$output
fi
# get line of insert position by header field "In-Reply-To"
if [ -n "${IN_REPLY_TO}" ]; then
  line=$(grep -n "^<!-- ${IN_REPLY_TO} -->$" $output | cut -d':' -f1)
fi

# insert comment into output file
<<-COMMENT sed -i "${line:-1}r /dev/stdin" $output
	<li>
	<time datetime="${DATE}">${DATE}</time>
	<a href="mailto:${mailto}?subject=comment on ${path}&in-reply-to=${MESSAGE_ID}">[reply]</a>

	$(<<<"${body}" ${markdown_bin})

	<ul>
	<!-- ${MESSAGE_ID} -->
	</ul>
	</li>
COMMENT

# }}}
