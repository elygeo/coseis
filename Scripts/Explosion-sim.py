#!/usr/bin/env python3
import os
import cst.sord

prm = {}

# step size
dx, dt = 50.0, 0.004
dx, dt = 100.0, 0.015
dx, dt = 200.0, 0.03
dx, dt = 200.0, 0.016

# dimensions
nx = int(6000.0 / dx + 1.0001)
nt = int(3.0 / dt + 1.0001)
prm['delta'] = [dx, dx, dx, dt]
prm['shape'] = [nx, nx, nx, nt]
prm['nproc3'] = [1, 1, 2]
prm['nproc3'] = [1, 1, 1]

# boundary conditions & hypocenter
prm['bc1'] = ['+node', '+node', '+node']; reg = 0.0
prm['bc1'] = ['+cell', '+cell', '+cell']; reg = 0.5
prm['bc2'] = ['pml', 'pml', 'pml']

# source properties
i = reg
val = 1.0
tau = 0.1
prm['pxx'] = ([i, i, i, []], '.', val, 'brune', tau)
prm['pyy'] = ([i, i, i, []], '.', val, 'brune', tau)
prm['pzz'] = ([i, i, i, []], '.', val, 'brune', tau)

# material
prm['rho'] = [2670.0]
prm['vp'] = [6000.0]
prm['vs'] = [3464.0]
prm['gam'] = [0.0]
prm['hourglass'] = [1.0, 1.0]

# receivers FIXME
x = reg
y = reg + 3000.0 / dx
z = reg + 4000.0 / dx
for f in 'vx', 'vy', 'vz':
    prm[f] = [
        ([x, x, z, []], '.>', 'p1-%s.bin' % f),
        ([x, y, z, []], '.>', 'p2-%s.bin' % f),
        ([x, x, z, []], '.>', 'p3-%s.bin' % f),
        ([y, y, z, []], '.>', 'p4-%s.bin' % f),
        ([y, x, z, []], '.>', 'p5-%s.bin' % f),
        ([x, x, z, []], '.>', 'p6-%s.bin' % f),
    ]

# snapshots
j = int(reg + 0.5)
for f in 'vx', 'vy', 'vz':
    prm[f] += [
        ([j, [], [], [None, None, 10]], '=>', 'snap-%s.bin' % f),
    ]

# run sord
d = cst.sord.repo + 'Explosion'
os.mkdir(d)
os.chdir(d)
cst.sord.run(prm)
