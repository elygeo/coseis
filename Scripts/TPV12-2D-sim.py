#!/usr/bin/env python3
import os
import math
import numpy as np
import cst.sord

# FIXME: prestress not correct

prm = {}

# dimensions
dx = 100.0
dt = dx / 12500.0
nx = 2
ny = int(16500.0 / dx + 21.5)
nz = int(12000.0 / dx + 120.5)
nt = int(8.0 / dt + 1.5)

prm['delta'] = [dx, dx, dx, dt]
prm['shape'] = [nx, ny, nz, nt]
prm['nproc3'] = [1, 1, 2]

# boundary conditions
prm['bc1'] = ['+node', 'free', 'free']
prm['bc2'] = ['+node', 'pml',  'free']

# mesh
alpha = math.sin(math.pi / 3.0)
prm['affine'] = [
    [1.0, 0.0,   0.0],
    [0.0, alpha, 0.0],
    [0.0, 0.5,   1.0]
]
prm['n1expand'] = [0, 0, 50]
prm['n2expand'] = [0, 0, 50]

# hypocenter
y = 12000.0 / dx
z = nz // 2 - 0.5
prm['hypocenter'] = hypo = [0.0, y, z]

# near-fault volume
k = int(15000.0 / dx + 0.5)
l0 = int(z - 3000.0 / dx + 0.5)
l1 = int(z + 3000.0 / dx + 0.5)

# material properties
prm['rho'] = [2700.0]
prm['vp'] = [5716.0]
prm['vs'] = [3300.0]
prm['gam'] = [0.2, ([[], [k], [l0, l1]], '==', 0.02)]
prm['hourglass'] = 1.0, 2.0

# fault parameters
k = int(15000.0 / dx) + 1
prm['faultnormal'] = '+z'
prm['co'] = [200000.0]
prm['dc'] = [0.5]
prm['mud'] = [0.1]
prm['mus'] = [10000.0, ([[], [k]], '=', 0.7)]
prm['sxx'] = ([0, ':'], '=<', 'sxx.bin')
prm['syy'] = ([0, ':'], '=<', 'syy.bin')
prm['szz'] = ([0, ':'], '=<', 'szz.bin')

# nucleation
i = int(1500.0 / dx + 0.5)
k = int(hypo[1])
prm['mus'] = [
    ([[], [k-i, k+i+1]],   '=', 0.62),
    ([[], [k-i-1, k+i+2]], '=', 0.54),
]

# fault time histories
for k in 0, 15, 30, 45, 75, 120:
    y = k * 100.0 / dx
    for f in (
        'sux', 'suy', 'suz',
        'svx', 'svy', 'svz',
        'tsx', 'tsy', 'tsz', 'tnm',
    ):
        if f not in prm:
            prm[f] = []
        s = 'faultst%03ddp000-%s.bin' % (k, f)
        prm[f] += [([0.0, y, []], '.>', s)]

# body time histories
for k, l in [
    [0, -30],
    [0, -20],
    [0, -10],
    [0,  10],
    [0,  20],
    [0,  30],
    [3, -10],
    [3,  -5],
    [3,   5],
    [3,  10],
]:
    y = k * 100.0 / dx / alpha
    z = l * 100.0 / dx + hypo[2]
    for f in 'u1', 'u2', 'u3', 'v1', 'v2', 'v3':
        s = 'body%03dst000dp%03d-%s.bin' % (l, k, f)
        s = s.replace('body-', 'body-0')
        prm[f] += [([0.0, y, z, []], '.>', s)]

# pre-stress
d = np.arange(ny) * alpha * dx
x = d * 9.8 * -1147.16
y = d * 9.8 * -1700.0
z = d * 9.8 * -594.32
k = int(13800.0 / dx + 1.5)
x[k:] = y[k:]
z[k:] = y[k:]

# run SORD
d = cst.sord.repo + 'TVP12-2D'
os.mkdir(d)
os.chdir(d)
x.astype('f').tofile('sxx.bin')
y.astype('f').tofile('syy.bin')
z.astype('f').tofile('szz.bin')
cst.sord.run(prm)
