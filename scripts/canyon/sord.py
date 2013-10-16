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
prm['bc1'] = ['free',  'free',  '+node']
prm['bc2'] = ['+node', '-node', '+node']

# Ricker wavelet source with 2 s period.
prm['vy'] = [(s_[-1,161:,:,:], '=', 'ricker1', 1.0, 2.0)]

# mesh input
prm['x'] = (s_[:,:,0], '=<', 'x.bin')
prm['y'] = (s_[:,:,0], '=<', 'y.bin')

# velocity output
prm['vx'] =  [(s_[:,:,0,::10],  '=>', 'snap-vx.bin')]
prm['vy'] += [(s_[:,:,0,::10],  '=>', 'snap-vy.bin')]

# displacement output
prm['ux'] = [
    (s_[-1,-1,0,:],   '=>', 'source-ux.bin'),
    (s_[0,:,0,:],     '=>', 'canyon-ux.bin'),
    (s_[1:158,0,0,:], '=>', 'flank-ux.bin'),
    (s_[:,:,0,::10],  '=>', 'snap-ux.bin'),
]
prm['uy'] = [
    (s_[-1,-1,0,:],   '=>', 'source-uy.bin'),
    (s_[0,:,0,:],     '=>', 'canyon-uy.bin'),
    (s_[1:158,0,0,:], '=>', 'flank-uy.bin'),
    (s_[:,:,0,::10],  '=>', 'snap-uy.bin'),
]

# run job
cst.sord.run(prm)
