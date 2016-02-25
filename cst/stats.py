"""
Compute basic statistics from raw binary or NumPy .npy files.
The data type for raw binary is specied by -dtype=str option (defautls to
native float).
"""
import os
import numpy as np
from numpy.lib.npyio import format as npy


def stats(filename, dtype='f', block=64*1024*1024):
    if filename.endswith('.npy'):
        fh = open(filename, 'rb')
        version = npy.read_magic(fh)
        shape, fcont, dtype = npy._read_array_header(fh, version)
        n = np.prod(shape)
    elif filename.endswith('.bin'):
        nb = np.dtype(dtype).itemsize
        n = os.path.getsize(filename)
        if n % nb != 0:
            raise Exception()
        n //= nb
        shape = [int(n)]
        fh = open(filename, 'rb')
    else:
        raise Exception()
    if n == 0:
        rmin = float('nan')
        rmax = float('nan')
        rmean = float('nan')
    else:
        rmin = float('inf')
        rmax = -float('inf')
        rsum = 0.0
        i = 0
        m = 0
        while i < n:
            b = min(n - i, block)
            r = np.fromfile(fh, dtype=dtype, count=b)
            j = ~np.isnan(r)
            rmin = min(rmin, r[j].min().copy())
            rmax = max(rmax, r[j].max().copy())
            rsum += r[j].astype('d').sum()
            i += b
            m += j.sum()
        rmean = rsum / m
    return rmin, rmax, rmean, list(shape)


def main(files, *kw):
    print('         Min          Max         Mean  Shape')
    for f in files:
        s = stats(f, *kw)
        print('%12g %12g %12g  %s  %s' % (s + (f,)))
