#!/usr/bin/env python
"""
PEER Lifelines program task 1A02, Problem SC2.1

SCEC Community Velocity Model, version 2.2 with double-couple point source.
http://peer.berkeley.edu/lifelines/lifelines_pre_2006/lifelines_princ_invest_y-7.html#day
http://www-rohan.sdsu.edu/~steveday/BASINS/Final_Report_1A02.pdf
"""
import os, json
import cst
s_ = cst.sord.get_slices()
prm = {}

# parameters
dx = 2000.0; prm['nproc3'] = [1, 1, 1]
dx = 200.0;  prm['nproc3'] = [1, 2, 30]
dx = 100.0;  prm['nproc3'] = [1, 4, 60]
dx = 500.0;  prm['nproc3'] = [1, 1, 2]

# mesh metadata
mesh = os.path.join('run', 'SC21', 'mesh', '%.0f' % dx) + os.sep
meta = json.load(open(mesh + 'meta.json'))
dx, dy, dz = meta['delta']
nx, ny, nz = meta['shape']

# dimensions
dt = dx / 16000.0
dt = dx / 20000.0
nt = int(50.0 / dt + 1.00001)
prm['delta'] = [dx, dy, dz, dt]
prm['shape'] = [nx, ny, nz, nt]

# boundary conditions
prm['bc1'] = ['pml', 'pml', 'free']
prm['bc2'] = ['pml', 'pml', 'pml']

# material
prm['rho'] = ([], '=<', 'mesh-rho.bin')
prm['vp']  = ([], '=<', 'mesh-vp.bin')
prm['vs']  = ([], '=<', 'mesh-vs.bin')
prm['gam'] = 0.0
prm['vp1'] = 600.0
prm['vs1'] = 200.0
prm['hourglass'] = [1.0, 1.0]

# source
j = int(56000.0 / dx + 0.5)
k = int(40000.0 / dx + 0.5)
l = int(14000.0 / dx + 0.5)
prm['mxy'] = (s_[j,k,l,:], '+', 1e18, 'brune', 0.2)

# receivers
for i in range(8):
    j = int((74000.0 - 6000.0 * i) / dx)
    k = int((16000.0 + 8000.0 * i) / dy)
    for f in 'vx', 'vy', 'vz':
        if f not in prm:
            prm[f] = []
        prm[f] += [
            (s_[j,k,0,:], '=>', 'p%s-%s.bin' % (i, f)),
        ]

# run job
d = os.path.join('run', 'SC21-sim-', '%.0f' % dx)
os.makedirs(d)
os.chdir(d)
for v in 'rho', 'vp', 'vs':
    os.link(mesh + 'mesh-' + v + '.bin', '.')
cst.sord.run(prm)

