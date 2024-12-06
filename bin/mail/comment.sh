#! /bin/bash

# Save incoming mail as comment
# Usage:
#   Step1. Add script into forward(5) for MDA
#          Some MDA won't accept arguments for command. If --output_dir is not specified,
#          directory of this script would be used instead
#
#     echo '|<PATH_TO_THIS_SCRIPT> --output_dir <PATH_OF_HTML_FILES>' >>~/.forward
#
#   Step2. Insert related html file into target page, the following example use <object> element
#          * Please replace <PATH> for your target page, relative to value of --output_dir
#          * Set <RECIPIENT> for mail address which can achive MDA
#          * Change <PATH> in data attribute of <object> based on routing if necessary
#
#     <!-- START OF COMMENT BLOCK -->
#     <div style="border-radius: 6px; background: lightyellow">
#       <a style="display: inline-block; margin: 0.5em 0.5em 0 0; float: right" href="mailto:<RECIPIENT>?subject=Comment on page: <PATH>">[Comment on this page]</a>
#       <object type="text/html" data="<PATH>.comment.html" onload="observeResize(this)" style="width: 100%;"></object>
#       <script>
#         function observeResize(commentBlock) {
#           new ResizeObserver((entries) => {
#             commentBlock.style.height = entries[0].target.clientHeight + 'px';
#           }).observe(commentBlock.contentDocument.documentElement);
#         }
#       </script>
#     </div>
#     <!-- END OF COMMENT BLOCK -->

# 1. Check mail is for comment {{{

# Restore mail into variables
MAIL="$(tr -d '\r')"
# join multi-line field value into one line
header="$(<<<"$MAIL" sed '/^$/ q; :a; N; s/\n\s\+//; ta')"
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

export PATH=/bin:/usr/bin:/usr/local/bin:~/.local/bin
output_dir=${output_dir:-$(dirname $0)}
markdown_bin=${markdown_bin:-$(which markdown 2>/dev/null)}
[ -x "$markdown_bin" ] || markdown_bin=cat

# }}}
# 3. Read header fields {{{

# enable execute last command in pipe under current shell
shopt -s lastpipe; set +m;

# save each field of header into variables
echo "$header" | \
while read field value; do
  echo "$field" "$value" >>/tmp/header
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
[[ "$path" =~ /$ ]] && path+=index
path=${path#/}
path=${path/.html}
output=$output_dir/${path}.comment.html
umask 022; mkdir -p $(dirname $output)

# }}}
# 5. Get comment from mail body {{{

# check mail includes multiple part
boundary="$(<<<"$CONTENT_TYPE" sed -En 's/^.*boundary="?([^"]+)"?.*$/\1/p')"
if [ -n "${boundary}" ]; then
  # print content of first mail part
  boundaryPat="\\|^--${boundary}\$|"
  body="$(<<<"$body" sed -n "${boundaryPat},${boundaryPat} p" | sed -n "1,4d; ${boundaryPat} q; p")"
fi

# }}}
# 6. Write comment to output file {{{

umask 133
# add basic html layout for output file if necessary {{{
if [ ! -f $output ] || ! xmllint --html --nofixup-base-uris $output &>/dev/null; then
  <<-LAYOUT cat >$output
	<style>
	   ul {
	     padding-inline: 1rem;
	     li {
	       margin-block: 1rem;
	     }
	   }
	  .comment-body {
	    margin-top: 0.5rem;
	    padding: 0.5rem;
	    overflow-x: scroll;
	    border-radius: 4px;
	    background: lightblue;
	    p {
	      margin: 0.5rem;
	    }
	  }
	  .replies {
	    display: none;
	    &:has(li) {
	      display: block;
	    }
	    summary {
	      cursor: pointer;
	    }
	    ul {
	      padding-inline: 1rem 0;
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

# FIXME prevent pattern <!-- ${MESSAGE_ID} --> shown in <pre> block
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

# vim:fdm=marker fdl=0
