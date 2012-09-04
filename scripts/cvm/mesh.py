#!/usr/bin/env python
"""
Mesh generation and CVM-S extraction.
"""
import os, subprocess
import numpy as np
import pyproj
import cst

# TeraShake
delta = 200.0; nproc = 512; nstripe = 32;
delta = 20000.0; nproc = 2; nstripe = 1;
x, y, z = 600000.0, 300000.0, 80000.0
proj = pyproj.Proj(proj='utm', zone=11, ellps='WGS84')
proj = cst.coord.Transform(proj, origin=(-121.0, 34.5), rotate=40.0)

# CH5Hz, Olsen, 2012 Aug 31
delta = 8.0; nproc = 512; nstripe = 32;
delta = 800.0; nproc = 2; nstripe = 1;
x, y, z = 56000.0, 40000.0, 28000.0
proj = pyproj.Proj(proj='tmerc', lon_0=-118.3, lat_0=33.75)

# node locations
d = 0.5 * delta
x = np.arange(d, x, delta)
y = np.arange(d, y, delta)
z = np.arange(d, z, delta)
shape = x.size, y.size, z.size
nsample = x.size * y.size * z.size

# create mesh
x, y = np.meshgrid(x, y)
x, y = proj(x, y, inverse=True)
x = x.astype('f')
y = y.astype('f')

# build mesher
cfg = cst.util.configure()
m = open('Makefile.in').read()
m = m.format(
    shape_x = shape[0] * shape[1],
    shape_z = shape[2],
    delta = delta,
    z_start = 0.0,
    **cfg
)
open('Makefile', 'w').write(m)
subprocess.check_call(['make'])

# save 2D mesh
d = 'run/mesh/hold'
if not os.path.isdir(d):
    os.makedirs('run/mesh/hold')
x.astype('f').tofile('run/mesh/lon.bin')
y.astype('f').tofile('run/mesh/lat.bin')

# launch mesher
job0 = cst.util.launch(
    name = 'mesh',
    code = 'mesh',
    stagein = ['mesh.x'],
    command = './mesh.x',
    new = False,
    minutes = nsample // 100000000,
    nproc = min(3, nproc),
    nthread = 1,
    nstripe = nstripe,
)

# launch cvms
cst.cvms.launch(
    depend = job0.jobid,
    nproc = nproc,
    nthread = 1,
    nstripe = nstripe,
    nsample = nsample,
    file_lon = '../mesh/hold/lon.bin',
    file_lat = '../mesh/hold/lat.bin',
    file_dep = '../mesh/hold/dep.bin',
    file_rho = '../mesh/hold/rho.bin',
    file_vp = '../mesh/hold/vp.bin',
    file_vs = '../mesh/hold/vs.bin',
)

