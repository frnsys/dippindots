#!/usr/bin/python3

import re
import os
import json
from shutil import copyfile
from datetime import datetime
from tzlocal import get_localzone
from subprocess import Popen, PIPE, run

# signal number to fetch for
DAEMON_NUM = os.environ['DAEMONSIGNALNUM']

# save all messages to a temporary location
# in case we hit an error
BACKUP_LOG = '/tmp/daemon.log'

# where signal-cli saves attachments
ATTACH_DIR = os.path.expanduser('~/.config/signal/attachments/')

# base output directory
OUTPUT_DIR = os.path.expanduser('~/notes/memos')

# where to move attachments for safekeeping
# relative to OUTPUT_DIR
ASSETS_DIR = 'assets'

# file for when no command directive is specified
DEFAULT_FILE = 'memos.md'

# parse out command directives, e.g.
# for "TODO: hello world" this parses out "TODO"
COMMAND_RE = re.compile(r'^([A-Za-z]+): ?')

MEMO_TEMPLATE = '''# {dt}

{body}{attachments}

---

'''


def notify(msg):
    run(['notify-send', msg])


def fetch(from_backup=False):
    if from_backup:
        with open(BACKUP_LOG, 'r') as backup:
            return [json.loads(line) for line in backup.read().split('\n') if line]
    else:
        with open(BACKUP_LOG, 'a') as backup:
            proc = Popen(
                ['signal-cli', '-u', DAEMON_NUM, 'receive', '--json'],
                stdin=PIPE, stdout=PIPE, stderr=PIPE)
            data, err = proc.communicate()
            msgs = [json.loads(line) for line in data.decode('utf8').split('\n') if line]

            # backup messages in case something goes wrong
            for msg in msgs:
                backup.write('{}\n'.format(json.dumps(msg)))
        return msgs


if __name__ == '__main__':
    notify('Fetching memos...')
    tz = get_localzone()
    msgs = fetch()
    for msg in msgs:
        env = msg['envelope']
        body = env['dataMessage']['message']

        # localized datetime
        ts = env['timestamp']/1000
        dt = datetime.fromtimestamp(ts)
        dt = tz.localize(dt)
        dt_str = dt.strftime('%a %b %d %H:%M:%S %Z %Y')

        # handle attachments
        attachments = env['dataMessage']['attachments']
        attachment_refs = []
        for a in attachments:
            type = a['contentType']
            ext = type.split('/')[-1]
            fname = '{}.{}'.format(a['id'], ext)
            src = os.path.join(ATTACH_DIR, str(a['id']))
            dst = os.path.join(os.path.join(OUTPUT_DIR, ASSETS_DIR), fname)
            copyfile(src, dst)
            attachment_refs.append(
                '![]({})'.format(os.path.join(ASSETS_DIR, fname))
            )
        if attachments:
            attachment_content = '\n\n{}'.format('\n'.join(attachment_refs))
        else:
            attachment_content = ''

        # get command, if any
        cmd = COMMAND_RE.match(body)
        if cmd:
            cmd = cmd.groups()[0]
            fname = '{}.md'.format(cmd.lower())
            out = os.path.join(OUTPUT_DIR, fname)
        else:
            out = os.path.join(OUTPUT_DIR, DEFAULT_FILE)

        # remove command directive
        body = COMMAND_RE.sub('', body)

        with open(out, 'a') as f:
            content = MEMO_TEMPLATE.format(
                dt=dt_str,
                body=body,
                attachments=attachment_content
            )
            f.write(content)
    notify('Got {} memos'.format(len(msgs)))