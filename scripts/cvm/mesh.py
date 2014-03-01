#!/usr/bin/env python
"""
Mesh generation and CVM-S extraction.
"""
import os, subprocess, shutil
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
delta = 8.0; nproc = 32768; nstripe = 32;
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
    nnode = shape[0] * shape[1],
    nz = shape[2],
    delta = delta,
    zstart = 0.0,
    **cfg
)
open('Makefile', 'w').write(m)
subprocess.check_call(['make'])

# create run directory
path = os.path.join('run', 'mesh') + os.sep
os.makedirs(path)

# save files
shutil.copy2('mesh.x', path)
os.chdir(path)
x.astype('f').tofile('lon.bin')
y.astype('f').tofile('lat.bin')

# dir path
#subprocess.check_call(['setstrip', nstripe])

# launch mesher
job = cst.util.launch(
    nthread = 1,
    nproc = 4,
    ppn_range = [4],
    command = os.path.join('.', 'mesh.x'),
    minutes = int(nsample // 1000000000),
)

# launch cvms
cst.cvms.run(
    nsample = nsample,
    nproc = nproc,
    depend = job['jobid'],
)

