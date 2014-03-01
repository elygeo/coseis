#!/usr/bin/env python
"""
Mesh generation
"""
import os, json
import numpy as np

# metedata
meta = json.load('meta.json')
shape = meta['shape']
delta = meta['delta']
npml = meta['npml']
ntop = meta['ntop']

# read data
dep = np.arange(shape[2]) * delta[2]
x = np.load('lon.npy')
y = np.load('lat.npy')
z = np.load('topo.npy')

# demean topography
z0 = z.mean()
z -= z0

# PML regions are extruded
for w in x, y, z:
    for i in range(npml, 0, -1):
        w[i-1,:] = w[i,:]
        w[-i,:]  = w[-i-1,:]
        w[:,i-1] = w[:,i]
        w[:,-i]  = w[:,-i-1]

# topography blending function for elevation
n = shape[2] - ntop - npml
w = 1.0 - np.r_[np.zeros(ntop), 1.0 / (n - 1) * np.arange(n), np.ones(npml)]

# node elevation mesh
mode = os.O_WRONLY | os.O_CREAT | os.O_EXCL
try:
    fd = os.open('mesh-z3.bin', mode)
except OSError:
    pass
else:
    with os.fdopen(fd, 'wb') as fh:
        for i in range(dep.size):
            (dep[i] + z0 + w[i] * z).T.tofile(fh)

# cell center locations
dep = 0.5 * (dep[:-1] + dep[1:])
x = 0.25 * (x[:-1,:-1] + x[1:,:-1] + x[:-1,1:] + x[1:,1:])
y = 0.25 * (y[:-1,:-1] + y[1:,:-1] + y[:-1,1:] + y[1:,1:])
z = 0.25 * (z[:-1,:-1] + z[1:,:-1] + z[:-1,1:] + z[1:,1:])

# topography blending function for depth
n = shape[2] - ntop - npml
w = np.r_[np.zeros(ntop), 1.0 / n * (0.5 + np.arange(n)), np.ones(npml)]

# write dep file
try:
    fd = os.open('mesh-dep.bin', mode)
except OSError:
    pass
else:
    with os.fdopen(fd, 'wb') as fh:
        for i in range(dep.size):
            (w[i] * z - dep[i]).astype('f').T.tofile(fh)

# write lon file
try:
    fd = os.open('mesh-lon.bin', mode)
except OSError:
    pass
else:
    with os.fdopen(fd, 'wb') as fh:
        for i in range(dep.size):
            x.T.tofile(fh)

# write lat file
try:
    fd = os.open('mesh-lat.bin', mode)
except OSError:
    pass
else:
    with os.fdopen(fd, 'wb') as fh:
        for i in range(dep.size):
            y.T.tofile(fh)

