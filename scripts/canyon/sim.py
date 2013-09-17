#!/usr/bin/env python
"""
Semi-cylindrical canyon with vertically incident P-wave.
"""
import cst
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
    'rho = 1.0',
    'vp  = 2.0',
    'vs  = 1.0',
    'gam = 0.0',
]

# Ricker wavelet source with 2 s period.
prm['fieldio'] += [
    'v2[-1,161:,:,:] = ricker1 1.0 2.0'
]

# mesh input
prm['fieldio'] += [
    'x1[:,:,1,0] = fill x.bin',
    'x2[:,:,1,0] = fill y.bin',
]

# output
for s in [
    'u{c}[-1,-1,1,0]   . write source-u{c}.bin',
    'u{c}[1,:,1,0]     . write canyon-u{c}.bin',
    'u{c}[2:158,1,1,0] . write flank-u{c}.bin',
    'v{c}[:,:,1,::10]  . write snap-v{c}.bin',
    'u{c}[:,:,1,::10]  . write snap-u{c}.bin',
]:
    for c in '12':
        prm['fieldio'] += [s.format(c=c)]

# run job
cst.sord.run(prm)
