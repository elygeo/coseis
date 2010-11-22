#!/usr/bin/env python
"""
Material model extraction from CVM
"""
import os
import numpy as np
import cst

# parameters
dx = 100.0;  nproc = 1024
dx = 200.0;  nproc = 256
dx = 500.0;  nproc = 2
dx = 4000.0; nproc = 1
delta = dx, dx, dx

# projection
bounds = (0.0, 80000.0), (0.0, 80000.0), (0.0, 30000.0)
extent = (33.7275238, 34.44875336), (-118.90798187, -118.04201508)

# dimensions
x, y, z = bounds
x, y, z = x[1] - x[0], y[1] - y[0], z[1] - z[0]
shape = (
    int( abs( x / delta[0] ) + 1.5 ),
    int( abs( y / delta[1] ) + 1.5 ),
    int( abs( z / delta[2] ) + 1.5 ),
)

# mesh
x, y = extent
x = np.linspace( x[0], x[1], shape[0] )
y = np.linspace( y[0], y[1], shape[1] )
y, x = np.meshgrid( y, x )

# metadata
meta = dict(
    delta = delta,
    shape = shape,
    bounds = bounds,
    extent = extent,
    npml = 10,
    dtype = np.dtype( 'f' ).str,
)

# path
path = os.path.join( 'run', 'mesh' )
path = os.path.realpath( path ) + os.sep
os.makedirs( path )

# save data
cst.util.save( path + 'meta.py', meta )
x.astype( 'f' ).T.tofile( path + 'lon.bin' )
y.astype( 'f' ).T.tofile( path + 'lat.bin' )

# stage cvm
rundir = os.path.join( 'run', 'cvm' )
#post = 'rm lon.bin lat.bin dep.bin\nmv rho.bin vp.bin vs.bin %r' % path
post = ''
n = (shape[0] - 1) * (shape[1] - 1) * (shape[2] - 1)
job = cst.cvm.stage(
    rundir = rundir,
    nproc = nproc,
    nsample = n,
    post = post,
    version = '2.2'
)

# launch mesher
x, y, z = shape
s = x * y * z / 2000000
job0 = cst.conf.launch(
    name = 'mesh',
    new = False,
    rundir = path,
    stagein = ['mesh.py'],
    command = 'python mesh.py',
    seconds = s,
    nproc = min( 3, nproc ),
)

# launch cvm, wait for mesher
cst.cvm.launch( job, depend=job0.jobid )

