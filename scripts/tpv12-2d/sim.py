#!/usr/bin/env python
"""
SCEC Code Validation Workshop, Test Problem 12-2D
FIXME: prestress not correct
"""
import os, math
import numpy as np
import cst
prm = cst.sord.parameters()
fld = cst.sord.fieldnames()

# dimensions
dx, dy, dz, dt = 100.0, 100.0, 100.0, 100.0 / 12500.0
nx = 2
ny = int(16500.0 / dy +  21.5)
nz = int(12000.0 / dz + 120.5)
nt = int(    8.0 / dt +   1.5)
prm['delta'] = [dx, dy, dz, dt]
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
prm['ihypo'] = [1, 12000.0 / dy + 1, nz // 2 + 1]

# near-fault volume
k = 15000.0 / dy + 0.5
l = 3000.0 / dz + 0.5
l0 = prm['ihypo'][2] - l
l1 = prm['ihypo'][2] + l

# material properties
prm['hourglass'] = 1.0, 2.0
prm['fieldio'] = [
    fld['rho'] == 2700.0,
    fld['vp']  == 5716.0,
    fld['vs']  == 3300.0,
    fld['gam'] == 0.2,
    fld['gam'][1.5,1.5:k,l0:l1,:] == 0.02,
]

# fault parameters
k = 15000.0 / dy
l = prm['ihypo'][2]
prm['faultnormal'] = 3
prm['fieldio'] += [
    fld['co'] == 2e5,
    fld['dc'] == 0.5,
    fld['mud'] == 0.1,
    fld['mus'] == 1e4,
    fld['mus'][:,:k,l,:] == 0.7,
    fld['s11'][1,:,l,0] << 's11.bin',
    fld['s22'][1,:,l,0] << 's22.bin',
    fld['s33'][1,:,l,0] << 's33.bin',
]

# nucleation
i = 1500.0 / dx
j, k, l = prm['ihypo']
prm['fieldio'] += [
    fld['mus'][:,k-i:k+i,l,:] == 0.62,
    fld['mus'][:,k-i-1:k+i+1,l,:] == 0.54,
]

# fault time histories
l = prm['ihypo'][2]
for y in 0, 15, 30, 45, 75, 120:
    k = y * 100.0 / dy + 1
    for f in 'su1', 'su2', 'su3', 'sv1', 'sv2', 'sv3', 'ts1', 'ts2', 'ts3', 'tnm':
        s = 'faultst%03ddp000-%s.bin' % (y, f)
        prm['fieldio'] += [fld[f][1,k,l,:] > s]

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
    l = z * 100.0 / dy + prm['ihypo'][2]
    for f in 'u1', 'u2', 'u3', 'v1', 'v2', 'v3':
        s = 'body%03dst000dp%03d-%s.bin' % (z, y, f)
        s = s.replace('body-', 'body-0')
        prm['fieldio'] += [fld[f][1,k,l,:] > s]

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

