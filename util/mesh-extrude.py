#!/usr/bin/env python
"""
Read 2D lon/lat mesh and extrude the 3D for CVM extraction.
Convert node coords to cell center coords.
Etrude PML regions if present.
"""

import os, json
import numpy as np

# metedata
meta = json.load(open('meta.json'))
npml = meta['npml']
nz = meta['shape'][2]
dz = meta['delta'][2]

# read data
x = np.load('lat.npy')
y = np.load('lon.npy')

# PML regions are extruded
for w in x, y:
    for i in range(npml, 0, -1):
        w[i-1,:] = w[i,:]
        w[-i,:]  = w[-i-1,:]
        w[:,i-1] = w[:,i]
        w[:,-i]  = w[:,-i-1]

# cell center locations
dep = np.arange(nz) * dz
dep = 0.5 * (dep[:-1] + dep[1:])
x = 0.25 * (x[:-1,:-1] + x[1:,:-1] + x[:-1,1:] + x[1:,1:])
y = 0.25 * (y[:-1,:-1] + y[1:,:-1] + y[:-1,1:] + y[1:,1:])
z = np.zeros_like(x)

# thread safe exclusive open
mode = os.O_WRONLY | os.O_CREAT | os.O_EXCL

# write dep file
try:
    fd = os.open('mesh-dep.bin', mode)
except OSError:
    pass
else:
    with os.fdopen(fd, 'wb') as fh:
        for i in range(dep.size):
            (z + dep[i]).astype('f').T.tofile(fh)

# write lon file
try:
    fd = os.open('mesh-lat.bin', mode)
except OSError:
    pass
else:
    with os.fdopen(fd, 'wb') as fh:
        for i in range(dep.size):
            x.T.tofile(fh)

# write lat file
try:
    fd = os.open('mesh-lon.bin', mode)
except OSError:
    pass
else:
    with os.fdopen(fd, 'wb') as fh:
        for i in range(dep.size):
            y.T.tofile(fh)

