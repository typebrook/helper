#! /bin/bash

# Save incoming mail as comment
# Usage:
#   echo '|<PATH_TO_THIS_SCRIPT> --output_dir=<PATH_OF_HTML_FILES>' >>~/.forward

# 1. Check mail is for comment {{{

# Restore mail into variable
MAIL="$(tr -d '\r')"
header="$(<<<"$MAIL" sed '/^$/ q')"
body="$(<<<"$MAIL" sed -n '/^$/,$ p' | sed '1d')"

# determine mail is for comment by pattern
pattern='^Subject: .*[cC]omment on page: (https?://)?([^/]+/)?([^ ]+)$'
<<<"$header" grep -E "$pattern" >/dev/null || exit 0

# }}}
# 2. Get necessary variables from arguments {{{

while [[ "$1" =~ ^-- && ! "$1" == "--" ]]; do
  case $1 in
    --output_dir ) shift; output_dir=$1 ;;
    --markdown_bin ) shift; markdown_bin=$1 ;;
    *) shift ;;
  esac
  shift
done

output_dir=${output_dir:?}
markdown_bin=${markdown_bin:-markdown}
[ -x $(which $markdown_bin) ] || markdown_bin=cat

# }}}
# 3. Read header fields {{{

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
# 4. Get path of output file {{{

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
# 5. Get comment from mail body {{{

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
# 6. Write comment to output file {{{

# add basic html layout for output file if necessary {{{
if [ ! -f $output ] || ! xmllint --html --nofixup-base-uris $output &>/dev/null; then
  <<-LAYOUT cat >$output
	<style>
	  .comment-body {
	    padding: 0.5rem;
	    width: fit-content;
	    border-radius: 8px;
	    background: lightblue;
	    p {
	      margin: 0.5rem;
	    }
	  }
	  .replies {
	    display: none;
	    cursor: pointer;
	    &:has(li) {
	      display: block;
	    }
	  }
	</style>
	<ul>
	</ul>
	LAYOUT
fi
# }}}
# get line of insert position by header field "In-Reply-To" {{{
if [ -n "${IN_REPLY_TO}" ]; then
  line=$(grep -n "^<!-- ${IN_REPLY_TO} -->$" $output | cut -d':' -f1)
fi
# }}}
# insert comment into output file {{{
<<-COMMENT sed -i "${line:-/<ul>/}r /dev/stdin" $output
	<li>

	<time datetime="${DATE}">${DATE}</time>
	<a href="mailto:${RECIPIENT}?subject=Comment on page: ${path}&in-reply-to=${MESSAGE_ID}">[reply]</a>

	<div class='comment-body'>
	$(<<<"${body}" ${markdown_bin})
	</div>

	<details class="replies" open="true">
	<summary>replies</summary>
	<ul>
	<!-- ${MESSAGE_ID} -->
	</ul>
    </details>

	</li>
COMMENT

# }}}

# }}}
