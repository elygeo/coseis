#!/usr/bin/env python
"""
Reproduce Magistrale (2000) Fig. 10 fence diagram.
"""
import os, sys, pyproj
import numpy as np
import cvm

# parameters
version = 'cvm4'
nproc = 2
transpose = True
transpose = False
dx = 200.0; dz = 50.0; nz = 201
dx = 400.0; dz = 100.0; nz = 101

# projection
proj = pyproj.Proj( proj='aeqd', lon_0=-118.25, lat_0=34.1 )

# segment boundaries
ll = [
    ( -119.292, 34.431 ),
    ( -118.966, 34.098 ),
    ( -119.133, 34.274 ),
    ( -118.684, 34.406 ),
    ( -118.684, 34.406 ),
    ( -118.460, 34.338 ),
    ( -118.460, 34.338 ),
    ( -118.153, 33.867 ),
    ( -118.215, 33.973 ),
    ( -117.933, 34.210 ),
    ( -118.344, 33.758 ),
    ( -117.940, 33.980 ),
    ( -117.940, 33.980 ),
    ( -117.187, 34.137 ),
]

# sample segments
xx = []
yy = []
nn = []
for i in range( 0, len( ll ), 2 ):
    x = ll[i][0], ll[i+1][0]
    y = ll[i][1], ll[i+1][1]
    x, y = proj( x, y )
    dr = np.sqrt( np.diff( x ) ** 2 + np.diff( y ) ** 2 )
    r  = np.r_[ 0.0, np.cumsum( dr ) ]
    n  = int( r[-1] / dx + 1.5 )
    ri = np.linspace( 0.0, r[-1], n )
    x  = np.interp( ri, r, x )
    y  = np.interp( ri, r, y )
    nn += [n]
    xx += [x]
    yy += [y]

# project lon/lat to meters
xx = np.concatenate( xx )
yy = np.concatenate( yy )
xx, yy = proj( xx, yy, inverse=True )

# creat 2D mesh
z = dz * np.arange( nz )
zz, xx = np.meshgrid( z, xx )
zz, yy = np.meshgrid( z, yy )

# test for CVM bugs
if transpose:
    xx, yy, zz = xx.T, yy.T, zz.T

# only run if called from the command line
if __name__ == '__main__':

    # CVM setup
    job = cvm.stage( nsample=xx.size, nproc=nproc, name=version )
    path = job.rundir + os.sep

    # write CMV input files
    np.array( xx, 'f' ).tofile( path + 'lon' )
    np.array( yy, 'f' ).tofile( path + 'lat' )
    np.array( zz, 'f' ).tofile( path + 'dep' )

    # launch job
    cvm.launch( job )

