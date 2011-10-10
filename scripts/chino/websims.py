#!/usr/bin/env python
"""
WebSims setup
"""
import os, sys, glob
import numpy as np
import pyproj
import cst

# parameters
nproc = 2
template = 'ws-meta-in.py'
author = 'Geoffrey Ely'
title = 'Chino Hills'
scale = 0.001
sims = 'run/sim/*'
force = '-f' in sys.argv[1:]

# loop over sims
for path in glob.glob(sims):

    # skip if already exists
    path += os.sep
    if not force and os.path.exists(path + 'ws-meta.py'):
        continue
    print path

    # meta data
    meta = cst.util.load(path + 'meta.py')
    shape = meta.shape
    delta = meta.delta
    extent = meta.extent
    bounds = meta.bounds
    proj = pyproj.Proj(**meta.projection)

    # snapshot and time history dimensions
    x, y, t = meta.shapes['hold/snap-v1.bin']; nsnap = x, y, t
    x, y, t = meta.shapes['hold/hist-v1.bin']; nhist = t, x, y
    x, y, t = meta.deltas['hold/snap-v1.bin']; dsnap = scale * x, scale * y, t
    x, y, t = meta.deltas['hold/hist-v1.bin']; dhist = t, scale * x, scale * y

    # adjust bounds for WebSims (should fix WebSims instead)
    x, y = bounds[:2]
    proj = cst.coord.Transform(proj, translate=(-x[0], -y[0]))
    x = 0.0, (x[1] - x[0])
    y = 0.0, (y[1] - y[0])
    bounds = x, y

    # WebSims configuration
    vticks = 0, 0.05, 0.1, 0.15, 0.2
    uticks = 0, 0.01, 0.02, 0.03, 0.04, 0.05
    meta.__dict__.update(locals())
    wsmeta = open(template).read()
    open(path + 'ws-meta.py', 'w').write(wsmeta % meta.__dict__)

    # topography
    topo, extent = cst.data.topo(extent)
    x, y = extent
    topo_extent = (x[0] + 360.0, x[1] + 360.0), y

    # mountains
    x, y = topo_extent
    n = topo.shape
    ddeg = 0.5 / 60.0
    x = x[0] + ddeg * np.arange(n[0])
    y = y[0] + ddeg * np.arange(n[1])
    y, x = np.meshgrid(y, x)
    x, y = proj(x, y)
    v = 1000,
    x, y = cst.plt.contour(x, y, topo, v)[0]
    z = np.empty_like(x)
    z.fill(1000.0)
    np.savetxt(path + 'mountains-xyz.txt', scale * np.array([x,y,z]).T)

    # hypocenter
    x, y, z = meta.ihypo
    x = (x - 1) * delta[0]
    y = (y - 1) * delta[1]
    z = (z - 1) * delta[2]
    f = path + 'hypocenter-xyz.txt'
    np.savetxt(f, scale * np.array([[x,y,z]]))

    # receivers
    xyz = set()
    for k in meta.shapes:
        if len(meta.shapes[k]) == 1:
            x, y, z, t = zip(*meta.indices[k])[0]
            x = (x - 1) * delta[0]
            y = (y - 1) * delta[1]
            z = (z - 1) * delta[2]
            xyz.add((x, y, z))
    f = path + 'receivers-xyz.txt'
    np.savetxt(f, scale * np.array(list(xyz)))

    # map data
    f1 = open(path + 'mapdata.txt', 'w')
    f2 = open(path + 'mapdata-xyz.txt', 'w')
    with f1, f2:
        for kind in 'coastlines',:
            x, y = cst.data.mapdata(kind, 'high', extent, 10.0)
            z = cst.coord.interp2(topo_extent, topo, (x, y))
            np.savetxt(f1, np.array([x,y,z]).T)
            x, y = proj(x, y)
            x, y, i = cst.data.clipdata(x, y, bounds)
            z = z[i]
            np.savetxt(f2, scale * np.array([x,y,z]).T)

    # surface Vs
    n = shape[1], shape[0]
    x = np.fromfile(path + 'lon.bin', meta.dtype).reshape(n)
    y = np.fromfile(path + 'lat.bin', meta.dtype).reshape(n)
    z = np.zeros_like(x)
    if meta.cvm == 'cvms':
        z = cst.cvms.extract(x, y, z, 'vs', rundir='run/cvms')
    else:
        z = cst.cvmh.extract(x, y, z, 'vs')
    z.tofile(path + 'vs0.bin')

    # basins
    z.fill(1000.0)
    if meta.cvm == 'cvms':
        z = cst.cvms.extract(x, y, z, 'vs', rundir='run/cvms')
    else:
        z = cst.cvmh.extract(x, y, z, 'vs')
    x, y = proj(x, y)
    v = 2500,
    x, y = cst.plt.contour(x, y, z, v)[0]
    z = np.empty_like(x)
    z.fill(-1000.0)
    np.savetxt(path + 'basins-xyz.txt', scale * np.array([x,y,z]).T)

