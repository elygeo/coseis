#!/usr/bin/env python
import os
import numpy as np


def vmcheck():
    vpmin, vsmin = 1500.0, 500.0
    vpmin, vsmin = 0.0, 0.0
    block = 16 * 1024 * 1024
    dtype = 'f'

    nb = np.dtype(dtype).itemsize
    n = os.path.getsize('rho.bin') // nb
    fr = open('rho.bin', 'rb')
    fp = open('vp.bin', 'rb')
    fs = open('vs.bin', 'rb')

    sumr, minr, maxr = 0.0, float('inf'), -float('inf')
    sump, minp, maxp = 0.0, float('inf'), -float('inf')
    sums, mins, maxs = 0.0, float('inf'), -float('inf')
    sumn, minn, maxn = 0.0, float('inf'), -float('inf')

    i = 0
    while i < n:
        b = min(n-i, block)

        f = np.fromfile(fp, dtype=dtype, count=b)
        g = np.fromfile(fs, dtype=dtype, count=b)
        if vpmin:
            f = np.maximum(f, vpmin)
        if vsmin:
            g = np.maximum(g, vsmin)
        sump += f.astype('d').sum()
        sums += g.astype('d').sum()
        minp, maxp = min(minp, f.min()), max(maxp, f.max())
        mins, maxs = min(mins, g.min()), max(maxs, g.max())

        g = (0.5 * f * f - g * g) / (f * f - g * g)
        f = np.fromfile(fr, dtype=dtype, count=b)
        sumr += f.astype('d').sum()
        sumn += g.astype('d').sum()
        minr, maxr = min(minr, f.min()), max(maxr, f.max())
        minn, maxn = min(minn, g.min()), max(maxn, g.max())

        i += b

        print('         Min          Max         Mean %12d / %12d' % (i, n))
        print('%12g %12g %12g rho' % (minr, maxr, sumr / i))
        print('%12g %12g %12g vp' % (minp, maxp, sump / i))
        print('%12g %12g %12g vs' % (mins, maxs, sums / i))
        print('%12g %12g %12g nu' % (minn, maxn, sumn / i))
