#!/usr/bin/env python
"""
Material model extraction from CVM
"""
import os, pyproj
import numpy as np
import cst

# parameters
cvm = 'h'
cvm = 's'
dx = 100.0;  nproc = 4096
dx = 200.0;  nproc = 512
dx = 500.0;  nproc = 32
dx = 1000.0; nproc = 2
dx = 8000.0; nproc = 1
delta = dx, dx, -dx

rotate = None
origin = -117.761, 33.953, 14700.0
bounds = (-144000.0, 112000.0), (-72000.0, 72000.0), (0.0, 64000.0-dx)

if 1:

    # path
    mesh_id = '%04.f' % delta[0]
    path = os.path.join( 'run', 'mesh', mesh_id )
    path = os.path.realpath( path ) + os.sep
    os.makedirs( path )

    # projection
    projection = dict( proj='tmerc', lon_0=origin[0], lat_0=origin[1] )
    proj = pyproj.Proj( **projection )
    transform = None
    #proj = cst.coord.Transform( proj, **transform )

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
    topo, topo_extent = cst.data.topo( extent )

    # mesh
    x, y, z = bounds
    x = np.arange( shape[0] ) * delta[0] + x[0]
    y = np.arange( shape[1] ) * delta[1] + y[0]
    y, x = np.meshgrid( y, x )
    x, y = proj( x, y, inverse=True )
    z = cst.coord.interp2( topo_extent, topo, (x, y) )

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

    # save data
    cst.util.save( path + 'meta.py', meta, header='# mesh parameters\n' )
    np.savetxt( path + 'box.txt', np.array( box, 'f' ).T )
    x.astype( 'f' ).T.tofile( path + 'lon' )
    y.astype( 'f' ).T.tofile( path + 'lat' )
    z.astype( 'f' ).T.tofile( path + 'topo' )

    # python executable
    python = 'python'
    if cst.site.machine == 'nics-kraken':
        python = '/lustre/scratch/gely/local/bin/python'

    if cvm == 'h':

        # stage cvm
        cvm_proj = pyproj.Proj( **cst.cvmh.projection )
        x, y = cvm_proj( x, y )
        x.astype( 'f' ).T.tofile( path + 'x' )
        y.astype( 'f' ).T.tofile( path + 'y' )

        # launch mesher
        x, y, z = shape
        s = x * y * z / 600000 # linear
        s = x * y * z / 2000000 # nearest
        print 'CVM-H wall time estimate: %s' % s
        cst.conf.launch(
            name = 'cvmh',
            new = False,
            rundir = path,
            stagein = ['cvmh.py'],
            command = '%s cvmh.py' % python,
            seconds = s,
            nproc = min( 4, nproc ),
        )

    if cvm == 's':

        # stage cvm
        rundir = path + 'cvm' + os.sep
        post = 'rm lon lat dep\nmv rho vp vs %r' % path
        n = (shape[0] - 1) * (shape[1] - 1) * (shape[2] - 1)
        job = cst.cvm.stage( rundir=rundir, nproc=nproc, nsample=n, post=post )

        # launch mesher
        x, y, z = shape
        s = x * y * z / 2000000
        job0 = cst.conf.launch(
            name = 'mesh',
            new = False,
            rundir = path,
            stagein = ['mesh.py'],
            command = '%s mesh.py' % python,
            seconds = s,
            nproc = min( 4, nproc ),
        )

        # launch cvm, wait for mesher
        cst.cvm.launch( job, depend=job0.jobid )

