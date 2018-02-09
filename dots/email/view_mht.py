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
        headers, content = chunk.strip().split('\n\n')
        headers = dict([l.split(': ') for l in headers.split('\n')])
        parts.append((headers, content))

    # assuming first part is the html doc
    # (though we could also check from headers)
    html = parts.pop(0)[1]
    html = quopri.decodestring(html).decode('utf8')

    # assume remaining parts are b64-encoded assets
    # (though again we could verify via headers)
    for headers, content in parts:
        cid = 'cid:{}'.format(headers['Content-Id'][1:-1])
        mime = headers['Content-Type']
        data = 'data:{};base64, {}'.format(mime, content)
        html = html.replace(cid, data)

    with open(output, 'w') as f:
        f.write(html)


if __name__ == '__main__':
    import sys
    convert(sys.argv[1], sys.argv[2])