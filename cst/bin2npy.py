"""
Load binary files into NumPy arrays.
"""
import os
import sys
import json
import numpy


def load(filenames, **metadata):
    meta = {'dtype': 'f', 'shape': []}
    meta.update(metadata)
    out = []
    for f in filenames:
        if f.endswith('.json'):
            meta.update(json.load(open(f)))
            continue
        dtype = meta['dtype']
        if 'shapes' in meta and f in meta['shapes']:
            shape = meta['shapes'][f]
        else:
            shape = meta['shape']
        x = numpy.fromfile(f, dtype)
        if shape:
            x = x.reshape(shape[::-1]).T
        out.append(x)
    return out


def convert(filenames, **metadata):
    meta = {'dtype': 'f', 'shape': []}
    meta.update(metadata)
    for f in filenames:
        if f == '-':
            meta.update(json.load(sys.stdin))
            continue
        elif f.endswith('.json'):
            meta.update(json.load(open(f)))
            continue
        dtype = meta['dtype']
        if 'shapes' in meta and f in meta['shapes']:
            shape = meta['shapes'][f]
        else:
            shape = meta['shape']
        if f.endswith('.bin'):
            g = f[:-4] + '.npy'
        else:
            g = f + '.npy'
        if os.path.exists(g):
            continue
        x = numpy.fromfile(f, dtype)
        if shape:
            x = x.reshape(shape[::-1]).T
        print('%s: %s %s' % (g, dtype, x.shape))
        numpy.save(g, x)


if __name__ == '__main__':
    convert(sys.argv[1:])
