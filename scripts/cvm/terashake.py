#!/usr/bin/env python
"""
TeraShake mesh generation and CVM extraction.
"""
import os
import numpy as np
import pyproj
import cst

# parameters
nproc = 512
dx =    200.0,    200.0,   200.0
x0 =      0.0,      0.0,     0.0
x1 = 600000.0, 300000.0, 80000.0

# node locations
x = np.arange( x0[0], x1[0] + dx[0]/2, dx[0] )
y = np.arange( x0[1], x1[1] + dx[1]/2, dx[1] )
z = np.arange( x0[2], x1[2] + dx[2]/2, dx[2] )
nn = x.size, y.size, z.size

# projection
proj = pyproj.Proj( proj='utm', zone=11, ellps='WGS84' )
proj = cst.coord.Transform( proj, origin=(-121.0, 34.5), rotate=40.0 )

# create mesh
xx, yy = np.meshgrid( x, y )
xx, yy = proj( xx, yy, inverse=True )
xx = np.array( xx, 'f' )
yy = np.array( yy, 'f' )
zz = np.empty_like( xx )

# CVM setup
n = nn[0] * nn[1] * nn[2]
cfg = cst.cvm.stage( nsample=n, nproc=nproc )
path = cfg.rundir

# write CVM input files
f1 = open( os.path.join( path, 'lon.bin' ), 'wb' )
f2 = open( os.path.join( path, 'lat.bin' ), 'wb' )
f3 = open( os.path.join( path, 'dep.bin' ), 'wb' )
for z in z:
    xx.tofile( f1 )
    yy.tofile( f2 )
    zz.fill( z )
    zz.tofile( f3 )
f1.close()
f2.close()
f3.close()

