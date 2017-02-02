#!/usr/bin/env python
import os
import cst.job
import cst.sord

# step size options
dx, dt = 50.0, 0.004
dx, dt = 100.0, 0.015
dx, dt = 200.0, 0.03
dx, dt = 200.0, 0.016
nx = int(6000.0 / dx + 1.0001)
nt = int(3.0 / dt + 1.0001)

# registration options
bc, reg = '+node', 0.0
bc, reg = '+cell', 0.5

prm = {
    'nproc3': [1, 1, 1],
    'shape': [nx, nx, nx, nt],
    'delta': [dx, dx, dx, dt],
    'bc1': [bc, bc, bc],
    'bc2': ['pml', 'pml', 'pml'],
    'hourglass': [1.0, 1.0],
    'rho': [2670.0],
    'vp': [6000.0],
    'vs': [3464.0],
    'gam': [0.0],
    'pxx': [([reg, reg, reg, []], '.', 1.0, 'brune', 0.1)],
    'pyy': [([reg, reg, reg, []], '.', 1.0, 'brune', 0.1)],
    'pzz': [([reg, reg, reg, []], '.', 1.0, 'brune', 0.1)],
}

# receivers FIXME
x = reg
y = reg + 3000.0 / dx
z = reg + 4000.0 / dx
for f in 'vx', 'vy', 'vz':
    prm[f] = [
        ([x, x, z, []], '.>', 'p1-%s.bin' % f),
        ([x, y, z, []], '.>', 'p2-%s.bin' % f),
        ([x, x, z, []], '.>', 'p3-%s.bin' % f),
        ([y, y, z, []], '.>', 'p4-%s.bin' % f),
        ([y, x, z, []], '.>', 'p5-%s.bin' % f),
        ([x, x, z, []], '.>', 'p6-%s.bin' % f),
    ]

# snapshots
j = int(reg + 0.5)
t = [None, None, 10]
for f in 'vx', 'vy', 'vz':
    prm[f] += [([j, [], [], t], '=>', 'snap-%s.bin' % f)]

# run sord
d = cst.repo + 'Explosion'
os.mkdir(d)
os.chdir(d)
cst.job.launch(cst.sord.stage(prm))
