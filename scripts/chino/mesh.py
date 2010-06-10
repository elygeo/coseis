#!/usr/bin/env python
"""
Mesh generation
"""
import os
import numpy as np
import meta

# location
rundir = 'cvm4' + os.sep

# metedata
dtype = meta.dtype
shape = meta.shape
delta = meta.delta
npml = meta.npml
ntop = meta.ntop

# read data
n = shape[:2]
x = np.fromfile( 'lon', dtype ).reshape( n[::-1] ).T
y = np.fromfile( 'lat', dtype ).reshape( n[::-1] ).T
z = np.fromfile( 'topo', dtype ).reshape( n[::-1] ).T

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

# demean topography
z0 = z.mean()
z -= z0

# node elevation mesh
dep = np.arange( shape[2] ) * delta[2]
f3 = open( 'z3', 'wb' )
for i in range( dep.size ):
    (dep[i] + z0 + w[i] * z).T.tofile( f3 )
f3.close()

# cell center locations
dep = 0.5 * (dep[:-1] + dep[1:])
x = 0.25 * (x[:-1,:-1] + x[1:,:-1] + x[:-1,1:] + x[1:,1:])
y = 0.25 * (y[:-1,:-1] + y[1:,:-1] + y[:-1,1:] + y[1:,1:])
z = 0.25 * (z[:-1,:-1] + z[1:,:-1] + z[:-1,1:] + z[1:,1:])

# topography blending function for depth
n = shape[2] - ntop - npml
w = np.r_[ np.zeros(ntop), 1.0 / n * (0.5 + np.arange(n)), np.ones(npml) ]

# write lon/lat/depth mesh
f1 = open( rundir + 'lon', 'wb' )
f2 = open( rundir + 'lat', 'wb' )
f3 = open( rundir + 'dep', 'wb' )
for i in range( dep.size ):
    x.T.tofile( f1 )
    y.T.tofile( f2 )
    np.array( w[i] * z - dep[i], 'f' ).T.tofile( f3 )
f1.close()
f2.close()
f3.close()

