#!/usr/bin/env python3
"""
Swap byte order.

-dtype=<NumPy dtype>  Default is native float
"""
import os
import sys


def swab(src, dst, verbose=False, dtype='f', block=64*1024*1024):
    import numpy as np
    nb = np.dtype(dtype).itemsize
    n = os.path.getsize(src)
    if n == 0 or n % nb != 0:
        return
    n //= nb
    f0 = open(src, 'rb')
    f1 = open(dst, 'wb')
    i = 0
    while i < n:
        b = min(n-i, block)
        r = np.fromfile(f0, dtype=dtype, count=b)
        r.byteswap(True).tofile(f1)
        i += b
        if verbose:
            sys.stdout.write('\r%s %3d%%' % (dst, 100.0 * i / n))
            sys.stdout.flush()
    if verbose:
        print('')
    return


def main():
    if not sys.argv[1:]:
        raise SystemExit(__doc__)
    files = []
    args = {'verbose': True}
    for k in sys.argv[1:]:
        if k[0] == '-':
            k, v = k.split('=')
            k = k.lstrip('-')
            args[k] = v
        else:
            files.append(k)
    for f in files:
        swab(f, f + '.swab', **args)

if __name__ == '__main__':
    main()
