#!/usr/bin/env python
"""
Step 1: Mesh and CVM extraction
"""
import os, pyproj, cvm
import numpy as np

# parameters
dx = 200.0;   nproc = 512
dx = 100.0;   nproc = 4096
dx = 10000.0; nproc = 2
dx = 2000.0;  nproc = 2
dx = 500.0;   nproc = 34
delta = dx, dx, -dx

# projection
origin = -117.761, 33.953, 14700.0
bounds = (-160000.0, 160000.0), (-90000.0, 90000.0), (0.0, 60000.0)
projection = dict( proj='tmerc', lon_0=origin[0], lat_0=origin[1] )
proj = pyproj.Proj( **projection )

# path
mesh_id = '%04.f' % delta[0]
path = os.path.join( 'run', 'mesh', mesh_id )
workdir = os.path.join( 'tmp', 'mesh', mesh_id )
path = os.path.realpath( path ) + os.sep
os.makedirs( path )

# uniform zone in PML and to deepest source depth
npml = 10
npml = min( npml, int( 8000.0 / delta[0] + 0.5 ) )
ntop = int( 26000.0 / abs( delta[2] ) + 0.5 )

# dimensions
x, y, z = bounds
x, y, z = x[1] - x[0], y[1] - y[0], z[1] - z[0]
shape = (
    int( abs( x / delta[0] ) + 1.5 ),
    int( abs( y / delta[1] ) + 1.5 ),
    int( abs( z / delta[2] ) + 1.5 ),
)

# corners
x, y, z = bounds
x = x[0], x[1], x[1], x[0]
y = y[0], y[0], y[1], y[1]
x, y = proj( x, y, inverse=True )
corners = tuple( x ), tuple( y )

# box
x, y, z = bounds
x = np.arange( shape[0] ) * delta[0] + x[0]
y = np.arange( shape[1] ) * delta[1] + y[0]
y, x = np.meshgrid( y, x )
x = np.concatenate([ x[:,0], x[-1,1:], x[-2::-1,-1], x[0,-2::-1] ])
y = np.concatenate([ y[:,0], y[-1,1:], y[-2::-1,-1], y[0,-2::-1] ])
x, y = proj( x, y, inverse=True )
box = x, y
extent = (x.min(), x.max()), (y.min(), y.max())

# topography
topo, ll = cvm.data.topo( extent )
lon, lat = ll
ddeg = 0.5 / 60.0

# mesh
x, y, z = bounds
x = np.arange( shape[0] ) * delta[0] + x[0]
y = np.arange( shape[1] ) * delta[1] + y[0]
y, x = np.meshgrid( y, x )
x, y = proj( x, y, inverse=True )
z = cvm.coord.interp2( lon[0], lat[0], ddeg, ddeg, topo, x, y )
x = np.array( x, 'f' )
y = np.array( y, 'f' )
z = np.array( z, 'f' )

# metadata
meta = dict(
    mesh_id = mesh_id,
    delta = delta,
    shape = shape,
    npml = npml,
    bounds = bounds,
    corners = corners,
    extent = extent,
    origin = origin,
    projection = projection,
    transform = None,
    dtype = np.dtype( 'f' ).str,
)

# save data
cvm.util.save( path + 'meta.py', meta, header='# mesh parameters\n' )
np.savetxt( path + 'box.txt', np.array( box, 'f' ).T )
np.array( x, 'f' ).T.tofile( path + 'lon' )
np.array( y, 'f' ).T.tofile( path + 'lat' )
np.array( z, 'f' ).T.tofile( path + 'topo' )

# PML regions are extruded
for w in x, y, z:
    for i in xrange( npml, 0, -1 ):
        w[i-1,:] = w[i,:]
        w[-i,:]  = w[-i-1,:]
        w[:,i-1] = w[:,i]
        w[:,-i]  = w[:,-i-1]

# topography blending function for depth
n = shape[2] - ntop - npml
w = 1.0 - np.r_[ np.zeros(ntop), 1.0 / (n - 1) * np.arange(n), np.ones(npml) ]

# demean topography
z0 = z.mean()
z -= z0

# node elevation mesh
dep = np.arange( shape[2] ) * delta[2]
f3 = open( path + 'z3', 'wb' )
clock = cvm.util.progress()
for i in range( dep.size ):
    (dep[i] + z0 + w[i] * z).T.tofile( f3 )
    cvm.util.progress( clock, i+1, dep.size, 'Z mesh' )
f3.close()

# stage cvm
n = (shape[0] - 1) * (shape[1] - 1) * (shape[2] - 1)
post = 'mv rho %s\nmv vp %s\nmv vs %s' % (path, path, path)
cfg = cvm.stage( nsample=n, nproc=nproc, post=post, workdir=workdir )
rundir = cfg.rundir + os.sep

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
clock = cvm.util.progress()
for i in range( dep.size ):
    x.T.tofile( f1 )
    y.T.tofile( f2 )
    np.array( w[i] * z - dep[i], 'f' ).T.tofile( f3 )
    cvm.util.progress( clock, i+1, dep.size, 'Lon/Lat/Dep mesh' )
f1.close()
f2.close()
f3.close()

# launch job
if nproc <=2:
    os.system( rundir + 'run.sh' )
else:
    os.system( rundir + 'queue.sh' )

