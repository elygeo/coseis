#!/usr/bin/env python
"""
PEER Lifelines program task 1A01, Problem LOH.1
Layer over a halfspace model with buried double-couple source.
"""
import os
import cst.sord

nthread, nproc = 1, 16
nthread, nproc = 4, 1

dx, dt = 50.0, 0.004
dx, dt = 100.0, 0.008

x, y, z, t = 8000.0, 10000.0, 6000.0, 9.0

nx = int(x / dx + 20.5)
ny = int(y / dx + 20.5)
nz = int(z / dx + 20.5)
nt = int(t / dt + 1.5)

i = []
l = [None, int(1000.0 / dx + 0.5)]

prm = {
    'nthread': nthread,
    'nproc3': [1, nproc, 1],
    'shape': [nx, ny, nz, nt],
    'delta': [dx, dx, dx, dt],
    'bc1': ['-cell', '-cell', 'free'],
    'bc2': ['pml', 'pml', 'pml'],
    'hourglass': [1.0, 2.0],
    'gam': [0.0],
    'rho': [2700.0, ([i, i, l], '=', 2600.0)],
    'vp': [6000.0, ([i, i, l], '=', 4000.0)],
    'vs': [3464.0, ([i, i, l], '=', 2000.0)],
    'mxy': [([0, 0, 40, i], '+', 1e18, 'brune', 0.1)],
}

# receivers
for i in range(10):
    x = 0.5 + 600.0 * (i + 1) / dx
    y = 0.5 + 800.0 * (i + 1) / dx
    for f in 'vx', 'vy', 'vz':
        prm[f] = [
            ([x, y, 0.0, []], '.>', 'p%s-%s.bin' % (i, f)),
        ]

p = 'repo/LOH1'
os.mkdir(p)
os.chdir(p)
cst.sord.run(prm)
