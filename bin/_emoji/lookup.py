import os
import sys
import json

here = os.path.dirname(os.path.realpath(__file__))

if __name__ == '__main__':
    q = ' '.join(sys.argv[1:])
    if q:
        emoji = json.load(open(os.path.join(here, 'emoji.json'), 'r'))
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
                print('\\U{}'.format(code))