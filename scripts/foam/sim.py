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
s_ = cst.sord.s_

# parameters
weakzone = 0.2
weakzone = 0.0
x, y, z, t = 2.8, 2.2, 2.2, 0.15
dx, dy, dz, dt = [0.01, 0.01, 0.01, 0.000075]
dx, dy, dz, dt = [0.02, 0.02, 0.02, 0.00015]

prm = {

    # dimentions
    'nproc3': [1, 2, 1],
    'delta': [dx, dy, dz, dt],
    'shape': [
        int(x / dx + 1.5),
        int(y / dy + 1.5),
        int(z / dz + 1.5),
        int(t / dt + 1.5),
    ],

    # material
    'hourglass': [1.0, 1.0],
    'fieldio': [
        ['=', 'rho', [], 16.0],
        ['=', 'vp',  [], 56.0],
        ['=', 'vs',  [], 30.0],
        ['=', 'gam', [], 0.5],
    ],

    # boundary conditions
    'bc1': [0, -1, -2],
    'bc2': [10, 10, 10],

    # rupture
    'faultnormal': 3,
    'slipvector': [0.0, 1.0, 0.0],
    'ihypo': [1.4 / dx + 1.0, 1, 1.5],
    'vrup': 15.0,
    'rcrit': 0.4,
    'trelax': 10.0 * dt,
}

# rupture
j = prm['ihypo'][0]
prm['fieldio'] += [
    ['=', 'ts',  [], -730.0],
    ['=', 'tn',  [], -330.0],
    ['=', 'mus', [],  1e5],
    ['=', 'mud', [],  1e5],
    ['=', 'dc',  [],  0.001],
    ['=', 'mus', s_[:j,:,:,0], 2.4],
    ['=', 'mud', s_[:j,:,:,0], 1.85],
]

# weak zone
if weakzone:
    j = weakzone / dx + 1.0
    prm['fieldio'] += [
        ['=', 'ts',  s_[:j,:,:,0], -66.0],
        ['=', 'mus', s_[:j,:,:,0],  0.6],
        ['=', 'mud', s_[:j,:,:,0],  0.6],
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
        ['=w', 'a2', s_[j,1,l,:], 'sensor%02d.bin' % s],
    ]
prm['fieldio'] += [
    ['=w', 'u2', s_[1,1,1,:], 'sensor16.bin'],
]

# surface output
k = prm['ihypo'][1]
l = 0.8 / prm['delta'][2] + 2.0
prm['fieldio'] += [
    ['=w', 'u2', s_[1,k,2:l,:], 'off-fault.bin'],
    #['=w', 'v2', s_[:,k,2:l.::10], 'xsec.bin'],
]

# run SORD
d = os.path.join('run', '%02.0f' % (weakzone * 100))
os.makedirs(d)
os.chdir(d)
cst.sord.run(prm)

