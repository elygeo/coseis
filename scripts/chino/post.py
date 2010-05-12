#!/usr/bin/env python
"""
Step 4: Create WebSims files
"""
import os, sys, glob, pyproj
import numpy as np
import cvm

# parameters
template = 'wsconf-in.py'
author = 'Geoffrey Ely'
title = 'Chino Hills'
scale = 0.001
sims = 'run/sim/*'
force = '-f' in sys.argv[1:]

# loop over sims
for path in glob.glob( sims ):

    # skip if already exists
    path += os.sep
    if not force and os.path.exists( path + 'wsconf.py' ):
        continue
    print path

    # meta data
    meta = cvm.util.load( path + 'meta.py' )
    name = meta.name
    extent = meta.extent
    bounds = meta.bounds
    proj = pyproj.Proj( **meta.projection )
    x_shape = meta.shapes['snap']
    t_shape = meta.shapes['hist']
    x, y, z = meta.deltas['snap']; x_delta = scale * x, scale * y, scale * z
    x, y, z = meta.deltas['hist']; t_delta = scale * x, scale * y, scale * z

    # adjust bounds for WebSims (should fix WebSims instead)
    x, y = bounds[:2]
    proj = cvm.coord.Transform( proj, translate=(-x[0], -y[0]) )
    x = 0.0, (x[1] - x[0])
    y = 0.0, (y[1] - y[0])
    bounds = x, y

    # WebSims configuration
    vscale = 0.002
    uscale = 0.002
    vticks = 0, vscale, 2 * vscale
    uticks = 0, uscale, 2 * uscale
    meta.__dict__.update( locals() )
    wsconf = open( template ).read()
    open( path + 'wsconf.py', 'w' ).write( wsconf % meta.__dict__ )

    # topography
    topo, extent = cvm.data.topo( extent )
    lon, lat = extent
    ddeg = 0.5 / 60.0

    # hypocenter
    x, y, z = meta.origin
    x, y = proj( x, y )
    f = path + 'source-xyz.txt'
    np.savetxt( f, scale * np.array( [[x,y,z]] ) )

    # map data
    f1 = open( path + 'mapdata.txt', 'w' )
    f2 = open( path + 'mapdata-xyz.txt', 'w' )
    for kind in 'coastlines', 'borders':
        x, y = cvm.data.mapdata( kind, 'high', extent, 10.0 )
        z = cvm.coord.interp2( lon[0]+360.0, lat[0], ddeg, ddeg, topo, x, y )
        np.savetxt( f1, np.array( [x,y,z] ).T )
        x, y = proj( x, y )
        x, y, i = cvm.data.clipdata( x, y, bounds )
        z = z[i]
        np.savetxt( f2, scale * np.array( [x,y,z] ).T )
    f1.close()
    f2.close()

    # surface Vs
    j, k = x_shape[:2]
    n = j * k
    post = 'mv vs %s/vs0' % os.path.realpath( path )
    job = cvm.stage( nsample=n, nproc=2, post=post, workdir='tmp' )
    rundir = job.rundir + os.sep
    os.link( path + 'lon', rundir + 'lon' )
    os.link( path + 'lat', rundir + 'lat' )
    np.zeros( n, 'f' ).tofile( rundir + 'dep' )
    os.system( rundir + 'run.sh' )

