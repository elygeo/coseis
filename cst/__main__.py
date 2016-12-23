import sys
import json


def json_args(argv):
    d = {}
    l = []
    for k in argv:
        if k[0] == '-':
            k = k.lstrip('-')
            if '=' in k:
                k, v = k.split('=')
                if len(v) and not v[0].isalpha():
                    v = json.loads(v)
                d[k] = v
            else:
                d[k] = True
        elif k[0] in '{[':
            d.update(json.loads(k))
        else:
            l.append(k)
    return d, l


print(__name__)
print(__file__)
print(sys.argv)
