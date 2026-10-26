#!/usr/bin/env python3
"""Write a threaded reply into a Maildir, for the mail skill.

Builds a MIME message (UTF-8 text, optional HTML alternative, attachments),
sets threading headers from the original message, delivers it via tmp/ -> new/
(or cur/ when flagged), and optionally moves the flag from original to reply.
Prints the path of the delivered reply.
"""

import argparse
import mimetypes
import os
import re
import socket
import sys
import time
from email import policy
from email.message import EmailMessage
from email.parser import BytesHeaderParser
from email.utils import formatdate
from pathlib import Path

HOST = socket.gethostname()


def parse_args():
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("original", type=Path, help="path of the message to reply to")
    p.add_argument("-s", "--subject", required=True, help='full subject, e.g. "[Resolved] Fix build"')
    p.add_argument("-b", "--body", default="-", help="UTF-8 plain-text body file, '-' for stdin (default)")
    p.add_argument("--html", type=Path, help="HTML file, added as alternative inline part")
    p.add_argument("-a", "--attach", type=Path, action="append", default=[], help="attachment file (repeatable)")
    p.add_argument("--model", required=True, help="agent model name, used as From: <MODEL>@<HOSTNAME>")
    p.add_argument("--token", help="token spent, saved into Token:")
    p.add_argument("--workdir", help="saved into Working-Directory: (hostname is prefixed)")
    p.add_argument("--keyword", help="Message-ID keyword (default: derived from subject)")
    p.add_argument("--flag", action="store_true", help="flag the reply and unflag the original")
    p.add_argument("--maildir", type=Path, default=Path.home() / "Maildir/BOX", help="target Maildir (default: ~/Maildir/BOX)")
    p.add_argument("-n", "--dry-run", action="store_true", help="print the message instead of delivering it")
    return p.parse_args()


def keyword_of(subject):
    subject = re.sub(r"^\s*(\[[^\]]*\]\s*|re:\s*)*", "", subject, flags=re.I)
    words = re.findall(r"[a-z0-9]+", subject.lower())[:4]
    return "-".join(words) or "reply"


def build(args, orig):
    msg = EmailMessage()
    ts = time.time()
    msg["From"] = f"{args.model}@{HOST}"
    if orig["Reply-To"] or orig["From"]:
        msg["To"] = orig["Reply-To"] or orig["From"]
    msg["Subject"] = args.subject
    msg["Date"] = formatdate(ts, localtime=True)
    msg["Message-ID"] = f"<{ts:.6f}.{args.keyword or keyword_of(args.subject)}@{HOST}>"

    # Threading: References = original References (or In-Reply-To) + original Message-ID
    orig_id = (orig["Message-ID"] or "").strip()
    if orig_id:
        refs = (orig["References"] or orig["In-Reply-To"] or "").split()
        msg["In-Reply-To"] = orig_id
        msg["References"] = " ".join(refs + [orig_id])

    if args.token:
        msg["Token"] = args.token
    if args.workdir:
        msg["Working-Directory"] = f"{HOST}:{args.workdir}"

    body = sys.stdin.read() if args.body == "-" else Path(args.body).read_text(encoding="utf-8")
    msg.set_content(body, charset="utf-8")
    if args.html:
        msg.add_alternative(args.html.read_text(encoding="utf-8"), subtype="html", charset="utf-8")
    for path in args.attach:
        ctype = mimetypes.guess_type(path.name)[0] or "application/octet-stream"
        maintype, subtype = ctype.split("/", 1)
        msg.add_attachment(path.read_bytes(), maintype=maintype, subtype=subtype, filename=path.name)
    return msg


def deliver(maildir, data, flagged):
    for sub in ("tmp", "new", "cur"):
        if not (maildir / sub).is_dir():
            sys.exit(f"error: {maildir} is not a Maildir (no {sub}/)")
    now = time.time()
    name = f"{int(now)}.M{int(now % 1 * 1e6)}P{os.getpid()}.{HOST.replace('/', '_').replace(':', '_')}"
    tmp = maildir / "tmp" / name
    with open(tmp, "xb") as f:
        f.write(data)
        f.flush()
        os.fsync(f.fileno())
    dest = maildir / "cur" / f"{name}:2,F" if flagged else maildir / "new" / name
    os.rename(tmp, dest)
    return dest


def unflag(path):
    name = path.name
    if ":2," not in name:
        return
    base, flags = name.rsplit(":2,", 1)
    if "F" in flags:
        path.rename(path.with_name(f"{base}:2,{flags.replace('F', '')}"))


def main():
    args = parse_args()
    if not args.original.is_file():
        sys.exit(f"error: original message not found: {args.original}")
    with open(args.original, "rb") as f:
        orig = BytesHeaderParser(policy=policy.default).parse(f)

    data = build(args, orig).as_bytes(policy=policy.default)
    if args.dry_run:
        sys.stdout.write(data.decode("utf-8", "replace"))
        return

    dest = deliver(args.maildir, data, args.flag)
    if args.flag:
        unflag(args.original)
    print(dest)


if __name__ == "__main__":
    main()
