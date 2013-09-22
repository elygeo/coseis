#!/usr/bin/env python
"""
Semi-cylindrical canyon with vertically incident P-wave.
"""
import cst
prm = cst.sord.parameters()
fld = cst.sord.fieldnames()

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
    fld['rho'] == 1.0,
    fld['vp']  == 2.0,
    fld['vs']  == 1.0,
    fld['gam'] == 0.0,
]

# Ricker wavelet source with 2 s period.
prm['fieldio'] += [
    fld['v2'][-1,161:,:,:] == cst.sord.func.ricker1(1.0, 2.0),
]

# mesh input
prm['fieldio'] += [
    fld['x1'][:,:,1,0] << 'x.bin',
    fld['x2'][:,:,1,0] << 'y.bin',
]

# output
for i in '12':
    prm['fieldio'] += [
        fld['u'+i][-1,-1,1,0]   >> 'source-u%s.bin' % i,
        fld['u'+i][1,:,1,0]     >> 'canyon-u%s.bin' % i,
        fld['u'+i][2:158,1,1,0] >> 'flank-u%s.bin' % i,
        fld['u'+i][:,:,1,::10]  >> 'snap-u%s.bin' % i,
        fld['v'+i][:,:,1,::10]  >> 'snap-v%s.bin' % i,
    ]

# run job
cst.sord.run(prm)
