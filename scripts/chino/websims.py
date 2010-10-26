#!/usr/bin/env python
"""
WebSims setup
"""
import os, sys, glob, shutil
import pyproj
import numpy as np
import cst

# parameters
nproc = 1
template = 'ws-meta-in.py'
author = 'Geoffrey Ely'
title = 'Chino Hills'
scale = 0.001
sims = 'run/sim/*'
force = '-f' in sys.argv[1:]

# loop over sims
for path in glob.glob( sims ):

    # skip if already exists
    path += os.sep
    if not force and os.path.exists( path + 'ws-meta.py' ):
        continue
    print path

    # meta data
    meta = cst.util.load( path + 'meta.py' )
    extent = meta.extent
    bounds = meta.bounds
    proj = pyproj.Proj( **meta.projection )

    # snapshot and time history dimensions
    x, y, t = meta.shapes['snap-v1.bin']; nsnap = x, y, t
    x, y, t = meta.shapes['hist-v1.bin']; nhist = t, x, y
    x, y, t = meta.deltas['snap-v1.bin']; dsnap = scale * x, scale * y, t
    x, y, t = meta.deltas['hist-v1.bin']; dhist = t, scale * x, scale * y

    # adjust bounds for WebSims (should fix WebSims instead)
    x, y = bounds[:2]
    proj = cst.coord.Transform( proj, translate=(-x[0], -y[0]) )
    x = 0.0, (x[1] - x[0])
    y = 0.0, (y[1] - y[0])
    bounds = x, y

    # WebSims configuration
    vscale = 0.002
    uscale = 0.002
    vticks = 0, vscale, 2 * vscale
    uticks = 0, uscale, 2 * uscale
    meta.__dict__.update( locals() )
    wsmeta = open( template ).read()
    open( path + 'ws-meta.py', 'w' ).write( wsmeta % meta.__dict__ )

    # topography
    topo, extent = cst.data.topo( extent )
    lon, lat = extent
    topo_extent = (lon[0] + 360.0, lon[1] + 360.0), lat

    # hypocenter
    x, y, z = meta.origin
    x, y = proj( x, y )
    f = path + 'source-xyz.txt'
    np.savetxt( f, scale * np.array( [[x,y,z]] ) )

    # map data
    f1 = open( path + 'mapdata.txt', 'w' )
    f2 = open( path + 'mapdata-xyz.txt', 'w' )
    for kind in 'coastlines', 'borders':
        x, y = cst.data.mapdata( kind, 'high', extent, 10.0 )
        z = cst.coord.interp2( topo_extent, topo, (x, y) )
        np.savetxt( f1, np.array( [x,y,z] ).T )
        x, y = proj( x, y )
        x, y, i = cst.data.clipdata( x, y, bounds )
        z = z[i]
        np.savetxt( f2, scale * np.array( [x,y,z] ).T )
    f1.close()
    f2.close()

    # surface Vs
    j, k = nsnap[:2]
    n = j * k
    post = 'rm lon.bin lat.bin dep.bin rho.bin vp.bin\nmv vs.bin %s/vs0.bin' % os.path.realpath( path )
    job = cst.cvm.stage( nsample=n, nproc=nproc, post=post, workdir='run', run='exec' )
    rundir = job.rundir + os.sep
    shutil.copy2( path + 'lon', rundir + 'lon.bin' )
    shutil.copy2( path + 'lat', rundir + 'lat.bin' )
    np.zeros( n, 'f' ).tofile( rundir + 'dep.bin' )
    cst.cvm.launch( job )

