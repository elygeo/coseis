#!/usr/bin/env python
"""
Material model extraction from CVM
"""
import os
import pyproj
import numpy as np
import cst

# parameters
name = 'chino'
cvm = 'cvmh'
cvm = 'cvmg'
cvm = 'cvms'
dx = 50.0;   nproc = 2048; nstripe = 32
dx = 100.0;  nproc = 256;  nstripe = 16
dx = 200.0;  nproc = 32;   nstripe = 8
dx = 500.0;  nproc = 2;    nstripe = 2
dx = 1000.0; nproc = 2;    nstripe = 1
dx = 4000.0; nproc = 1;    nstripe = 1
delta = dx, dx, -dx

# moment tensor source
eventid = 14383980
mts = os.path.join('run', 'data', '%s.mts.py' % eventid)
mts = cst.util.load(mts)

# projection
rotate = None
s, d = 1000.0, 0.5 * dx
bounds = (-80 * s + d, 48 * s - d), (-58 * s + d, 54 * s - d), (0.0, 48 * s - dx)
origin = mts.longitude, mts.latitude, mts.depth
projection = dict(proj='tmerc', lon_0=origin[0], lat_0=origin[1])
proj = pyproj.Proj(**projection)

# path
mesh_id = '%s-%s-%04.f' % (name, cvm, delta[0])
path = os.path.join('run', 'mesh', mesh_id)
path = os.path.realpath(path) + os.sep
hold = path + 'hold' + os.sep
os.makedirs(hold)

# uniform zone in PML and to deepest source depth
npml = 10
npml = min(npml, int(8000.0 / delta[0] + 0.5))
ntop = int(origin[2] / abs(delta[2]) + 2.5)

# dimensions
x, y, z = bounds
x, y, z = x[1] - x[0], y[1] - y[0], z[1] - z[0]
shape = (
    int(abs(x / delta[0]) + 1.5),
    int(abs(y / delta[1]) + 1.5),
    int(abs(z / delta[2]) + 1.5),
)

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
    rotate = rotate,
    dtype = np.dtype('f').str,
)

# save data
cst.util.save(path + 'meta.py', meta, header='# mesh parameters\n')
np.savetxt(path + 'box.txt', np.array(box, 'f').T)
x.astype('f').T.tofile(path + 'lon.bin')
y.astype('f').T.tofile(path + 'lat.bin')
z.astype('f').T.tofile(path + 'topo.bin')

# python executable
python = 'python'
if cst.site.machine == 'nics-kraken':
    python = '/lustre/scratch/gely/local/bin/python'

# cvm-s
if cvm == 'cvms':

    # stage cvms
    job = cst.cvms.stage(
        rundir = path + 'cvms',
        nsample = (shape[0] - 1) * (shape[1] - 1) * (shape[2] - 1),
        post = 'rm %slon.bin\nrm %slat.bin\nrm %sdep.bin' % (hold, hold, hold),
        nproc = nproc,
        file_lon = hold + 'lon.bin',
        file_lat = hold + 'lat.bin',
        file_dep = hold + 'dep.bin',
        file_rho = hold + 'rho.bin',
        file_vp = hold + 'vp.bin',
        file_vs = hold + 'vs.bin',
    )

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
        nproc = min(4, nproc),
        nstripe = nstripe,
    )

    # launch cvms, wait for mesher
    cst.cvms.launch(job, depend=job0.jobid)

# cvm-h
else:

    # stage cvmh
    cvm_proj = pyproj.Proj(**cst.cvmh.projection)
    x, y = cvm_proj(x, y)
    x.astype('f').T.tofile(path + 'x.bin')
    y.astype('f').T.tofile(path + 'y.bin')

    # launch mesher
    x, y, z = shape
    s = x * y * z / 600000 # linear
    s = x * y * z / 2000000 # nearest
    print 'CVM-H wall time estimate: %s' % s
    cst.conf.launch(
        name = cvm,
        new = False,
        rundir = path,
        stagein = ['cvmh.py'],
        command = '%s cvmh.py' % python,
        seconds = s,
        nproc = min(4, nproc),
        nstripe = nstripe,
    )

