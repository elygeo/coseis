#!/usr/bin/env python
"""
Mesh generation
"""
import os
import numpy as np
import cst
import meta

# metedata
dtype = meta.dtype
shape = meta.shape
delta = meta.delta
npml = meta.npml

# read data
dep = np.arange(shape[2]) * delta[2]
n = shape[:2]
x = np.fromfile('lat.bin', dtype).reshape(n[::-1]).T
y = np.fromfile('lon.bin', dtype).reshape(n[::-1]).T

# PML regions are extruded
for w in x, y:
    for i in range(npml, 0, -1):
        w[i-1,:] = w[i,:]
        w[-i,:]  = w[-i-1,:]
        w[:,i-1] = w[:,i]
        w[:,-i]  = w[:,-i-1]

# cell center locations
dep = 0.5 * (dep[:-1] + dep[1:])
x = 0.25 * (x[:-1,:-1] + x[1:,:-1] + x[:-1,1:] + x[1:,1:])
y = 0.25 * (y[:-1,:-1] + y[1:,:-1] + y[:-1,1:] + y[1:,1:])
z = np.zeros_like(x)

# thread safe exclusive open
p = 'cvm' + os.sep
m = os.O_WRONLY | os.O_CREAT | os.O_EXCL

# write dep file
try:
    fh = os.fdopen(os.open(p + 'dep.bin', m), 'wb')
except OSError:
    pass
else:
    with fh:
        for i in range(dep.size):
            (z + dep[i]).astype('f').T.tofile(fh)

# write lon file
try:
    fh = os.fdopen(os.open(p + 'lat.bin', m), 'wb')
except OSError:
    pass
else:
    with fh:
        for i in range(dep.size):
            x.T.tofile(fh)

# write lat file
try:
    fh = os.fdopen(os.open(p + 'lon.bin', m), 'wb')
except OSError:
    pass
else:
    with fh:
        for i in range(dep.size):
            y.T.tofile(fh)

