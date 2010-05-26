#!/usr/bin/env python
"""
Material model extraction from CVM
"""
import os, pyproj
import numpy as np
import cvm

# parameters
dx = 100.0;  nproc = 4096
dx = 200.0;  nproc = 512
dx = 500.0;  nproc = 32
dx = 8000.0; nproc = 1
dx = 1000.0; nproc = 2
delta = dx, dx, -dx

# path
mesh_id = '%04.f' % delta[0]
path = os.path.join( 'run', 'mesh', mesh_id )

# projection
rotate = None
origin = -117.761, 33.953, 14700.0
bounds = (-144000.0, 112000.0), (-72000.0, 72000.0), (0.0, 64000.0-dx)
projection = dict( proj='tmerc', lon_0=origin[0], lat_0=origin[1] )
proj = pyproj.Proj( **projection )
transform = None
#proj = cvm.coord.Transform( proj, **transform )

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
z = cvm.coord.interp2( (lon[0], lat[0]), (ddeg, ddeg), topo, (x, y) )
x = np.array( x, 'f' )
y = np.array( y, 'f' )
z = np.array( z, 'f' )

# metadata
meta = dict(
    mesh_id = mesh_id,
    delta = delta,
    shape = shape,
    ntop = ntop,
    npml = npml,
    bounds = bounds,
    corners = corners,
    extent = extent,
    origin = origin,
    projection = projection,
    transform = transform,
    rotate = rotate,
    dtype = np.dtype( 'f' ).str,
)

# stage cvm
rundir = os.path.realpath( path ) + os.sep
post = 'rm lon lat dep\nmv rho vp vs %r' % rundir
n = (shape[0] - 1) * (shape[1] - 1) * (shape[2] - 1)
job = cvm.stage( workdir=path, nproc=nproc, nsample=n, post=post )

# save data
cvm.util.save( rundir + 'meta.py', meta, header='# mesh parameters\n' )
np.savetxt( rundir + 'box.txt', np.array( box, 'f' ).T )
np.array( x, 'f' ).T.tofile( rundir + 'lon' )
np.array( y, 'f' ).T.tofile( rundir + 'lat' )
np.array( z, 'f' ).T.tofile( rundir + 'topo' )

# launch prep job
x, y, z = shape
s = x * y * z / 2000000
job0 = cvm.launch(
    new = False,
    rundir = path,
    name = 'mesh',
    stagein = ['mesh.py'],
    command = 'python mesh.py',
    run = job.run,
    seconds = s,
)

# launch cvm job
cvm.launch( job, depend=job0.jobid )

