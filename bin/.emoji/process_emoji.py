import json

data = json.load(open('_emoji.json', 'r'))
emoji = {}

for e in data.values():
    name = e['name']
    emoji[name] = {
        'name': name,
        'keywords': e['keywords'],
        'shortname': e['shortname'],
        'aliases': e['shortname_alternates'],
        'unicode': e['code_points']['output']
    }

with open('emoji.json', 'w') as f:
    json.dump(emoji, f)