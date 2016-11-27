#!/usr/bin/python2
from __future__ import unicode_literals

import os
import sys
import json
import subprocess

N_LINES = 10 # n lines to show in dmenu
here = os.path.dirname(os.path.realpath(__file__))
emoji = json.load(open(os.path.join(here, 'emoji.json'), 'r'))


def search(q):
    results = []
    for data in emoji.values():
        name = data['name']
        kws = data['keywords']
        code = data['unicode']
        shortname = data['shortname']
        aliases = data['aliases']

        # for simplicity of searching,
        # ignore skin tone codes
        if '-' in code:
            continue

        if q in name\
            or any(q in kw for kw in kws)\
            or any(q in a for a in aliases)\
            or q in shortname:
            results.append((name, unichr(int(code, 16))))
    return results

def run(cmd, inp=None):
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stdin=subprocess.PIPE)
    if inp:
        inp = inp.encode('utf8')
    print(inp)
    out, err = proc.communicate(inp)
    return out.strip().decode('utf8')


if __name__ == '__main__':
    query = ' '.join(sys.argv[1:])
    results = search(query)

    if not results:
        run(['notify-send', 'No results'])
        sys.exit()

    choices = [choice for choice, _ in results]
    lookup = {choice: code for choice, code in results}
    choice = run(
        ['dmenu', '-l', str(N_LINES), '-i', '-p', '>'],
        inp='\n'.join(choices))
    if choice:
        print(lookup[choice].encode('utf8'))
    else:
        print('')