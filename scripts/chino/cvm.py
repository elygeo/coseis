#!/usr/bin/env python
"""
Material model extraction from CVM
"""
import os, json, shutil, subprocess
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
mts = os.path.join('run', 'data', '%s.mts.txt' % eventid)
mts = json.load(mts)

# mesh parameters
rotate = None
s, d = 1000.0, 0.5 * dx
bounds = (-80 * s + d, 48 * s - d), (-58 * s + d, 54 * s - d), (0.0, 48 * s - dx)
origin = mts['longitude'], mts['latitude'], mts['depth']

# projection
projection = {'proj': 'tmerc', 'lon_0': origin[0], 'lat_0': origin[1]}
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
ncell = (shape[0] - 1) * (shape[1] - 1) * (shape[2] - 1)

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

# mesh
x, y, z = bounds
x = np.arange(shape[0]) * delta[0] + x[0]
y = np.arange(shape[1]) * delta[1] + y[0]
y, x = np.meshgrid(y, x)
x, y = proj(x, y, inverse=True)
z = cst.data.dem([x, y])

# loop over cvm versions
cwd = os.getcwd() + os.sep
for cvm in 'cvms', 'cvmh', 'cvmg':

    # metadata
    mesh_id = '%s%04.f%s' % (label, dx, cvm[-1])
    meta = {
        '#': 'mesh parameters',
        'cvm': cvm,
        'mesh_id': mesh_id,
        'delta': delta,
        'shape': shape,
        'ntop': ntop,
        'npml': npml,
        'bounds': bounds,
        'corners': corners,
        'extent': extent,
        'origin': origin,
        'projection': projection,
        'transform': transform,
        'rotate': rotate,
    }

    # create run directory
    path = os.path.join(cwd, 'run', 'mesh', mesh_id)
    os.makedirs(path)
    os.chdir(path)
    os.mkdir('hold')

    # save data
    f = open('meta.json', 'w')
    json.dump(meta, f, indent=4, sort_keys=True)
    np.save('box.npy', box.astype('f'))
    np.save('lon.npy', x.astype('f'))
    np.save('lat.npy', y.astype('f'))
    np.save('topo.npy', z.astype('f'))

    # cvm-s
    if cvm == 'cvms':

        # build mesher
        os.chdir(cwd)
        cfg = cst.util.configure()
        m = open('mesh-in.mk').read()
        m = m.format(
            machine = cfg['machine'],
            nx = shape[0],
            ny = shape[1],
            nz = shape[2],
            delta = abs(delta[0]),
            ntop = ntop,
            npml = npml
        )
        open('mesh.mk', 'w').write(m)
        subprocess.check_call(['make', '-f', 'mesh.mk'])

        # launch mesher
        os.chdir(path)
        shutil.copy2(cwd + 'mesh.py', '.')
        job0 = cst.util.launch(
            nthread = 1,
            nproc = 4,
            ppn_range = [4],
            nstripe = nstripe,
            command = '{python} mesh.py',
            minutes = int(ncell // 120000000),
        )

        # launch cvms
        job = cst.cvms.launch(
            iodir = 'hold',
            nproc = nproc,
            nstripe = nstripe,
            minutes = 30,
            depend = job0.jobid,
            nsample = ncell,
        )

    # cvm-h
    else:

        # launch mesher + cvmh
        shutil.copy2(cwd + 'mesh-cvmh.py', '.')
        proj_cvmh = pyproj.Proj(**cst.cvmh.projection)
        x_, y_ = proj_cvmh(x, y)
        np.save('x.npy', x_.astype('f'))
        np.save('y.npy', y_.astype('f'))
        cst.util.launch(
            nthread = 1,
            nproc = 4,
            ppn_range = [4],
            nstripe = nstripe,
            command = '{python} mesh-cvmh.py',
            minutes = int(ncell // 120000000), # nearest
            #minutes = int(ncell // 36000000), # linear
        )

