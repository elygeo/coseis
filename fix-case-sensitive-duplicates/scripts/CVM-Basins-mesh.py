#!/usr/bin/env python
"""
Simple SoCal mesh generation and CVM-S extraction.
"""
import os
import json
import numpy as np
import cst.cvms

# parameters
nproc, delta = 512, [0.25 / 60, 0.25 / 60, 20.0]
nproc, delta = 1,   [1.0 / 60, 1.0 / 60, 1000.0]
extent = (-120.5, -112.5), (31.0, 36.0), (0.0, 11000.0)

# node locations
x, y, z = extent
dx, dy, dz = delta
x = np.arange(x[0], x[1] + dx/2, dx, 'f')
y = np.arange(y[0], y[1] + dy/2, dy, 'f')
z = np.arange(z[0], z[1] + dz/2, dz, 'f')
shape = x.size, y.size, z.size
nsample = shape[0] * shape[1] * shape[2]

# 2d mesh
x, y = np.meshgrid(x, y)

# metadata
meta = {
    'delta': delta,
    'shape': shape,
    'extent': extent,
}

# run dir
p = 'repo/CVM-Basins'
os.mkdir(p)
os.chdir(p)

# save data
json.dump(open('meta.json', 'w'), meta)
np.save('lon.npy', x.astype('f'))
np.save('lat.npy', y.astype('f'))

# write input files
with open('lon.bin', 'wb') as f:
    for i in range(z.size):
        x.tofile(f)
with open('lat.bin', 'wb') as f:
    for i in range(z.size):
        y.tofile(f)
with open('dep.bin', 'wb') as f:
    for i in range(z.size):
        x.fill(z[i])
        x.tofile(f)

# launch CVM-S
cst.cvms.run(nsample=nsample, nproc=nproc)
