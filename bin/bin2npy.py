#!/usr/bin/env python
"""
Convert binary files to NumPy
Geoffrey Ely, 2015-03-10
"""
import os, sys, json
import numpy as np

# metadata file
if os.path.exists('meta.json'):
    meta = json.load(open('meta.json'))
else:
    meta = {}

# arguments
files = []
for i in sys.argv[1:]:
    if i.startswith('--'):
        k, v = i[2:].split('=')
        if len(v) and not v[0].isalpha():
            v = json.loads(v)
        meta[k] = v
    else:
        files.append(i)

# data type
if 'dtype' in meta:
    dtype = meta['dtype']
else:
    dtype = 'f'

# process files
for f in files:
    f1 = f.replace('.bin', '.npy')
    if f == f1:
        raise Exception('Missing .bin extention for ' + f)
    if 'shapes' in meta and f in meta['shapes']:
        print(f)
        n = meta['shapes'][f]
        v = np.fromfile(f, dtype).reshape(n[::-1]).T
    elif 'shape' in meta:
        print(f)
        n = meta['shape']
        v = np.fromfile(f, dtype).reshape(n[::-1]).T
    else:
        print('Warning: no shape information found for ' + f)
        v = np.fromfile(f, dtype)
    np.save(f1, v)

