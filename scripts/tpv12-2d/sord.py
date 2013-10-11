#!/usr/bin/env python
"""
SCEC Code Validation Workshop, Test Problem 12-2D
FIXME: prestress not correct
"""
import os, math
import numpy as np
import cst
s_ = cst.sord.get_slices()
prm = {}

# dimensions
dx = 100.0
dt = dx / 12500.0
nx = 2
ny = int(16500.0 / dx +  21.5)
nz = int(12000.0 / dx + 120.5)
nt = int(    8.0 / dt +   1.5)
prm['delta'] = [dx, dx, dx, dt]
prm['shape'] = [nx, ny, nz, nt]
prm['nproc3'] = [1, 1, 2]

# boundary conditions
prm['bc1'] = [1,  0, 0]
prm['bc2'] = [1, 10, 0]

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
k = 12000.0 / dx + 1
l = nz // 2 + 1
prm['ihypo'] = ihypo = [1, k, l]

# near-fault volume
k = 15000.0 / dx + 0.5
l0 = l - 3000.0 / dx + 0.5
l1 = l + 3000.0 / dx + 0.5

# material properties
prm['rho'] = 2700.0
prm['vp']  = 5716.0
prm['vs']  = 3300.0
prm['gam'] = [0.2, (s_[1.5,1.5:k,l0:l1] == 0.02)]
prm['hourglass'] = 1.0, 2.0

# fault parameters
k = 15000.0 / dx
prm['faultnormal'] = 3
prm['co'] = 200000.0
prm['dc'] = 0.5
prm['mud'] = 0.1
prm['mus'] = [10000.0, (s_[:,:k,:], '=', 0.7)]
prm['s11'] = (s_[1,:,:], '=<', 's11.bin')
prm['s22'] = (s_[1,:,:], '=<', 's22.bin')
prm['s33'] = (s_[1,:,:], '=<', 's33.bin')

# nucleation
i = 1500.0 / dx
k = ihypo[1]
prm['mus'] = [
    (s_[:,k-i  :k+i,  :], '=', 0.62),
    (s_[:,k-i-1:k+i+1,:], '=', 0.54),
]

# fault time histories
l = ihypo[2]
for y in 0, 15, 30, 45, 75, 120:
    k = y * 100.0 / dx + 1
    for f in 'su1', 'su2', 'su3', 'sv1', 'sv2', 'sv3', 'ts1', 'ts2', 'ts3', 'tnm':
        if f not in prm:
            prm[f] = []
        s = 'faultst%03ddp000-%s.bin' % (y, f)
        prm[f] += [(s_[1,k,l,:], '.>', s)]

# body time histories
for y, z in [
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
    k = y * 100.0 / dx / alpha + 1
    l = z * 100.0 / dx + ihypo[2]
    for f in 'u1', 'u2', 'u3', 'v1', 'v2', 'v3':
        s = 'body%03dst000dp%03d-%s.bin' % (z, y, f)
        s = s.replace('body-', 'body-0')
        prm[f] += [(s_[1,k,l,:], '.>', s)]

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
x.astype('f').tofile('run/s11.bin')
y.astype('f').tofile('run/s22.bin')
z.astype('f').tofile('run/s33.bin')

# run SORD
cst.sord.run(prm)

