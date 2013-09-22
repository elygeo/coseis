#!/usr/bin/env python
"""
Foam rubber model from:

Day, S. M., and G. P. Ely (2002),
*Effect of a shallow weak zone on fault rupture: Numerical simulation of
scale-model experiments*, Bull. Seism. Soc. Am., `92(8), 3022-3041
<http://www.bssaonline.org/cgi/content/abstract/92/8/3022>`__,
doi:10.1785/0120010273.
"""
import os
import cst
prm = cst.sord.parameters()
fld = cst.sord.fieldnames()

# parameters
weakzone = 0.2
weakzone = 0.0
x, y, z, t = 2.8, 2.2, 2.2, 0.15
dx, dy, dz, dt = [0.01, 0.01, 0.01, 0.000075]
dx, dy, dz, dt = [0.02, 0.02, 0.02, 0.00015]

# dimentions
prm['nproc3'] = [1, 2, 1]
prm['delta'] = [dx, dy, dz, dt]
prm['shape'] = [
    int(x / dx + 1.5),
    int(y / dy + 1.5),
    int(z / dz + 1.5),
    int(t / dt + 1.5),
]

# material model
prm['hourglass'] = [1.0, 1.0]
prm['fieldio'] = [
    fld['rho'] == 16.0,
    fld['vp']  == 56.0,
    fld['vs']  == 30.0,
    fld['gam'] == 0.5,
]

# boundary conditions
prm['bc1'] = [0, -1, -2]
prm['bc2'] = [10, 10, 10]

# nucleation
prm['ihypo'] = [1.4 / dx + 1.0, 1, 1.5]
prm['vrup'] = 15.0
prm['rcrit'] = 0.4
prm['trelax'] = 10.0 * dt

# rupture
j = prm['ihypo'][0]
prm['faultnormal'] = 3
prm['slipvector'] = [0.0, 1.0, 0.0]
prm['fieldio'] += [
    fld['ts'] == -730.0,
    fld['tn'] == -330.0,
    fld['mus'] == 1e5,
    fld['mud'] == 1e5,
    fld['dc'] == 0.001,
    fld['mus'][:j,:,:,0] == 2.4,
    fld['mud'][:j,:,:,0] == 1.85,
]

# weak zone
j = weakzone / dx + 1.0
if weakzone:
    prm['fieldio'] += [
        fld['ts'][j,:,:,0] == -66.0,
        fld['mus'][j,:,:,0] == 0.6,
        fld['mud'][j,:,:,0] == 0.6,
    ]

# sensors
z = 0.03
z = 0.04
for s, x, g in [
    [1, 0.92, 0.020074],
    [2, 0.72, 0.019926],
    [3, 0.42, 0.020350],
    [4, 0.22, 0.020166],
    [15, 0.02, 0.020773],
]:
    j = x / dx + 1.0
    l = z / dz + 2.0
    prm['fieldio'] += [
        fld['a2'][j,1,l,:] >> 'sensor%02d.bin' % s,
    ]
prm['fieldio'] += [
    fld['u2'][1,1,1,:] >> 'sensor16.bin'
]

# surface output
k = prm['ihypo'][1]
l = 0.8 / dz + 2.0
prm['fieldio'] += [
    fld['u2'][1,k,2:l,:] > 'off-fault.bin',
    #fld['v2'][:,k,2:l,::10] > 'xsec.bin',
]

# run SORD
w = weakzone * 100
prm['rundir'] = os.path.join('run', '%02.0f' % w)
os.makedirs(prm['rundir'])
cst.sord.run(prm)

