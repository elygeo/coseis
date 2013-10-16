#!/usr/bin/env python
"""
SCEC Code Validation Workshop, Test Problem 12
FIXME: prestress not correct
"""
import os, math
import numpy as np
import cst
s_ = cst.sord.get_slices()
prm = {}

# number of processes
prm['nproc3'] = [1, 1, 2]

# model dimensions
dx = 100.0
dt = dx / 12500.0
nx = int(16500.0 / dx +  21.5)
ny = int(16500.0 / dx +  21.5)
nz = int(12000.0 / dx + 120.5)
nt = int(    8.0 / dt +   1.5)
prm['shape'] = [nx, ny, nz, nt]
prm['delta'] = [dx, dx, dx, dt]

# boundary conditions
prm['bc1'] = ['-node', 'free', 'free']
prm['bc2'] = ['pml',   'pml',  'free']

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
k = 12000.0 / dx
l = nz // 2 + 0.5
prm['ihypo'] = ihypo = [0, k, l]

# near-fault volume
j = int(15000.0 / dx + 0.5)
k = int(15000.0 / dx + 0.5)
l0 = l - 3000.0 / dx + 0.5
l1 = l + 3000.0 / dx + 0.5

# material properties
prm['rho'] = 2700.0
prm['vp']  = 5716.0
prm['vs']  = 3300.0
prm['gam'] = [0.2, (s_[:j+1,:k+1,l0:l1+1], '=', 0.02)]
prm['hourglass'] = [1.0, 2.0]

# fault parameters
i = int(15000.0 / dx + 1.5)
prm['faultnormal'] = 3
prm['co'] = 200000.0
prm['dc'] = 0.5
prm['mud'] = 0.1
prm['mus'] = [10000.0, (s_[:i,:i,:], '=', 0.7)]
prm['sxx'] = (s_[0,:,:], '=>', 'sxx.bin')
prm['syy'] = (s_[0,:,:], '=>', 'syy.bin')
prm['szz'] = (s_[0,:,:], '=>', 'szz.bin')
prm['trup'] = (s_[:i,:i,:,-1], '=>', 'trup.bin')

# nucleation
k = int(ihypo[1])
m = int(1500.0 / dx + 0.5)
n = int(1500.0 / dx + 1.5)
prm['mus'] += [
    (s_[:n,k-n:k+n+1,:], '=', 0.66),
    (s_[:n,k-m:k+m+1,:], '=', 0.62),
    (s_[:m,k-n:k+n+1,:], '=', 0.62),
    (s_[:m,k-m:k+m+1,:], '=', 0.54),
]

# slip, slip velocity, and shear traction time histories
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
    j = x * 100.0 / dx
    k = y * 100.0 / dx
    l = ihypo[2]
    for f in 'sux', 'suy', 'suz', 'svx', 'svy', 'svz', 'tsx', 'tsy', 'tsz', 'tnm':
        s = 'faultst%03ddp%03d-%s.bin' % (x, y, f)
        if f not in prm:
            prm[f] = []
        prm[f] += [(s_[j,k,l,:], '.>', s)]

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
    j = x * 100.0 / dx
    k = y * 100.0 / dx / alpha
    l = z * 100.0 / dx + ihypo[2]
    for f in 'ux', 'uy', 'uz', 'vx', 'vy', 'vz':
        s = 'body%03dst%03ddp%03d-%s.bin' % (z, x, y, f)
        s = s.replace('body-', 'body-0')
        if f not in prm:
            prm[f] = []
        prm[f] += [(s_[j,k,l,:], '.>', s)]

# pre-stress
d = np.arange(ny) * alpha * dx
x = d * 9.8 * -1147.16
y = d * 9.8 * -1700.0
z = d * 9.8 * -594.32
k = int(13800.0 / dx + 1.5)
x[k:] = y[k:]
z[k:] = y[k:]

# run directory
os.mkdir('run')
x.astype('f').tofile('run/sxx.bin')
y.astype('f').tofile('run/syy.bin')
z.astype('f').tofile('run/szz.bin')

# run SORD
cst.sord.run(prm)

