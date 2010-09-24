#!/usr/bin/env python
"""
Mesh generation
"""
import numpy as np
import cst, meta

# metedata
dtype = meta.dtype
shape = meta.shape
delta = meta.delta
npml = meta.npml
ntop = meta.ntop

# read data
dep = np.arange( shape[2] ) * delta[2]
n = shape[:2]
x = np.fromfile( 'x', dtype ).reshape( n[::-1] ).T
y = np.fromfile( 'y', dtype ).reshape( n[::-1] ).T
z = np.fromfile( 'topo', dtype ).reshape( n[::-1] ).T

# demean topography
z0 = z.mean()
z -= z0

# PML regions are extruded
for w in x, y, z:
    for i in xrange( npml, 0, -1 ):
        w[i-1,:] = w[i,:]
        w[-i,:]  = w[-i-1,:]
        w[:,i-1] = w[:,i]
        w[:,-i]  = w[:,-i-1]

# topography blending function for elevation
n = shape[2] - ntop - npml
w = 1.0 - np.r_[ np.zeros(ntop), 1.0 / (n - 1) * np.arange(n), np.ones(npml) ]

# node elevation mesh
fh = cst.util.open_excl( 'z3', 'wb' )
if fh:
    for i in range( dep.size ):
        (dep[i] + z0 + w[i] * z).T.tofile( fh )
    fh.close()

# cell center locations
dep = 0.5 * (dep[:-1] + dep[1:])
x = 0.25 * (x[:-1,:-1] + x[1:,:-1] + x[:-1,1:] + x[1:,1:])
y = 0.25 * (y[:-1,:-1] + y[1:,:-1] + y[:-1,1:] + y[1:,1:])
z = 0.25 * (z[:-1,:-1] + z[1:,:-1] + z[:-1,1:] + z[1:,1:])

# topography blending function for depth
n = shape[2] - ntop - npml
w = np.r_[ np.zeros(ntop), 1.0 / n * (0.5 + np.arange(n)), np.ones(npml) ]

# rho extraction
fh = cst.util.open_excl( 'rho', 'wb' )
if fh:
    vm = cst.cvmh.Extraction( x, y, 'vp', interpolation='nearest' )
    for i in range( dep.size ):
        zz = w[i] * z - dep[i]
        cst.cvmh.nafe_drake( vm( zz ) ).T.tofile( fh )
    fh.close()

# vp extraction
fh = cst.util.open_excl( 'vp', 'wb' )
if fh:
    vm = cst.cvmh.Extraction( x, y, 'vp', interpolation='nearest' )
    for i in range( dep.size ):
        zz = w[i] * z - dep[i]
        vm( zz ).T.tofile( fh )
    fh.close()

# vs extraction
fh = cst.util.open_excl( 'vs', 'wb' )
if fh:
    vm = cst.cvmh.Extraction( x, y, 'vs', interpolation='nearest' )
    for i in range( dep.size ):
        zz = w[i] * z - dep[i]
        vm( zz ).T.tofile( fh )
    fh.close()

