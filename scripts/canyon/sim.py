#!/usr/bin/env python
"""
Semi-cylindrical canyon with vertically incident P-wave.
"""
import os
import cst
s_ = cst.sord.s_

# model dimensions
nproc2 = 2, 1, 1
shape = 301, 321, 2, 6000
delta = 0.0075, 0.0075, 0.0075, 0.002

# boundary conditions
bc1 = 0,  0, 1
bc2 = 1, -1, 1

# material properties
hourglass = 1.0, 2.0
fieldio = [
    ('=', 'rho', [], 1.0),
    ('=', 'vp',  [], 2.0),
    ('=', 'vs',  [], 1.0),
    ('=', 'gam', [], 0.0),
]

# Ricker wavelet source, 2 second period
fieldio += [
    ('=f', 'v2', s_[-1,161:-1,:,:], 1.0, 'ricker1', 2.0),
]

# mesh input files
fieldio += [
    ('=R', 'x1', s_[:,:,1,0], 'x.bin'),
    ('=R', 'x2', s_[:,:,1,0], 'y.bin'),
]

# output
for c in '12':
    fieldio += [
        ('=w', 'u' + c, s_[-1,-1,1,0], 'source-u%s.bin' % c),
        ('=w', 'u' + c, s_[1,:,1,0], 'canyon-u%s.bin' % c),
        ('=w', 'u' + c, s_[2:158,1,1,0], 'flank-u%s.bin' % c),
        ('=w', 'v' + c, s_[:,:,1,::10], 'snap-v%s.bin' % c),
        ('=w', 'u' + c, s_[:,:,1,::10], 'snap-u%s.bin' % c),
    ]

# stage job, copy mesh files, and run job
rundir = os.path.join('run', 'sim')
job = cst.sord.stage(locals())
for f in 'x.bin', 'y.bin':
    a = os.path.join('run', 'mesh', f)
    b = os.path.join('run', 'sim', f)
    os.link(a, b)
cst.sord.run(job)

