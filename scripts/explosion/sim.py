#!/usr/bin/env python
"""
Explosion test problem
"""
import os, math
import numpy as np
import cst
prm = cst.sord.parameters()
fld = cst.sord.fieldnames()
prm['oplevel'] = 6

# dimensions
dx, dy, dz, dt = 50.0, 50.0, 50.0, 0.004
dx, dy, dz, dt = 100.0, 100.0, 100.0, 0.015
dx, dy, dz, dt = 200.0, 200.0, 200.0, 0.03
dx, dy, dz, dt = 200.0, 200.0, 200.0, 0.016
nx = int(6000.0 / dx + 1.0001)
ny = int(6000.0 / dy + 1.0001)
nz = int(6000.0 / dz + 1.0001)
nt = int(   3.0 / dt + 1.0001)
prm['delta'] = [dx, dy, dz, dt]
prm['shape'] = [nx, ny, nz, nt]
prm['nproc3'] = [1, 1, 2]

# source type
sources = [
    ['potency', 1.0],
    #['moment', 3*rho*vp*vp - 4*rho*vs*vs],
]

# boundary conditions & hypocenter
prm['bc1'] = [1, 1, 1]; prm['ihypo'] = [1.0, 1.0, 1.0]
prm['bc1'] = [2, 2, 2]; prm['ihypo'] = [1.5, 1.5, 1.5]
prm['bc2'] = [10, 10, 10]

# material
rho, vp, vs = 2670.0, 6000.0, 3464.0
prm['hourglass'] = [1.0, 1.0]
prm['fieldio'] = [
    fld['rho'] == rho,
    fld['vp']  == vp,
    fld['vs']  == vs,
    fld['gam'] == 0.0,
]

# output
j = prm['ihypo'][0]
k = 3000.0 / dx + j
l = 4000.0 / dx + j
for f in 'v1', 'v2', 'v3', 'e11', 'e22', 'e33':
    prm['fieldio'] += [
        fld[f][j,j,l,:] >> 'p1-%s.bin' % f,
        fld[f][j,k,l,:] >> 'p2-%s.bin' % f,
        fld[f][j,j,l,:] >> 'p3-%s.bin' % f,
        fld[f][k,k,l,:] >> 'p4-%s.bin' % f,
        fld[f][k,j,l,:] >> 'p5-%s.bin' % f,
        fld[f][j,j,l,:] >> 'p6-%s.bin' % f,
    ]
for f in 'v1', 'v2', 'v3':
    prm['fieldio'] += [fld[f][j,:,:,::10] >> 'snap-%s.bin' % f]

# loop over sources
cwd = os.getcwd()
for source, s in sources:

    # source properties
    prm['source'] = source
    prm['tau'] = tau = 0.1
    prm['source1'] = src1 = [s, s, s]
    prm['source2'] = src2 = [0.0, 0.0, 0.0]

    # point source
    if 1:
        prm['nsource'] = 0
        prm['pulse'] = 'integral_brune'
        prm['rundir'] = p = os.path.join('run', 'point-' + source)
        os.makedirs(p)
        cst.sord.run(prm)

    # finite source
    if 0:
        prm['nsource'] = 1
        prm['pulse'] = 'none'
        t = dt * np.arange(nt)
        f = 1.0 - math.exp(-t / tau) / tau * (t + tau)
        p = os.path.join('run', 'finite-' + source)
        q = os.path.join(p, 'source')
        os.makedirs(q)
        os.chdir(p)
        cst.source.write(f, nt, dt, 0.0, prm['ihypo'], src1, src2, q)
        cst.sord.run(prm)
        os.chdir(cwd)

