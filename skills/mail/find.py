#!/usr/bin/env python3
"""Print the Maildir file of a message by its Message-ID, for the mail skill.

Looks up notmuch first, then scans headers under the Maildir. Exits 1 if not found.
File names in a synced Maildir change with flags, so resolve the path right before use.
"""

import argparse
import os
import shutil
import subprocess
import sys
from email.parser import BytesHeaderParser
from email import policy
from pathlib import Path

MAILDIR = Path(os.environ.get("MAILDIR", Path.home() / "Maildir"))


def normalize(message_id):
    return message_id.strip().strip("<>")


def via_notmuch(message_id):
    if not shutil.which("notmuch"):
        return None
    subprocess.run(["notmuch", "new", "--quiet"], capture_output=True)
    out = subprocess.run(["notmuch", "search", "--output=files", f"id:{message_id}"],
                         capture_output=True, text=True).stdout
    return next((Path(f) for f in out.splitlines() if Path(f).is_file()), None)


def via_scan(message_id, maildir):
    target = f"<{message_id}>"
    needle = message_id.encode()
    for sub in sorted(maildir.glob("**/cur")) + sorted(maildir.glob("**/new")):
        for path in sub.iterdir():
            try:
                with open(path, "rb") as f:
                    head = f.read(65536)
                if needle not in head:
                    continue
                headers = BytesHeaderParser(policy=policy.default).parsebytes(head)
            except OSError:
                continue
            if (headers["Message-ID"] or "").strip() == target:
                return path
    return None


def find(message_id, maildir=MAILDIR):
    message_id = normalize(message_id)
    return via_notmuch(message_id) or via_scan(message_id, maildir)


def main():
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("message_id", help="Message-ID, with or without <>")
    p.add_argument("--maildir", type=Path, default=MAILDIR, help="Maildir root (default: $MAILDIR or ~/Maildir)")
    args = p.parse_args()
    path = find(args.message_id, args.maildir)
    if not path:
        sys.exit(f"error: message not found: <{normalize(args.message_id)}>")
    print(path)


if __name__ == "__main__":
    main()
