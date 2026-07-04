#!/usr/bin/env python3
import json, os

base = os.path.expanduser('~/.claude/projects')
for proj in sorted(os.listdir(base)):
    proj_dir = os.path.join(base, proj)
    if not os.path.isdir(proj_dir):
        continue
    for f in sorted(os.listdir(proj_dir)):
        if not f.endswith('.jsonl'):
            continue
        title = ''
        for line in open(os.path.join(proj_dir, f)):
            e = json.loads(line)
            if e.get('type') == 'ai-title':
                title = e['aiTitle']
                break
        print(f'{proj}/{f[:-6]}  {title}')
