#! /bin/bash

# Deliver new articles of nippper.com into Maildir, one HTML message per article.
# Images are embedded as multipart/related parts referenced by cid:.
#
# Usage: nippper.sh [-a] [-r [ID...]]
#   -a  deliver every item in feed, not only items of last 24h on first run
#   -r  resend items already delivered (all items in feed, or only given IDs),
#       replacing earlier copies in MAILDIR_TARGET
# Env:
#   SMTP_SERVER     server for smtp(1) (default: smtp+notls://localhost:2525)
#   MAIL_FROM       sender address (default: rss@nippper.com)
#   MAIL_TO         recipient address (default: $USER@localhost)
#   MAILDIR_TARGET  maildir where SMTP_SERVER delivers MAIL_TO, used by -r to
#                   remove earlier copies (default: ~/Maildir/INBOX)
#   IMG_MAX         max width/height of images in px (default: 1000)
# State:
#   $XDG_STATE_HOME/nippper/seen  delivered item IDs, one per line.
#   Remove a line to deliver that item again; remove the file to start over.
#
# Cron: 0 8 * * * ~/helper/bin/mail/nippper.sh 2>&1 | logger -t nippper

set -euo pipefail

FEED=https://nippper.com/feed/
SMTP_SERVER=${SMTP_SERVER:-smtp+notls://localhost:2525}
MAIL_FROM=${MAIL_FROM:-rss@nippper.com}
MAIL_TO=${MAIL_TO:-$USER@localhost}
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
extract() { # $1=page.html $2=link $3=title $4=creator $5=outdir $6=date
python3 -I - "$@" <<'PY'
import sys, os, html, email.utils
from html.parser import HTMLParser
from urllib.parse import urljoin, urlparse

page, link, title, creator, out, date = sys.argv[1:7]
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
u = html.escape(link, quote=True)
try:
    d = email.utils.parsedate_to_datetime(date)
    date = f'{d.year}/{d.month}/{d.day}'
except (TypeError, ValueError):
    pass
# Mimic nippper.com theme (css/nippper.webflow.css, mobile layout)
doc = f'''<!DOCTYPE html>
<html lang="ja"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>{t}</title>
<style>
body{{margin:0;padding:0 .5rem;color:#333;background:#f4f4f4;
  font-family:Arial,"Helvetica Neue",Helvetica,sans-serif;font-size:14px;line-height:20px}}
main{{max-width:800px;margin:auto}}
a{{color:#000;text-decoration:none}}
img{{max-width:100%;height:auto}}
h1{{font-size:20px;line-height:30px;margin:0 0 10px}}
h1 img{{display:block;margin:0 auto 20px}}
h1 span{{background-image:repeating-linear-gradient(-45deg,#ff6 0,#ff6 4px,transparent 4px,transparent 8px);
  background-position:center bottom;background-repeat:repeat-x;background-size:auto .75em}}
.info{{display:flex;justify-content:space-between;margin:0 0 20px;font-size:14px;color:#696969}}
.content{{font-size:16px;line-height:2em}}
.content a{{color:#c00}}
.content p{{margin:0 0 30px}}
.content h2,.content h3{{font-size:22px;line-height:1.5em;margin:20px 0 16px}}
.content figure{{margin:20px 0;text-align:center}}
.content figcaption{{font-size:.8em;color:#474747;line-height:1.5em}}
.content blockquote{{margin:0 0 30px;padding:0 1em;border-left:4px solid #ccc;color:#555}}
</style></head>
<body><main>
<h1>{p.hero}<a href="{u}"><span>{t}</span></a></h1>
<div class="info"><span>投稿者／{html.escape(creator)}</span><span>{html.escape(date)}</span></div>
<div class="content">
{body}
</div>
<p class="info"><a href="{u}">nippper.com で読む</a></p>
</main></body></html>
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
  extract "$dir/page.html" "$link" "$title" "$creator" "$dir" "$date" || return 1

  # download images; on failure fall back to remote URL in HTML
  local url name mime
  : >"$dir/parts.tsv"
  while IFS=$'\t' read -r url name mime; do
    if fetch -e "$link" -o "$dir/$name" "$url"; then
      shrink "$dir/$name"
      printf '%s\t%s\n' "$name" "$mime" >>"$dir/parts.tsv"
    else
      echo "image failed: $url" >&2
      sed -i "s#src=\"cid:$name@nippper\"#src=\"$url\"#" "$dir/body.html"
    fi
  done <"$dir/images.tsv"

  compose "$dir" "$id" "$link" "$title" "$date" \
    | smtp -s "$SMTP_SERVER" -F "$MAIL_FROM" "$MAIL_TO" || return 1
  echo "delivered: $id $title"
}

# print message: multipart/related with HTML body and cid: images
compose() { # $1=dir $2=id $3=link $4=title $5=date
python3 -I - "$@" "$MAIL_FROM" "$MAIL_TO" <<'PY'
import sys, os, email.utils
from email.message import EmailMessage

dir, pid, link, title, date, mfrom, mto = sys.argv[1:8]
try:
    date = email.utils.format_datetime(email.utils.parsedate_to_datetime(date))
except (TypeError, ValueError):
    date = email.utils.formatdate(localtime=True)
m = EmailMessage()
m['From'] = 'nippper <%s>' % mfrom
m['To'] = mto
m['Subject'] = title
m['Date'] = date
m['Message-ID'] = '<nippper-%s@nippper.com>' % pid
m['List-Id'] = 'nippper <nippper.com>'
m['X-Original-URL'] = link
with open(os.path.join(dir, 'body.html'), encoding='utf-8') as f:
    m.set_content(f.read(), subtype='html')
with open(os.path.join(dir, 'parts.tsv')) as f:
    for line in f:
        name, mime = line.rstrip('\n').split('\t')
        with open(os.path.join(dir, name), 'rb') as img:
            m.add_related(img.read(), *mime.split('/'), cid='<%s@nippper>' % name)
sys.stdout.buffer.write(m.as_bytes())
PY
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
