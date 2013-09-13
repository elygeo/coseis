#!/usr/bin/env python
"""
SCEC Code Validation Workshop, Test Problem 12
FIXME: prestress not correct
"""
import os, math
import numpy as np
import cst
s_ = cst.sord.s_
prm = {}

# number of processes
prm['nproc3'] = [1, 1, 2]

# model dimensions
prm['delta'] = dx, dy, dz, dt = [100.0, 100.0, 100.0, 100.0 / 12500.0]
prm['shape'] = nx, ny, nz, nt = [
    int(16500.0 / dx +  21.5),
    int(16500.0 / dy +  21.5),
    int(12000.0 / dz + 120.5),
    int(    8.0 / dt +   1.5),
]

# boundary conditions
prm['bc1'] = [-1,  0, 0]
prm['bc2'] = [10, 10, 0]

# mesh
alpha = math.sin(math.pi / 3.0)
prm['n1expand'] = [0, 0, 50]
prm['n2expand'] = [0, 0, 50]
prm['affine'] = [
    [1.0, 0.0, 0.0],
    [0.0, alpha, 0.0],
    [0.0, 0.5, 1.0]
]

# hypocenter
k = 12000.0 / dy + 1
l = nz // 2 + 1
prm['ihypo'] = [1, k, l]

# near-fault volume
j = [1.5, 15000.0 / dx + 0.5]
k = [1.5, 15000.0 / dy + 0.5]
l = 3000.0 / dz + 0.5
l = [prm['ihypo'][2] - l, prm['ihypo'][2] + l]

# material properties
prm['hourglass'] = [1.0, 2.0]
prm['fieldio'] = [
    ['rho', [], '=', 2700.0],
    ['vp', [],  '=', 5716.0],
    ['vs', [],  '=', 3300.0],
    ['gam', [], '=', 0.2],
    ['gam', [j,k,l,0], '=', 0.02],
]

# fault parameters
prm['faultnormal'] = 3
j = [1, 15000.0 / dx]
k = [1, 15000.0 / dy]
l = prm['ihypo'][2]
prm['fieldio'] += [
    ['co', [],  '=', 2e5],
    ['dc', [],  '=', 0.5],
    ['mud', [], '=', 0.1],
    ['mus', [], '=', 1e4],
    ['mus', [j,k,l,[]], '=', 0.7],
    ['s11', [1,[],l,0], 'R', 's11.bin'],
    ['s22', [1,[],l,0], 'R', 's22.bin'],
    ['s33', [1,[],l,0], 'R', 's33.bin'],
    ['trup', [j,k,l,[]], 'w', 'trup.bin'],
]

# nucleation
i = 1500.0 / dx
j, k, l = prm['ihypo']
prm['fieldio'] += [
    ['mus', s_[:j+i+1,k-i-1:k+i+1,l,:], '=', 0.66],
    ['mus', s_[:j+i,  k-i-1:k+i+1,l,:], '=', 0.62],
    ['mus', s_[:j+i+1,k-i:  k+i,  l,:], '=', 0.62],
    ['mus', s_[:j+i,  k-i:  k+i,  l,:], '=', 0.54],
]

# slip, slip velocity, and shear traction time histories
l = prm['ihypo'][2]
for x, y in [
    [0, 0],
    [45, 0],
    [120, 0],
    [0, 15],
    [0, 30],
    [0, 45],
    [0, 75],
    [45, 75],
    [120, 75],
    [0, 120],
]:
    j = x * 100.0 / dx + 1
    k = y * 100.0 / dy + 1
    for f in 'su1', 'su2', 'su3', 'sv1', 'sv2', 'sv3', 'ts1', 'ts2', 'ts3', 'tnm':
        p = 'faultst%03ddp%03d-%s.bin' % (x, y, f)
        p = p.replace('fault-', 'fault-0')
        prm['fieldio'] += [[f, [j,k,l,[]], 'w', p]]

# displacement and velocity time histories
for x, y, z in [
    [0, 0, -30],
    [0, 0, -20],
    [0, 0, -10],
    [0, 0, 10],
    [0, 0, 20],
    [0, 0, 30],
    [0, 3, -10],
    [0, 3, -5],
    [0, 3, 5],
    [0, 3, 10],
    [120, 0, -30],
    [120, 0, 30],
]:
    j = x * 100.0 / dx + 1
    k = y * 100.0 / dy / alpha + 1
    l = z * 100.0 / dz + prm['ihypo'][2]
    for f in 'u1', 'u2', 'u3', 'v1', 'v2', 'v3':
        p = 'body%03dst%03ddp%03d-%s.bin' % (z, x, y, f)
        p = p.replace('body-', 'body-0')
        prm['fieldio'] += [[f, [j,k,l,[]], 'w', p]]

# pre-stress
d = np.arange(ny) * alpha * dy
x = d * 9.8 * -1147.16
y = d * 9.8 * -1700.0
z = d * 9.8 * -594.32
k = int(13800.0 / dy + 1.5)
x[k:] = y[k:]
z[k:] = y[k:]

# run directory
os.mkdir('run')
x.astype('f').tofile('run/s11.bin')
y.astype('f').tofile('run/s22.bin')
z.astype('f').tofile('run/s33.bin')

# run SORD
cst.sord.run(prm)

