"""
Convert binary files to NumPy .npy format.

Data types will be read from file 'meta.json' if it exists.
"""
import os
import sys
import json
import numpy


def convert(filenames, dtype='f', shape=[]):
    for fn in filenames:
        t = dtype
        n = shape
        p = ['.'] + os.path.split(fn)
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
                t = m['dtype']
            if 'shapes' in m and fn in m['shapes']:
                n = m['shape'][fn]
            elif 'shape' in m:
                n = m['shape']
            break
        if fn.endswith('.bin'):
            f = fn[:-4] + '.npy'
        else:
            f = fn + '.npy'
        if os.path.exists(f):
            return
        x = numpy.fromfile(fn, t)
        if n:
            x = x.reshape(n[::-1]).T
        print('%s: %s %s' % (fn, t, x.shape))
        numpy.save(g, x)


if __name__ == '__main__':
    args = []
    kw = {}
    for i in sys.argv[1:]:
        if i[:1] == '-':
            kw['dtype'] = i.lstrip('-')
        elif i[:1] + i[-1:] == '[]':
            kw['shape'] = json.loads(i)
        else:
            args.append(i)
    convert(args, **kw)
