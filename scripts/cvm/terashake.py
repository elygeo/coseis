#!/usr/bin/env python
"""
Mesh generation and CVM-S extraction.
"""
import os
import numpy as np
import pyproj
import cst

# parameters
delta = 200.0; nproc = 512
delta = 2000.0; nproc = 2
x, y, z = 600000.0, 300000.0, 80000.0

# projection
proj = pyproj.Proj(proj='utm', zone=11, ellps='WGS84')
proj = cst.coord.Transform(proj, origin=(-121.0, 34.5), rotate=40.0)

# node locations
d = 0.5 * delta
x = np.arange(d, x, delta)
y = np.arange(d, y, delta)
z = np.arange(d, z, delta)
nn = x.size, y.size, z.size

# create mesh
x, y = np.meshgrid(x, y)
x, y = proj(x, y, inverse=True)
x = x.astype('f')
y = y.astype('f')

# CVM setup
n = nn[0] * nn[1] * nn[2]
job = cst.cvms.stage(nsample=n, nproc=nproc)
path = job.rundir + os.sep + 'hold' + os.sep
mode = os.O_WRONLY | os.O_CREAT | os.O_EXCL

# write lon file
try:
    fh = os.fdopen(os.open(path + 'lon.bin', mode), 'wb')
except OSError:
    pass
else:
    with fh:
        for i in range(z.size):
            x.tofile(fh)

# write lat file
try:
    fh = os.fdopen(os.open(path + 'lat.bin', mode), 'wb')
except OSError:
    pass
else:
    with fh:
        for i in range(z.size):
            y.tofile(fh)

# write dep file
try:
    fh = os.fdopen(os.open(path + 'dep.bin', mode), 'wb')
except OSError:
    pass
else:
    with fh:
        for i in range(z.size):
            x.fill(z[i])
            x.tofile(fh)

