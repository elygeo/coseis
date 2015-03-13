#!/usr/bin/env python
"""
Convert binary files to NumPy
Geoffrey Ely, 2015-03-10

TODO: make into a library function 
TODO: adapt for very large files, ala swab.py
"""
import os, sys, json, glob
import numpy as np

def bin2npy(filenames=[], delete=False, **meta):

    # metadata
    if os.path.exists('meta.json'):
        meta = json.load(open('meta.json')).update(**meta)
    if 'dtype' in meta:
        dtype = meta['dtype']
    else:
        dtype = 'f'

    # process files
    if len(filenames) == 0:
        if 'shapes' in meta:
            filenames = meta['shapes'].keys()
    elif len(filenames) == 1:
        filenames = glob.glob(filenames[0])
    for f in filenames:
        f1 = f.replace('.bin', '.npy')
        if os.path.exists(f1):
            continue
        if f == f1:
            raise Exception(f + ': missing .bin extention')
        if 'shapes' in meta and f in meta['shapes']:
            n = meta['shapes'][f]
            v = np.fromfile(f, dtype).reshape(n[::-1]).T
        elif 'shape' in meta:
            n = meta['shape']
            v = np.fromfile(f, dtype).reshape(n[::-1]).T
        else:
            v = np.fromfile(f, dtype)
            n = v.shape
        print(f + ': %s %s' % (dtype, n))
        np.save(f1, v)
        if delete:
            os.unlink(f)

# continue if command line
if __name__ == '__main__':

    filenames = []
    for i in sys.argv[1:]:
        if i.startswith('--'):
            k, v = i[2:].split('=')
            if k not in ['dtype', 'shape', 'shapes']:
                raise Exception('Unknown option: ' + k)
            if len(v) and not v[0].isalpha():
                v = json.loads(v)
            meta[k] = v
        else:
            filenames.append(i)

    bin2npy(filenames, **meta)

