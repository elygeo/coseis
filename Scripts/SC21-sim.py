#!/usr/bin/env python
"""
PEER Lifelines program task 1A02, Problem SC2.1
SCEC Community Velocity Model, version 2.2 with double-couple point source.
"""
import os
import json
import cst.job
import cst.sord

dx, nproc3 = 2000.0, [1, 1, 1]
dx, nproc3 = 200.0, [1, 2, 30]
dx, nproc3 = 100.0, [1, 4, 60]
dx, nproc3 = 500.0, [1, 1, 2]

mesh = cst.repo + ('SC21-Mesh-%.0f' % dx) + os.sep
meta = json.load(open(mesh + 'meta.json'))
dx, dy, dz = meta['delta']
nx, ny, nz = meta['shape']

dt = dx / 16000.0
dt = dx / 20000.0
nt = int(50.0 / dt + 1.00001)
j = int(56000.0 / dx + 0.5)
k = int(40000.0 / dx + 0.5)
l = int(14000.0 / dx + 0.5)

prm = {
    'delta': [dx, dy, dz, dt],
    'shape': [nx, ny, nz, nt],
    'bc1': ['pml', 'pml', 'free'],
    'bc2': ['pml', 'pml', 'pml'],
    'hourglass': [1.0, 1.0],
    'vp1': 600.0,
    'vs1': 200.0,
    'gam': [0.0],
    'rho': [([], '=<', 'mesh-rho.bin')],
    'vp':  [([], '=<', 'mesh-vp.bin')],
    'vs':  [([], '=<', 'mesh-vs.bin')],
    'mxy': [([j, k, l, []], '+', 1e18, 'brune', 0.2)],
}

for f in 'vx', 'vy', 'vz':
    prm[f] = []
    for i in range(8):
        j = int((74000.0 - 6000.0 * i) / dx)
        k = int((16000.0 + 8000.0 * i) / dy)
        prm[f] += [([j, k, 0, []], '=>', 'p%s-%s.bin' % (i, f))]

d = cst.repo + 'PEER-SC2.1-%.0f' % dx
os.mkdir(d)
os.chdir(d)
for v in 'rho', 'vp', 'vs':
    os.link(mesh + 'mesh-' + v + '.bin', '.')
cst.job.launch(cst.sord.stage(prm))
