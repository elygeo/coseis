#!/usr/bin/env python
"""
Mesh generation
"""
import os
import numpy as np
import cst, meta

# metedata
dtype = meta.dtype
shape = meta.shape
delta = meta.delta
npml = meta.npml
ntop = meta.ntop
hold = 'hold' + os.sep

# variant
if meta.cvm == 'cvmg':
    version = 'vx63'
    vs30 = 'wills'
else:
    version = 'vx63'
    vs30 = None

# read data
dep = np.arange(shape[2]) * delta[2]
n = shape[:2]
x = np.fromfile('x.bin', dtype).reshape(n[::-1]).T
y = np.fromfile('y.bin', dtype).reshape(n[::-1]).T
z = np.fromfile('topo.bin', dtype).reshape(n[::-1]).T

# demean topography
z0 = z.mean()
z -= z0

# PML regions are extruded
for w in x, y, z:
    for i in xrange(npml, 0, -1):
        w[i-1,:] = w[i,:]
        w[-i,:]  = w[-i-1,:]
        w[:,i-1] = w[:,i]
        w[:,-i]  = w[:,-i-1]

# topography blending function for elevation
n = shape[2] - ntop - npml
w = 1.0 - np.r_[np.zeros(ntop), 1.0 / (n - 1) * np.arange(n), np.ones(npml)]

# node elevation mesh
fh = cst.util.open_excl(hold + 'z3.bin', 'wb')
if fh:
    for i in range(dep.size):
        (dep[i] + z0 + w[i] * z).T.tofile(fh)
    fh.close()

# cell center locations
dep = 0.5 * (dep[:-1] + dep[1:])
x = 0.25 * (x[:-1,:-1] + x[1:,:-1] + x[:-1,1:] + x[1:,1:])
y = 0.25 * (y[:-1,:-1] + y[1:,:-1] + y[:-1,1:] + y[1:,1:])
z = 0.25 * (z[:-1,:-1] + z[1:,:-1] + z[:-1,1:] + z[1:,1:])

# topography blending function for depth
n = shape[2] - ntop - npml
w = np.r_[np.zeros(ntop), 1.0 / n * (0.5 + np.arange(n)), np.ones(npml)]

# material extraction
fr = cst.util.open_excl(hold + 'rho.bin', 'wb')
if fr:
    fp = open(hold + 'vp.bin', 'wb')
    fs = open(hold + 'vs.bin', 'wb')
    vp = cst.cvmh.Extraction(x, y, 'vp', vs30, version=version)
    vs = cst.cvmh.Extraction(x, y, 'vs', vs30, version=version)
    sumr, minr, maxr = 0.0, np.inf, -np.inf
    sump, minp, maxp = 0.0, np.inf, -np.inf
    sums, mins, maxs = 0.0, np.inf, -np.inf
    sumn, minn, maxn = 0.0, np.inf, -np.inf
    for i in range(dep.size):
        zz = w[i] * z - dep[i]
        f = vp(zz)
        g = vs(zz)
        f.T.tofile(fp)
        g.T.tofile(fs)
        sump += f.astype('d').sum()
        sums += g.astype('d').sum()
        minp, maxp = min(minp, f.min()), max(maxp, f.max())
        mins, maxs = min(mins, g.min()), max(maxs, g.max())
        g = (0.5 * f * f - g * g) / (f * f - g * g)
        f = cst.cvmh.nafe_drake(f)
        f.T.tofile(fr)
        sumr += f.astype('d').sum()
        sumn += g.astype('d').sum()
        minr, maxr = min(minr, f.min()), max(maxr, f.max())
        minn, maxn = min(minn, g.min()), max(maxn, g.max())
    fr.close()
    fp.close()
    fs.close()
    n = f.size * dep.size
    print('         Min          Max         Mean')
    print('%12g %12g %12g rho' % (minr, maxr, sumr / n))
    print('%12g %12g %12g vp'  % (minp, maxp, sump / n))
    print('%12g %12g %12g vs'  % (mins, maxs, sums / n))
    print('%12g %12g %12g nu'  % (minn, maxn, sumn / n))


