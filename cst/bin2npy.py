#!/usr/bin/env python3
"""
Convert binary files to NumPy .npy format.

Data types will be read from file 'meta.json' if it exists, or specified with
command line options:

-dtype=<numpy dytpe>
-shape=[nx, ny, ...]
"""

import sys
if '' in sys.path:
    sys.path.remove('')
import os
import json


def bin2npy(filename, dtype='f', shape=[]):
    import numpy as np
    p = ['.'] + os.path.split(filename)
    k = filename
    while p:
        f = os.sep.join(p + ['meta.json'])
        g = os.sep.join(p + ['meta', 'meta.json'])
        if os.path.exists(f):
            m = json.load(open(f))
        elif os.path.exists(g):
            m = json.load(open(g))
        else:
            continue
        if 'dtype' in m:
            dtype = m['dtype']
        if 'shapes' in m and k in m['shapes']:
            shape = m['shape'][k]
        elif 'shape' in m:
            shape = m['shape']
        break
    if filename.endswith('.bin'):
        f = filename[:-4] + '.npy'
    else:
        f = filename + '.npy'
    if os.path.exists(f):
        return
    v = np.fromfile(filename, dtype)
    if shape:
        v = v.reshape(shape[::-1]).T
    print('%s: %s %s' % (filename, dtype, v.shape))
    np.save(f, v)


def main():
    if not sys.argv[1:]:
        raise SystemExit(__doc__)
    args = {}
    files = []
    for i in sys.argv[1:]:
        if i.startswith('-'):
            k, v = i.split('=')
            if len(v) and not v[0].isalpha():
                v = json.loads(v)
            args[k.lstrip('-')] = v
        else:
            files.append(i)
    for f in files:
        bin2npy(f, **args)

if __name__ == '__main__':
    main()
