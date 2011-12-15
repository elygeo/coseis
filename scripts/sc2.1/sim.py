#!/usr/bin/env python
"""
PEER Lifelines program task 1A02, Problem SC2.1

SCEC Community Velocity Model, version 2.2 with double-couple point source.
http://peer.berkeley.edu/lifelines/lifelines_pre_2006/lifelines_princ_invest_y-7.html#day
http://www-rohan.sdsu.edu/~steveday/BASINS/Final_Report_1A02.pdf
"""
import os
import cst
s_ = cst.sord.s_

# parameters
dx_ = 2000.0; nproc3 = 1, 1, 1
dx_ = 200.0;  nproc3 = 1, 2, 30
dx_ = 100.0;  nproc3 = 1, 4, 60
dx_ = 500.0;  nproc3 = 1, 1, 2

# path
rundir = os.path.join('run', 'sim', '%.0f' % dx_)

# mesh metadata
mesh_ = os.path.join('run', 'mesh', '%.0f' % dx_) + os.sep
meta = cst.util.load(mesh_ + 'meta.py')
delta = meta.delta
shape = meta.shape

# dimensions
dt_ = dx_ / 16000.0
dt_ = dx_ / 20000.0
nt_ = int(50.0 / dt_ + 1.00001)
delta += (dt_,)
shape += (nt_,)

# boundary conditions
bc1 = 10, 10, 0
bc2 = 10, 10, 10

# material
hourglass = 1.0, 1.0
vs1 = 200.0
vp1 = 600.0
fieldio = [
    ('=r', 'rho', [], 'rho.bin'),
    ('=r', 'vp',  [], 'vp.bin'),
    ('=r', 'vs',  [], 'vs.bin'),
    ('=',  'gam', [],  0.0),
]

# source
x = 56000.0 / dx_ + 1
y = 40000.0 / dx_ + 1
z = 14000.0 / dx_ + 1
ihypo = x, y, z
source = 'moment'
pulse = 'integral_brune'
tau = 0.2
source1 = 0.0, 0.0, 0.0
source2 = 0.0, 0.0, 1e18

# receivers
for i in range(8):
    j = (74000.0 - 6000.0 * i) / delta[0] + 1
    k = (16000.0 + 8000.0 * i) / delta[1] + 1
    fieldio += [
        ('=wi', 'v1', s_[j,k,1,:], 'p%s-v1.bin' % i),
        ('=wi', 'v2', s_[j,k,1,:], 'p%s-v2.bin' % i),
        ('=wi', 'v3', s_[j,k,1,:], 'p%s-v3.bin' % i),
    ]

# run job
stagein = [mesh_ + v + '.bin' for v in 'rho', 'vp', 'vs']
post = 'rm rho.bin vp.bin vs.bin'
job = cst.sord.run(locals())

