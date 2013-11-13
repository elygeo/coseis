#!/usr/bin/env python
"""
Explosion test problem
"""
import os, subprocess
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
prm['bc1'] = ['+node', '+node', '+node']; reg = 0.0
prm['bc1'] = ['+cell', '+cell', '+cell']; reg = 0.5
prm['bc2'] = ['pml', 'pml', 'pml']

# source properties
i = reg
val = 1.0
tau = 0.1
prm['pxx'] = (s_[i,i,i,:], '.', val, 'brune', tau)
prm['pyy'] = (s_[i,i,i,:], '.', val, 'brune', tau)
prm['pzz'] = (s_[i,i,i,:], '.', val, 'brune', tau)

# material
prm['rho'] = rho = 2670.0
prm['vp']  = vp = 6000.0
prm['vs']  = vs = 3464.0
prm['gam'] = 0.0
prm['hourglass'] = [1.0, 1.0]

# receivers FIXME
x = reg
y = reg + 3000.0 / dx
z = reg + 4000.0 / dx
for f in 'vx', 'vy', 'vz':
    prm[f] = [
        (s_[x,x,z,:], '.>', 'p1-%s.bin' % f),
        (s_[x,y,z,:], '.>', 'p2-%s.bin' % f),
        (s_[x,x,z,:], '.>', 'p3-%s.bin' % f),
        (s_[y,y,z,:], '.>', 'p4-%s.bin' % f),
        (s_[y,x,z,:], '.>', 'p5-%s.bin' % f),
        (s_[x,x,z,:], '.>', 'p6-%s.bin' % f),
    ]

# snapshots
j = int(reg + 0.5)
for f in 'vx', 'vy', 'vz':
    prm[f] += [
        (s_[j,:,:,::10], '=>', 'snap-%s.bin' % f),
    ]

# run sord
os.mkdir('run')
os.chdir('run')
job = cst.sord.stage(prm)
subprocess.check_call(job['launch'])

