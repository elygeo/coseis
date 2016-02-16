#!/usr/bin/env python
"""
Semi-cylindrical canyon with vertically incident P-wave.
"""
import os
from cst import sord

p = os.path.join('run', 'Canyon')
os.chdir(p)

sord.run({

# dimentions
'delta': [0.0075, 0.0075, 0.0075, 0.002],
'shape': [301, 321, 2, 6000],
'nproc3': [2, 1, 1],

# material model
'rho': 1.0,
'vp': 2.0,
'vs': 1.0,
'gam': 0.0,
'hourglass': [1.0, 2.0],

# boundary conditions
'bc1': ['free',  'free',  '+node'],
'bc2': ['+node', '-node', '+node'],

# mesh input
'x' = [('[:,:,0]', '=<', 'x.bin')],
'y' = [('[:,:,0]', '=<', 'y.bin')],

# Ricker wavelet source with 2 s period.
'vy': [
    ('[-1,161:,:,:]', '=', 'ricker1', 1.0, 2.0),
    ('[:,:,0,::10]', '=>', 'snap-vy.bin'),
],

# velocity output
'vx': [
    ('[:,:,0,::10]', '=>', 'snap-vx.bin')
],

# displacement output
'ux': [
    ('[-1,-1,0,:]',   '=>', 'source-ux.bin'),
    ('[0,:,0,:]',     '=>', 'canyon-ux.bin'),
    ('[1:158,0,0,:]', '=>', 'flank-ux.bin'),
    ('[:,:,0,::10]',  '=>', 'snap-ux.bin'),
],
'uy': [
    ('[-1,-1,0,:]',   '=>', 'source-uy.bin'),
    ('[0,:,0,:]',     '=>', 'canyon-uy.bin'),
    ('[1:158,0,0,:]', '=>', 'flank-uy.bin'),
    ('[:,:,0,::10]',  '=>', 'snap-uy.bin'),
],

})

