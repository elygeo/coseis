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
prm = {}

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
    'rho = 16.0',
    'vp  = 56.0',
    'vs  = 30.0',
    'gam = 0.5',
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
    'ts  = -730.0',
    'tn  = -330.0',
    'mus = 1e5',
    'mud = 1e5',
    'dc  = 0.001',
    'mus[:{},:,:,0] = 2.4'.format(j),
    'mud[:{},:,:,0] = 1.85'.format(j),
]

# weak zone
j = weakzone / dx + 1.0
if weakzone:
    prm['fieldio'] += [
        'ts[{},:,:,0], = -66.0'.format(j),
        'mus[{},:,:,0], =  0.6'.format(j),
        'mud[{},:,:,0], =  0.6'.format(j),
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
        'a2[{},1,{},:] write sensor{:02d}.bin'.format(j, l, s),
    ]
prm['fieldio'] += [
    'u2[1,1,1,:] write sensor16.bin'
]

# surface output
k = prm['ihypo'][1]
l = 0.8 / dz + 2.0
prm['fieldio'] += [
    'u2[1,{},2:{},:] write off-fault.bin'.format(k, l),
    #'v2[:,{},2:{},::10] write xsec.bin'.format(k, l),
]

# run SORD
prm['rundir'] = os.path.join('run', '{:02.0f}'.format(weakzone * 100))
os.makedirs(prm['rundir'])
cst.sord.run(prm)

