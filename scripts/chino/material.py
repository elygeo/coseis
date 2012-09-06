#!/usr/bin/env python
"""
Material model extraction from CVM
"""
import os, imp, shutil
import numpy as np
import pyproj
import cst

# resolution and parallelization
dx = 50.0;   nproc = 2048; nstripe = 32
dx = 100.0;  nproc = 256;  nstripe = 16
dx = 200.0;  nproc = 32;   nstripe = 8
dx = 500.0;  nproc = 2;    nstripe = 2
dx = 1000.0; nproc = 2;    nstripe = 1
dx = 4000.0; nproc = 1;    nstripe = 1

# coordinate system
delta = dx, dx, -dx

# chino hills
label = 'ch'

# moment tensor source
eventid = 14383980
mts = os.path.join('run', 'data', '%s.mts.py' % eventid)
mts = imp.load_source('mts', mts)

# mesh parameters
rotate = None
s, d = 1000.0, 0.5 * dx
bounds = (-80 * s + d, 48 * s - d), (-58 * s + d, 54 * s - d), (0.0, 48 * s - dx)
origin = mts.longitude, mts.latitude, mts.depth

# loop over cvm versions
for cvm in 'cvms', 'cvmh', 'cvmg':

    # projection
    projection = dict(proj='tmerc', lon_0=origin[0], lat_0=origin[1])
    proj = pyproj.Proj(**projection)
    transform = {}

    # uniform zone in pml and to deepest source depth
    max_source_depth = origin[2]
    npml = 10
    npml = min(npml, int(8000.0 / delta[0] + 0.5))
    ntop = int(max_source_depth / abs(delta[2]) + 2.5)

    # dimensions
    x, y, z = bounds
    x, y, z = x[1] - x[0], y[1] - y[0], z[1] - z[0]
    shape = (
        int(abs(x / delta[0]) + 1.5),
        int(abs(y / delta[1]) + 1.5),
        int(abs(z / delta[2]) + 1.5),
    )
    ncell = (x - 1) * (y - 1) * (z - 1),

    # corners
    x, y, z = bounds
    x = x[0], x[1], x[1], x[0]
    y = y[0], y[0], y[1], y[1]
    x, y = proj(x, y, inverse=True)
    corners = tuple(x), tuple(y)

    # box
    x, y, z = bounds
    x = np.arange(shape[0]) * delta[0] + x[0]
    y = np.arange(shape[1]) * delta[1] + y[0]
    y, x = np.meshgrid(y, x)
    x = np.concatenate([x[:,0], x[-1,1:], x[-2::-1,-1], x[0,-2::-1]])
    y = np.concatenate([y[:,0], y[-1,1:], y[-2::-1,-1], y[0,-2::-1]])
    x, y = proj(x, y, inverse=True)
    box = x, y
    extent = (x.min(), x.max()), (y.min(), y.max())

    # topography
    topo, topo_extent = cst.data.topo(extent)

    # mesh
    x, y, z = bounds
    x = np.arange(shape[0]) * delta[0] + x[0]
    y = np.arange(shape[1]) * delta[1] + y[0]
    y, x = np.meshgrid(y, x)
    x, y = proj(x, y, inverse=True)
    z = cst.coord.interp2(topo_extent, topo, (x, y))

    # metadata
    mesh_id = '%s%04.f%s' % (label, dx, cvm[-1])
    meta = dict(
        cvm = cvm,
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
        dtype = np.dtype('f').str,
    )

    # create run directory
    path = os.path.join('run', 'mesh', mesh_id) + os.sep
    os.makedirs(path + 'hold')

    # save data
    cst.util.save(path + 'meta.py', meta, header='# mesh parameters\n')
    np.savetxt(path + 'box.txt', np.array(box, 'f').T)
    x.astype('f').T.tofile(path + 'lon.bin')
    y.astype('f').T.tofile(path + 'lat.bin')
    z.astype('f').T.tofile(path + 'topo.bin')

    # cvm-s
    if cvm == 'cvms':

        # launch mesher
        shutil.copy2('mesh.py', path)
        job0 = cst.util.launch(
            rundir = path,
            nproc = min(4, nproc),
            nstripe = nstripe,
            command = '{python} mesh.py',
            minutes = ncell // 120000000,
        )

        # launch cvms
        job = cst.cvms.launch(
            rundir = path,
            iodir = path + 'hold',
            nproc = nproc,
            nstripe = nstripe,
            minutes = 30,
            depend = job0.jobid,
            nsample = ncell,
        )

    # cvm-h
    else:

        # launch mesher + cvmh
        shutil.copy2('mesh-cvmh.py', path)
        proj_cvmh = pyproj.Proj(**cst.cvmh.projection)
        x, y = proj_cvmh(x, y)
        x.astype('f').T.tofile(path + 'x.bin')
        y.astype('f').T.tofile(path + 'y.bin')
        cst.util.launch(
            rundir = path,
            nproc = min(4, nproc),
            nstripe = nstripe,
            command = '{python} mesh-cvmh.py',
            minutes = ncell // 120000000, # nearest
            #minutes = ncell // 36000000, # linear
        )

