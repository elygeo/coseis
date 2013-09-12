#!/usr/bin/env python
"""
Semi-cylindrical canyon with vertically incident P-wave.
"""
import cst
s_ = cst.sord.s_
prm = {}

# dimentions
prm['nproc3'] = [2, 1, 1]
prm['shape'] = [301, 321, 2, 6000]
prm['delta'] = [0.0075, 0.0075, 0.0075, 0.002]

# boundary conditions
prm['bc1'] = [0,  0, 1]
prm['bc2'] = [1, -1, 1]

# material model
prm['hourglass'] = [1.0, 2.0]
prm['fieldio'] = [
    ['=', 'rho', [], 1.0],
    ['=', 'vp',  [], 2.0],
    ['=', 'vs',  [], 1.0],
    ['=', 'gam', [], 0.0],
]

# Ricker wavelet source with 2 s period.
prm['fieldio'] += [['=f', 'v2', s_[-1,161:,:,:], 1.0, 'ricker1', 2.0]]

# mesh input
prm['fieldio'] += [
    ['=R', 'x1', s_[:,:,1,0], 'x.bin'],
    ['=R', 'x2', s_[:,:,1,0], 'y.bin'],
]

# output
for c in '12':
    prm['fieldio'] += [
        ['=w', 'u' + c, s_[-1,-1,1,0],   'source-u%s.bin' % c],
        ['=w', 'u' + c, s_[1,:,1,0],     'canyon-u%s.bin' % c],
        ['=w', 'u' + c, s_[2:158,1,1,0], 'flank-u%s.bin' % c],
        ['=w', 'v' + c, s_[:,:,1,::10],  'snap-v%s.bin' % c],
        ['=w', 'u' + c, s_[:,:,1,::10],  'snap-u%s.bin' % c],
    ]

# run job
cst.sord.run(prm)
