#!/usr/bin/python3

"""
for converting MHT/MHTML files
(which HTML emails containing inline attachements are
attached as)
to regular HTML files.
(b/c most browsers do not support MHTML files out-of-the-box)
"""

import quopri

def convert(fname, output='/tmp/view_mht'):
    lines = [l.strip() for l in open(fname).readlines()]
    data = open(fname).read()

    # assume first line is always boundary
    boundary = lines[0]

    # assume last parts are cruft
    chunks = data.split(boundary)[1:-1]
    parts = []
    for chunk in chunks:
        # headers and content are separated by
        # an empty line
        headers, content = chunk.strip().split('\n\n', 1)
        headers = dict([l.split(': ') for l in headers.split('\n')])
        parts.append((headers, content))

    # assuming first part is the html doc
    # (though we could also check from headers)
    html = parts.pop(0)[1]
    html = quopri.decodestring(html).decode('utf8')

    # assume remaining parts are b64-encoded assets
    # (though again we could verify via headers)
    for headers, content in parts:
        cid = headers.get('Content-Id')
        mime = headers['Content-Type']
        data = 'data:{};base64, {}'.format(mime, content)

        # if cid present, seems to be embedded image
        if cid is not None:
            cid = 'cid:{}'.format(cid[1:-1])
            html = html.replace(cid, data)

        # otherwise, some other embedded content, e.g..PDF
        else:
            html = '{}\n\n<embed src="{}" width="100%" height="600">'.format(html, data)

    with open(output, 'w') as f:
        f.write(html)


if __name__ == '__main__':
    import sys
    convert(sys.argv[1], sys.argv[2])