#!/usr/bin/env python
"""
Explosion test problem
"""
import os
import cst
s_ = cst.sord.get_slices()
prm = {}

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

# source properties
i = reg
val = 1.0
tau = 0.1
prm['p11'] = (s_[i,i,i,:], '+', val, 'brune', tau)
prm['p22'] = (s_[i,i,i,:], '+', val, 'brune', tau)
prm['p33'] = (s_[i,i,i,:], '+', val, 'brune', tau)

# material
prm['rho'] = rho = 2670.0
prm['vp']  = vp = 6000.0
prm['vs']  = vs = 3464.0
prm['gam'] = 0.0
prm['hourglass'] = [1.0, 1.0]

# receivers
j = reg
k = reg + 3000.0 / dx
l = reg + 4000.0 / dx
for f in 'v1', 'v2', 'v3':
    prm[f] = [
        (s_[j,j,l,:], '.>', 'p1-%s.bin' % f),
        (s_[j,k,l,:], '.>', 'p2-%s.bin' % f),
        (s_[j,j,l,:], '.>', 'p3-%s.bin' % f),
        (s_[k,k,l,:], '.>', 'p4-%s.bin' % f),
        (s_[k,j,l,:], '.>', 'p5-%s.bin' % f),
        (s_[j,j,l,:], '.>', 'p6-%s.bin' % f),
    ]

# snapshots
for f in 'v1', 'v2', 'v3':
    prm[f] += [
        (s_[j,:,:,::10], '=>', 'snap-%s.bin' % f),
    ]

# run sord
os.mkdir('run')
cst.sord.run(prm)

