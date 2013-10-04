#!/usr/bin/env python
"""
Explosion test problem
"""
import os, math
import numpy as np
import cst
s_ = cst.sord.get_slices()
prm = {}
prm['oplevel'] = 6

# step size
dx, dt = 50.0, 0.004
dx, dt = 100.0, 0.015
dx, dt = 200.0, 0.03
dx, dt = 200.0, 0.016

# dimensions
nx = int(6000.0 / dx + 1.0001)
nt = int(   3.0 / dt + 1.0001)
prm['delta'] = [dx, dx, dx, dt]
prm['shape'] = [nx, nx, nx, nt]
prm['nproc3'] = [1, 1, 2]

# boundary conditions & hypocenter
prm['bc1'] = [1, 1, 1]; reg = 1.0
prm['bc1'] = [2, 2, 2]; reg = 1.5
prm['bc2'] = [10, 10, 10]

# material
prm['rho'] = rho = 2670.0
prm['vp']  = vp = 6000.0
prm['vs']  = vs = 3464.0
prm['gam'] = 0.0
prm['hourglass'] = [1.0, 1.0]

# output
j = reg
k = reg + 3000.0 / dx
l = reg + 4000.0 / dx
for f in 'v1', 'v2', 'v3', 'e11', 'e22', 'e33':
    prm[f] = [
        (s_[j,j,l,:], '.>', 'p1-%s.bin' % f),
        (s_[j,k,l,:], '.>', 'p2-%s.bin' % f),
        (s_[j,j,l,:], '.>', 'p3-%s.bin' % f),
        (s_[k,k,l,:], '.>', 'p4-%s.bin' % f),
        (s_[k,j,l,:], '.>', 'p5-%s.bin' % f),
        (s_[j,j,l,:], '.>', 'p6-%s.bin' % f),
    ]
for f in 'v1', 'v2', 'v3':
    prm[f] += [
        (s_[j,:,:,::10], '=>', 'snap-%s.bin' % f),
    ]

# source properties
#val = 3.0 * rho * vp * vp - 4 * rho * vs * vs # moment
val = 1.0
cwd = os.getcwd()

# point source
if 1:
    i = reg
    tau = 0.1
    prm['p11'] = (s_[i,i,i,:], '+', val, 'brune', tau)
    prm['p22'] = (s_[i,i,i,:], '+', val, 'brune', tau)
    prm['p33'] = (s_[i,i,i,:], '+', val, 'brune', tau)
    prm['rundir'] = p = os.path.join('run', 'point')
    os.makedirs(p)
    cst.sord.run(prm)
    os.chdir(cwd)

# finite source
if 0:
    prm['nsource'] = 1
    prm['source'] = 'potency'
    i = [reg, reg, reg]
    t = dt * np.arange(nt)
    f = 1.0 - math.exp(-t / tau) / tau * (t + tau)
    p = os.path.join('run', 'finite')
    q = os.path.join(p, 'source')
    os.makedirs(q)
    os.chdir(p)
    cst.source.write(f, nt, dt, 0.0, i, [1.0, 1.0, 1.0], [0.0, 0.0, 0.0], q)
    cst.sord.run(prm)
    os.chdir(cwd)

