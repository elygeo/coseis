#!/usr/bin/env python
"""
Convert binary files to NumPy
Geoffrey Ely, 2015-03-10

TODO: make into a library function 
TODO: adapt for very large files, ala swab.py
"""
import os, sys, json
import numpy as np

def bin2npy(files=[], dtype=None, shape=None, shapes=None, delete=False):

    # metadata
    if os.path.exists('meta.json'):
        meta = json.load(open('meta.json'))
        if dtype == None and 'dtype' in meta:
            dtype = meta['dtype']
        if shape == None and 'shape' in meta:
            shape = meta['shape']
        if shapes == None and 'shapes' in meta:
            shapes = meta['shapes']
    if dtype == None:
        dtype = 'f'
    if shapes == None:
        shapes = {}
    if len(files) == 0:
        files = shapes.keys()

    # process files
    for f in files:
        if f.endswith('.bin'):
            f1 = f[:-4] + '.npy'
        else:
            f1 = f + '.npy'
        if os.path.exists(f1):
            continue
        v = np.fromfile(f, dtype)
        if f in shapes:
            n = shapes[f]
            v = v.reshape(n[::-1]).T
        elif shape:
            v = v.reshape(shape[::-1]).T
        print(f + ': %s %s' % (dtype, v.shape))
        np.save(f1, v)
        if delete:
            os.unlink(f)

# continue if command line
if __name__ == '__main__':

    args = {}
    files = []
    for i in sys.argv[1:]:
        if i.startswith('--'):
            k, v = i[2:].split('=')
            if len(v) and not v[0].isalpha():
                v = json.loads(v)
            args[k] = v
        else:
            files.append(i)

    bin2npy(files, **args)

