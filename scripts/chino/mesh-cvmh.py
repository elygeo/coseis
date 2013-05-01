#!/usr/bin/env python
"""
Mesh generation
"""
import os, json
import numpy as np
import cst

# metedata
meta = open('meta.json')
meta = json.load(meta)
dtype = meta['dtype']
shape = meta['shape']
delta = meta['delta']
npml = meta['npml']
ntop = meta['ntop']
hold = 'hold' + os.sep

# variant
if meta['cvm'] == 'cvmg':
    vs30 = 'wills'
else:
    vs30 = None

# read data
dep = np.arange(shape[2]) * delta[2]
n = shape[:2]
x = np.load('x.npy')
y = np.load('y.npy')
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
    fd = os.open(hold + 'z3.bin', mode)
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

# rho extraction
try:
    fd = os.open(hold + 'rho.bin', mode)
except OSError:
    pass
else:
    with os.fdopen(fd, 'wb') as fh:
        vm = cst.cvmh.Extraction(x, y, 'vp', vs30, geographic=False)
        vmin, vmax = np.inf, -np.inf
        for i in range(dep.size):
            zz = w[i] * z - dep[i]
            v = cst.cvmh.nafe_drake(vm(zz))
            vmin = min(vmin, v.min())
            vmax = max(vmax, v.max())
            v.T.tofile(fh)
    print('%12g %12g rho' % (vmin, vmax))

# vp extraction
try:
    fd = os.open(hold + 'vp.bin', mode)
except OSError:
    pass
else:
    with os.fdopen(fd, 'wb') as fh:
        vm = cst.cvmh.Extraction(x, y, 'vp', vs30, geographic=False)
        vmin, vmax = np.inf, -np.inf
        for i in range(dep.size):
            zz = w[i] * z - dep[i]
            v = vm(zz)
            vmin = min(vmin, v.min())
            vmax = max(vmax, v.max())
            v.T.tofile(fh)
    print('%12g %12g vp' % (vmin, vmax))

# vs extraction
try:
    fd = os.open(hold + 'vs.bin', mode)
except OSError:
    pass
else:
    with os.fdopen(fd, 'wb') as fh:
        vm = cst.cvmh.Extraction(x, y, 'vs', vs30, geographic=False)
        vmin, vmax = np.inf, -np.inf
        for i in range(dep.size):
            zz = w[i] * z - dep[i]
            v = vm(zz)
            vmin = min(vmin, v.min())
            vmax = max(vmax, v.max())
            v.T.tofile(fh)
    print('%12g %12g vs' % (vmin, vmax))

