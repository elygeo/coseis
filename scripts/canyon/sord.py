#!/usr/bin/env python
"""
Semi-cylindrical canyon with vertically incident P-wave.
"""
import cst
s_ = cst.sord.get_slice()
prm = {}

# dimentions
prm['delta'] = [0.0075, 0.0075, 0.0075, 0.002]
prm['shape'] = [301, 321, 2, 6000]
prm['nproc3'] = [2, 1, 1]

# material model
prm['rho'] = 1.0
prm['vp']  = 2.0
prm['vs']  = 1.0
prm['gam'] = 0.0
prm['hourglass'] = [1.0, 2.0]

# boundary conditions
prm['bc1'] = [0,  0, 1]
prm['bc2'] = [1, -1, 1]

# Ricker wavelet source with 2 s period.
prm['v2'] = [(s_[-1,161:,:,:], '=', 'ricker1', 1.0, 2.0)]

# mesh input
prm['x1'] = (s_[:,:,1], '=<', 'x.bin')
prm['x2'] = (s_[:,:,1], '=<', 'y.bin')

# velocity output
prm['v1'] =  [(s_[:,:,1,::10],  '=>', 'snap-v1.bin')]
prm['v2'] += [(s_[:,:,1,::10],  '=>', 'snap-v2.bin')]

# displacement output
prm['u1'] = [
    (s_[-1,-1,1,:],   '=>', 'source-u1.bin'),
    (s_[1,:,1,:],     '=>', 'canyon-u1.bin'),
    (s_[2:158,1,1,:], '=>', 'flank-u1.bin'),
    (s_[:,:,1,::10],  '=>', 'snap-u1.bin'),
]
prm['u2'] = [
    (s_[-1,-1,1,:],   '=>', 'source-u2.bin'),
    (s_[1,:,1,:],     '=>', 'canyon-u2.bin'),
    (s_[2:158,1,1,:], '=>', 'flank-u2.bin'),
    (s_[:,:,1,::10],  '=>', 'snap-u2.bin'),
]

# run job
cst.sord.run(prm)
