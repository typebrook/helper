#!/usr/bin/env python3
"""Add token usage of a `pi -p --mode json` run to the agent's reply, for mail-agent.

Reads the JSONL event stream from stdin, finds the newest flagged message delivered since
--since in the thread of MESSAGE-ID, and puts usage into its Subject ("... (123k tokens)")
and Token: header. Only the header block changes; the body bytes are kept as-is.
The new copy keeps Message-ID and flags but gets a new file name, so a synced Maildir
sees a new message plus a deletion, never an edit in place.
Prints the path of the new copy.
"""

import argparse
import json
import os
import subprocess
import sys
import time
from email import policy
from email.parser import BytesHeaderParser
from pathlib import Path

from find import normalize
from reply import HOST


def usages(events):
    # Each completed message carries the usage of its own response; compaction reports its own
    for e in events:
        if e.get("type") == "message_end":
            yield e["message"].get("usage")
        elif e.get("type") == "compaction_end":
            yield (e.get("result") or {}).get("usage")


def total_tokens(stream):
    events = (json.loads(line) for line in stream.split(b"\n") if line.strip())
    return sum(u.get("totalTokens", 0) for u in usages(events) if u)


def human(n):
    return f"{n / 1e6:.1f}M" if n >= 1e6 else f"{round(n / 1e3)}k"


def find_reply(message_id, since):
    subprocess.run(["notmuch", "new", "--quiet"], capture_output=True)
    query = f"thread:{{id:{message_id}}} and tag:flagged and date:@{since}.. and not folder:Trash"
    out = subprocess.run(["notmuch", "search", "--output=files", "--sort=newest-first", query],
                         capture_output=True, text=True).stdout
    return next((Path(f) for f in out.splitlines() if Path(f).is_file()), None)


def retitle(path, total):
    head, _, body = path.read_bytes().partition(b"\n\n")
    headers = BytesHeaderParser(policy=policy.default).parsebytes(head + b"\n\n")
    headers.replace_header("Subject", f"{headers['Subject']} ({human(total)} tokens)")
    del headers["Token"]
    headers["Token"] = str(total)
    new_head = b"".join(policy.default.fold_binary(k, v) for k, v in headers.items())
    return new_head + b"\n" + body


def replace(path, data):
    # Same Maildir subdir and flags, new unique name: tmp/ -> cur/, then drop the old file
    maildir = path.resolve().parent.parent
    flags = path.name.rsplit(":2,", 1)[1] if ":2," in path.name else None
    now = time.time()
    name = f"{int(now)}.M{int(now % 1 * 1e6)}P{os.getpid()}.{HOST.replace('/', '_').replace(':', '_')}"
    tmp = maildir / "tmp" / name
    with open(tmp, "xb") as f:
        f.write(data)
        f.flush()
        os.fsync(f.fileno())
    dest = path.parent / (f"{name}:2,{flags}" if flags is not None else name)
    os.rename(tmp, dest)
    path.unlink()
    return dest


def main():
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("message_id", help="Message-ID of the message the agent worked on")
    p.add_argument("--since", type=int, required=True, help="epoch seconds when the agent started")
    p.add_argument("-n", "--dry-run", action="store_true", help="print the new headers instead of replacing")
    args = p.parse_args()

    total = total_tokens(sys.stdin.buffer.read())
    if not total:
        sys.exit("error: no token usage in JSON events")
    reply = find_reply(normalize(args.message_id), args.since)
    if not reply:
        sys.exit(f"error: no flagged reply since {args.since} in thread of <{normalize(args.message_id)}>")

    data = retitle(reply, total)
    if args.dry_run:
        sys.stdout.write(data.split(b"\n\n", 1)[0].decode("utf-8", "replace") + "\n")
        return
    print(replace(reply, data))


if __name__ == "__main__":
    main()
