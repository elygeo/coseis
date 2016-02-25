import os
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


def main():
    mod = sys.argv[1]
    args = []
    kw = {}
    for k in sys.argv[2:]:
        if k[0] == '-':
            k = k.lstrip('-')
            if '=' in k:
                k, v = k.split('=')
                if len(v) and not v[0].isalpha():
                    v = json.loads(v)
                kw[k] = v
            else:
                kw[k] = True
        else:
            args.append(k)

print(__name__)
print(__file__)
print(sys.argv)
