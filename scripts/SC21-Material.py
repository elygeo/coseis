#!/usr/bin/env python
"""
Material model extraction from CVM
"""
import os, json, shutil
import numpy as np
import cst

# parameters
dx = 2000.0; nproc = 1
dx = 200.0;  nproc = 60
dx = 100.0;  nproc = 240
dx = 500.0;  nproc = 2
delta = dx, dx, dx

# projection
bounds = (0.0, 80000.0), (0.0, 80000.0), (0.0, 30000.0 - dx)
extent = (33.7275238, 34.44875336), (-118.90798187, -118.04201508)

# dimensions
x, y, z = bounds
x, y, z = x[1] - x[0], y[1] - y[0], z[1] - z[0]
shape = (
    int(abs(x / delta[0]) + 1.5),
    int(abs(y / delta[1]) + 1.5),
    int(abs(z / delta[2]) + 1.5),
)
nsample = (shape[0] - 1) * (shape[1] - 1) * (shape[2] - 1)

# mesh
x, y = extent
x = np.linspace(x[0], x[1], shape[0])
y = np.linspace(y[0], y[1], shape[1])
y, x = np.meshgrid(y, x)

# metadata
meta = dict(
    delta = delta,
    shape = shape,
    bounds = bounds,
    extent = extent,
    npml = 10,
)

# create run directory
path = os.path.join('run', 'SC21', 'mesh', '%.0f' % dx)
os.makedirs(path)
shutil.copy2('../util/mesh-extrude.py', path)
os.chdir(path)
json.dump(meta, open('meta.json', 'w'))
np.save(x.astype('f'), 'lat.npy')
np.save(y.astype('f'), 'lon.npy')

# launch mesher
job = cst.util.launch(
    execute = '{python} mesh-extrude.py',
    minutes = nsample // 120000000,
    nproc = min(3, nproc),
)

# launch CVM-S
cst.cvms.run(
    version = '2.2',
    nsample = nsample,
    depend = job['jobid'],
    nproc = nproc,
)

