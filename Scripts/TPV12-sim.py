#!/usr/bin/env python3
import os
import math
import cst.sord
import numpy as np

# FIXME: prestress not correct

dx = 100.0

dt = dx / 12500.0
nx = int(16500.0 / dx + 21.5)
ny = int(16500.0 / dx + 21.5)
nz = int(12000.0 / dx + 120.5)
nt = int(8.0 / dt + 1.5)

alpha = math.sin(math.pi / 3.0)

prm = {
    'shape': [nx, ny, nz, nt],
    'delta': [dx, dx, dx, dt],
    'nproc3': [1, 1, 2],
    'bc1': ['-node', 'free', 'free'],
    'bc2': ['pml', 'pml', 'free'],
    'n1expand': [0, 0, 50],
    'n2expand': [0, 0, 50],
    'affine': [
        [1.0, 0.0, 0.0],
        [0.0, alpha, 0.0],
        [0.0, 0.5, 1.0],
    ],
    'hourglass': [1.0, 2.0],
    'rho': [2700.0],
    'vp': [5716.0],
    'vs': [3300.0],
    'faultnormal': '+z',
    'co': [200000.0],
    'dc': [0.5],
    'mud': [0.1],
    'sxx': [([0, []], '=>', 'sxx.bin')],
    'syy': [([0, []], '=>', 'syy.bin')],
    'szz': [([0, []], '=>', 'szz.bin')],
}

# hypocenter
y = 12000.0 / dx
z = nz // 2 - 0.5
prm['hypocenter'] = hypo = [0.0, y, z]

# near-fault volume
i = int(15000.0 / dx + 0.5)
l0 = int(z - 3000.0 / dx + 0.5)
l1 = int(z + 3000.0 / dx + 0.5)
prm['gam'] = [0.2, ([[i], [i], [l0, l1]], '=', 0.02)]
prm['mus'] = [10000.0, ([[i+1], [i+1]], '=', 0.7)]
prm['trup'] = [([[i+1], [i+1], -1], '=>', 'trup.bin')]

# nucleation
k = int(hypo[1])
m = int(1500.0 / dx + 0.5)
n = int(1500.0 / dx + 1.5)
prm['mus'] += [
    ([[n], [k-n, k+n+1]], '=', 0.66),
    ([[n], [k-m, k+m+1]], '=', 0.62),
    ([[m], [k-n, k+n+1]], '=', 0.62),
    ([[m], [k-m, k+m+1]], '=', 0.54),
]

# slip, slip velocity, and shear traction time histories
for j, k in [
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
    x = j * 100.0 / dx
    y = k * 100.0 / dx
    for f in (
        'sux', 'suy', 'suz',
        'svx', 'svy', 'svz',
        'tsx', 'tsy', 'tsz', 'tnm'
    ):
        s = 'faultst%03ddp%03d-%s.bin' % (j, k, f)
        if f not in prm:
            prm[f] = []
        prm[f] += [([x, y, []], '.>', s)]

# displacement and velocity time histories
for j, k, l in [
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
    x = j * 100.0 / dx
    y = k * 100.0 / dx / alpha
    z = l * 100.0 / dx + hypo[2]
    for f in 'ux', 'uy', 'uz', 'vx', 'vy', 'vz':
        s = 'body%03dst%03ddp%03d-%s.bin' % (j, k, l, f)
        s = s.replace('body-', 'body-0')
        if f not in prm:
            prm[f] = []
        prm[f] += [([x, y, z, []], '.>', s)]

# pre-stress
d = np.arange(ny) * alpha * dx
x = d * 9.8 * -1147.16
y = d * 9.8 * -1700.0
z = d * 9.8 * -594.32
k = int(13800.0 / dx + 1.5)
x[k:] = y[k:]
z[k:] = y[k:]

d = os.repo + 'TPV12'
os.mkdir(d)
os.chdir(d)
x.astype('f').tofile('sxx.bin')
y.astype('f').tofile('syy.bin')
z.astype('f').tofile('szz.bin')

cst.jon.launch(cst.sord.run(prm))
