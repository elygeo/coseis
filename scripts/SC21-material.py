#!/usr/bin/env python
import os
import json
import shutil
import numpy as np
import cst.cvms

# parameters
dx, nproc = 2000.0, 1
dx, nproc = 200.0, 60
dx, nproc = 100.0, 240
dx, nproc = 500.0, 2
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
meta = {
    'delta': delta,
    'shape': shape,
    'bounds': bounds,
    'extent': extent,
    'npml': 10,
}

# create run directory
d = 'repo/SC21-Mesh-%.0f' % dx
os.mkdir(d)
os.chdir(d)
f = os.path.join(cst.home, 'Util', 'Mesh-Extrude.py')
shutil.copy2(f, '.')
meta = json.dumps(meta, indent=4, sort_keys=True)
open('meta.json', 'w').write(meta)
np.save(x.astype('f'), 'lat.npy')
np.save(y.astype('f'), 'lon.npy')

job1 = cst.job.launch(
    execute='python mesh-extrude.py',
    minutes=nsample // 120000000,
    nproc=min(3, nproc),
)

job2 = cst.cvms.stage(
    version='2.2',
    nsample=nsample,
    nproc=nproc,
)

cst.job.launch(job2, depend=job1['jobid'])
