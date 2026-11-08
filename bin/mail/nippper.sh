#! /bin/bash

# Deliver new articles of nippper.com into Maildir, one HTML message per article.
# Images are embedded as multipart/related parts referenced by cid:.
#
# Usage: nippper.sh [-a] [-r [ID...]]
#   -a  deliver every item in feed, not only items of last 24h on first run
#   -r  resend items already delivered (all items in feed, or only given IDs),
#       replacing earlier copies in MAILDIR_TARGET
# Env:
#   MAILDIR_TARGET  target maildir (default: ~/Maildir/INBOX)
#   IMG_MAX         max width/height of images in px (default: 1000)
# State:
#   $XDG_STATE_HOME/nippper/seen  delivered item IDs, one per line.
#   Remove a line to deliver that item again; remove the file to start over.
#
# Cron: 0 8 * * * ~/helper/bin/mail/nippper.sh 2>&1 | logger -t nippper

set -euo pipefail

FEED=https://nippper.com/feed/
MAILDIR_TARGET=${MAILDIR_TARGET:-$HOME/Maildir/INBOX}
STATE_DIR=${XDG_STATE_HOME:-$HOME/.local/state}/nippper
SEEN=$STATE_DIR/seen
IMG_MAX=${IMG_MAX:-1000}
UA='Mozilla/5.0 (X11; Linux x86_64) nippper-maildir'
ALL= RESEND=
while getopts ar opt; do
  case $opt in
    a) ALL=1 ;;
    r) RESEND=1 ;;
    *) sed -n '6,9 s/^# \{0,1\}//p' "$0" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
ONLY=" $* "  # IDs to resend, empty for all

mkdir -p "$STATE_DIR"
first_run=; [ -f "$SEEN" ] || { first_run=1; touch "$SEEN"; }
work=$(mktemp -d); trap 'rm -rf "$work"' EXIT

fetch() { curl -fsSL -m 60 -A "$UA" "$@"; }

# Downscale image in place to fit IMG_MAX px, keep it only if smaller.
# Skip GIF (may be animated) and SVG.
shrink() {
  local f=$1 tmp
  command -v magick >/dev/null || return 0
  case "$f" in *.gif|*.svg) return 0 ;; esac
  tmp=${f%.*}.small.${f##*.}
  magick "$f" -auto-orient -resize "${IMG_MAX}x${IMG_MAX}>" -strip -quality 80 "$tmp" 2>/dev/null \
    && [ $(stat -c %s "$tmp") -lt $(stat -c %s "$f") ] && mv "$tmp" "$f"
  rm -f "$tmp"
}

# parse feed into TSV: id link title date creator {{{
fetch "$FEED" >"$work/feed.xml"
python3 -I - "$work/feed.xml" >"$work/items.tsv" <<'PY'
import sys, re, xml.etree.ElementTree as ET
dc = '{http://purl.org/dc/elements/1.1/}'
for item in ET.parse(sys.argv[1]).getroot().iter('item'):
    get = lambda tag: ' '.join((item.findtext(tag) or '').split())
    guid = get('guid')
    m = re.search(r'[?&]p=(\d+)', guid) or re.search(r'/(\d+)/?$', get('link'))
    pid = m.group(1) if m else guid
    print('\t'.join([pid, get('link'), get('title'), get('pubDate'), get(dc + 'creator')]))
PY
# }}}
# extract article content, rewrite <img> to cid: {{{
extract() { # $1=page.html $2=link $3=title $4=creator $5=outdir
python3 -I - "$@" <<'PY'
import sys, os, html
from html.parser import HTMLParser
from urllib.parse import urljoin, urlparse

page, link, title, creator, out = sys.argv[1:6]
DROP_CLASS = ('sd-sharing', 'robots-nocontent', 'pochipp-box', 'sharedaddy', 'jp-relatedposts')
DROP_TAG = {'script', 'style', 'iframe', 'noscript', 'form', 'button', 'svg'}
VOID = {'img', 'br', 'hr', 'meta', 'link', 'input', 'source', 'wbr', 'area', 'col', 'embed'}
MIME = {'.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.png': 'image/png',
        '.gif': 'image/gif', '.webp': 'image/webp', '.svg': 'image/svg+xml'}
images = []  # (url, name, mime)

def img_tag(attrs):
    a = dict(attrs)
    src = a.get('data-src') or a.get('src')
    if not src or src.startswith('data:'):
        return ''
    url = urljoin(link, src)
    if any(u == url for u, _, _ in images):
        return ''
    ext = os.path.splitext(urlparse(url).path)[1].lower()
    ext = ext if ext in MIME else '.jpg'
    name = 'img-%d%s' % (len(images) + 1, ext)
    images.append((url, name, MIME[ext]))
    alt = html.escape(a.get('alt') or '', quote=True)
    return '<img src="cid:%s@nippper" data-url="%s" alt="%s">' % (
        name, html.escape(url, quote=True), alt)

class P(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=False)
        self.out, self.hero = [], ''
        self.depth = 0      # depth inside div.article_content, 0 = outside
        self.skip = 0       # depth inside dropped element

    def handle_starttag(self, tag, attrs):
        cls = dict(attrs).get('class') or ''
        if not self.depth:
            if tag == 'div' and 'article_content' in cls.split():
                self.depth = 1
            elif tag == 'img' and 'wp-post-image' in cls and not self.hero:
                self.hero = img_tag(attrs)
            return
        if tag not in VOID:
            self.depth += 1
        if self.skip:
            if tag not in VOID: self.skip += 1
            return
        if tag in DROP_TAG or any(c in cls for c in DROP_CLASS):
            if tag not in VOID: self.skip = 1
            return
        if tag == 'img':
            self.out.append(img_tag(attrs)); return
        keep = [(k, v) for k, v in attrs if k in ('href', 'colspan', 'rowspan')]
        if tag == 'a' and dict(keep).get('href'):
            keep = [('href', urljoin(link, dict(keep)['href']))]
        self.out.append('<%s%s>' % (tag, ''.join(
            ' %s="%s"' % (k, html.escape(v or '', quote=True)) for k, v in keep)))

    def handle_startendtag(self, tag, attrs):
        self.handle_starttag(tag, attrs)

    def handle_endtag(self, tag):
        if not self.depth or tag in VOID:
            return
        self.depth -= 1
        if self.skip:
            self.skip -= 1; return
        if self.depth: self.out.append('</%s>' % tag)

    def handle_data(self, d):
        if self.depth and not self.skip: self.out.append(d)
    def handle_entityref(self, n):
        if self.depth and not self.skip: self.out.append('&%s;' % n)
    def handle_charref(self, n):
        if self.depth and not self.skip: self.out.append('&#%s;' % n)

p = P()
with open(page, encoding='utf-8', errors='replace') as f:
    p.feed(f.read())
body = ''.join(p.out)
if not body.strip():
    sys.exit('no article_content in ' + link)

t = html.escape(title)
doc = f'''<!DOCTYPE html>
<html lang="ja"><head><meta charset="utf-8"><title>{t}</title>
<style>body{{max-width:46em;margin:auto;padding:0 1em;line-height:1.7;font-family:sans-serif}}
img{{max-width:100%;height:auto}}</style></head>
<body>
<h1><a href="{html.escape(link, quote=True)}">{t}</a></h1>
<p><small>{html.escape(creator)} · <a href="{html.escape(link, quote=True)}">nippper.com</a></small></p>
{p.hero}
{body}
</body></html>
'''
with open(os.path.join(out, 'body.html'), 'w', encoding='utf-8') as f:
    f.write(doc)
with open(os.path.join(out, 'images.tsv'), 'w') as f:
    for row in images:
        f.write('\t'.join(row) + '\n')
PY
}
# }}}
# build and deliver one message {{{
deliver() { # id link title date creator
  local id=$1 link=$2 title=$3 date=$4 creator=$5
  local dir=$work/$id; mkdir -p "$dir"
  fetch "$link" >"$dir/page.html" || return 1
  extract "$dir/page.html" "$link" "$title" "$creator" "$dir" || return 1

  # download images; on failure fall back to remote URL in HTML
  local url name mime parts=()
  while IFS=$'\t' read -r url name mime; do
    if fetch -e "$link" -o "$dir/$name" "$url"; then
      shrink "$dir/$name"
      parts+=("#$mime#inline $dir/$name>$name")
    else
      echo "image failed: $url" >&2
      sed -i "s#src=\"cid:$name@nippper\"#src=\"$url\"#" "$dir/body.html"
    fi
  done <"$dir/images.tsv"

  {
    printf 'From: nippper <rss@nippper.com>\n'
    printf 'To: %s\n' "${USER}@localhost"
    printf 'Subject: %s\n' "$title"
    printf 'Date: %s\n' "$(date -R -d "$date" 2>/dev/null || date -R)"
    printf 'Message-ID: <nippper-%s@nippper.com>\n' "$id"
    printf 'List-Id: nippper <nippper.com>\n'
    printf 'X-Original-URL: %s\n\n' "$link"
    printf '#text/html;charset=utf-8#inline %s>index.html\n' "$dir/body.html"
    [ ${#parts[@]} -eq 0 ] || printf '%s\n' "${parts[@]}"
  } | mmime -t 'multipart/related; type="text/html"' \
    | sed -E '/^Content-Disposition: inline; filename="?index\.html"?$/d' \
    | sed -E '/^Content-Disposition: inline; filename="?(img-[0-9]+\.[a-z]+)"?$/{p;s//Content-ID: <\1@nippper>/}' \
    | mdeliver "$MAILDIR_TARGET" >/dev/null || return 1
  echo "delivered: $id $title"
}
# }}}

# files in MAILDIR_TARGET delivered earlier for item $1
old_copies() {
  grep -rlxF "Message-ID: <nippper-$1@nippper.com>" \
    "$MAILDIR_TARGET/cur" "$MAILDIR_TARGET/new" 2>/dev/null || true
}

now=$(date +%s)
while IFS=$'\t' read -r id link title date creator; do
  [ "$ONLY" = '  ' ] || [[ $ONLY == *" $id "* ]] || continue
  old=()
  if grep -qxF "$id" "$SEEN"; then
    [ -n "$RESEND" ] || continue
    mapfile -t old < <(old_copies "$id")
  # on first run, only deliver recent items, mark older ones as seen
  elif [ -n "$first_run" ] && [ -z "$ALL" ] && [ -z "$RESEND" ] \
     && [ $(( now - $(date +%s -d "$date") )) -gt 86400 ]; then
    echo "$id" >>"$SEEN"; continue
  fi
  if deliver "$id" "$link" "$title" "$date" "$creator"; then
    [ ${#old[@]} -eq 0 ] || rm -f -- "${old[@]}"
    grep -qxF "$id" "$SEEN" || echo "$id" >>"$SEEN"
  else
    echo "failed: $id $link" >&2
  fi
  sleep 1
done <"$work/items.tsv"

# vim:fdm=marker fdl=0
