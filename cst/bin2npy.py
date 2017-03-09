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


def convert(args, force=False, **metadata):
    meta = {'dtype': 'f', 'shape': []}
    meta.update(metadata)
    for i in args:
        if i == '-':
            meta.update(json.load(sys.stdin))
            continue
        elif i == '--force':
            force = True
        elif i.endswith('.json'):
            meta.update(json.load(open(i)))
            continue
        dtype = meta['dtype']
        if 'shapes' in meta and i in meta['shapes']:
            shape = meta['shapes'][i]
        else:
            shape = meta['shape']
        if i.endswith('.bin'):
            f = i[:-4] + '.npy'
        else:
            f = i + '.npy'
        if not force and os.path.exists(f):
            continue
        x = numpy.fromfile(i, dtype)
        if shape:
            x = x.reshape(shape[::-1]).T
        print('%s: %s %s' % (f, dtype, x.shape))
        numpy.save(f, x)


if __name__ == '__main__':
    convert(sys.argv[1:])
