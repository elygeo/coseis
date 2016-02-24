#!/usr/bin/env python3
"""
PEER Lifelines program task 1A01, Problem LOH.1
Layer over a halfspace model with buried double-couple source.
"""
import os
import cst.sord, cst.job

prm = {}

# number of processors in each dimension
prm['nthread'] = 1; prm['nproc3'] = [1, 16, 1]
prm['nthread'] = 4; prm['nproc3'] = [1, 1, 1]

# dimensions
dx, dt = 50.0, 0.004
dx, dt = 100.0, 0.008
x, y, z, t = 8000.0, 10000.0, 6000.0, 9.0
nx = int(x / dx + 20.5)
ny = int(y / dx + 20.5)
nz = int(z / dx + 20.5)
nt = int(t / dt + 1.5)
prm['delta'] = [dx, dx, dx, dt]
prm['shape'] = [nx, ny, nz, nt]

# material properties
l = int(1000.0 / dx + 0.5)
prm['rho'] = [2700.0, ([[], [], [l]], '=', 2600.0)]
prm['vp'] = [6000.0, ([[], [], [l]], '=', 4000.0)]
prm['vs'] = [3464.0, ([[], [], [l]], '=', 2000.0)]
prm['gam'] = [0.0]
prm['hourglass'] = [1.0, 2.0]

# boundary conditions:
prm['bc1'] = ['-cell', '-cell', 'free']
prm['bc2'] = ['pml',   'pml',   'pml']

# source
prm['mxy'] = ([0, 0, 40, []], '+', 1e18, 'brune', 0.1)

# receivers
for i in range(10):
    x = 0.5 + 600.0 * (i + 1) / dx
    y = 0.5 + 800.0 * (i + 1) / dx
    for f in 'vx', 'vy', 'vz':
        prm[f] = [
            ([x, y, 0.0, []], '.>', 'p%s-%s.bin' % (i, f)),
        ]

# run SORD
d = cst.sord.repo + 'LOH1'
os.mkdir(d)
os.chdir(d)
cfg = cst.sord.stage(prm)
cst.job.launch(cfg)
