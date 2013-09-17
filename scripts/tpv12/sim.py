#!/usr/bin/env python
"""
SCEC Code Validation Workshop, Test Problem 12
FIXME: prestress not correct
"""
import os, math
import numpy as np
import cst
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
j = 15000.0 / dx + 0.5
k = 15000.0 / dy + 0.5
l = 3000.0 / dz + 0.5
l0 = prm['ihypo'][2] - l
l1 = prm['ihypo'][2] + l

# material properties
prm['hourglass'] = [1.0, 2.0]
prm['fieldio'] = [
    'rho = 2700.0',
    'vp = 5716.0',
    'vs = 3300.0',
    'gam = 0.2',
    'gam[1.5:{},1.5:{},{}:{},0] = 0.02'.format(j, k, l0, l1),
]

# fault parameters
prm['faultnormal'] = 3
j = 15000.0 / dx
k = 15000.0 / dy
l = prm['ihypo'][2]
prm['fieldio'] += [
    'co  = 2e5',
    'dc  = 0.5',
    'mud = 0.1',
    'mus = 1e4',
    'mus[:{},:{},{},:] = 0.7'.format(j, k, l),
    'trup[:{},:{},{},:] write trup.bin'.format(j, k, l),
    's11[1,:,{},0] = fill s11.bin'.format(l),
    's22[1,:,{},0] = fill s22.bin'.format(l),
    's33[1,:,{},0] = fill s33.bin'.format(l),
]

# nucleation
m = 1500.0 / dx
n = 1500.0 / dx + 1
j, k, l = prm['ihypo']
prm['fieldio'] += [
    'mus[:{},{}:{},{},:] = 0.66'.format(j+n, k-n, k+n, l),
    'mus[:{},{}:{},{},:] = 0.62'.format(j+n, k-m, k+m, l),
    'mus[:{},{}:{},{},:] = 0.62'.format(j+m, k-n, k+n, l),
    'mus[:{},{}:{},{},:] = 0.54'.format(j+m, k-m, k+m, l),
]

# slip, slip velocity, and shear traction time histories
fmt = '{f}[{j},{k},{l},:] write faultst{x:03d}dp{y:03d}-{f}.bin'
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
    l = prm['ihypo'][2]
    for f in 'su1', 'su2', 'su3', 'sv1', 'sv2', 'sv3', 'ts1', 'ts2', 'ts3', 'tnm':
        s = fmt.format(f=f, j=j, k=k, l=l, x=x, y=y)
        prm['fieldio'] += [s]

# displacement and velocity time histories
fmt = '{f}[{j},{k},{l},:] write body{z:03d}st{x:03d}dp{y:03d}-{f}.bin'
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
        s = fmt.format(f=f, j=j, k=k, l=l, x=x, y=y, z=z).replace('body-', 'body-0')
        prm['fieldio'] += [s]

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

