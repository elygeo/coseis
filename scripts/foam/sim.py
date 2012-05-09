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
s_ = cst.sord.s_

# weak zone thickness
weakzone = 0.2
weakzone = 0.0

# number of processors in each dimension
prm.nproc3 = 1, 2, 1

# model dimensions
x, y, z, t = 2.8, 2.2, 2.2, 0.15
prm.delta = 0.01, 0.01, 0.01, 0.000075
prm.delta = 0.02, 0.02, 0.02, 0.00015
prm.shape = (
    int(x / prm.delta[0] + 1.5),
    int(y / prm.delta[1] + 1.5),
    int(z / prm.delta[2] + 1.5),
    int(t / prm.delta[3] + 1.5),
)

# material
prm.hourglass = 1.0, 1.0
prm.fieldio = [
    ('=', 'rho', [], 16.0),
    ('=', 'vp',  [], 56.0),
    ('=', 'vs',  [], 30.0),
    ('=', 'gam', [], 0.5),
]

# boundary conditions
prm.bc1 = 0, -1, -2
prm.bc2 = 10, 10, 10

# nucleation
prm.ihypo = 1.4 / prm.delta[0] + 1.0, 1, 1.5
prm.vrup = 15.0
prm.rcrit = 0.4
prm.trelax = 10.0 * prm.delta[-1]

# rupture
j = prm.ihypo[0]
prm.faultnormal = 3
prm.slipvector = 0.0, 1.0, 0.0
prm.fieldio += [
    ('=', 'ts',  [], -730.0),
    ('=', 'tn',  [], -330.0),
    ('=', 'mus', [],  1e5),
    ('=', 'mud', [],  1e5),
    ('=', 'dc',  [],  0.001),
    ('=', 'mus', s_[:j,:,:,0], 2.4),
    ('=', 'mud', s_[:j,:,:,0], 1.85),
]

# weak zone
if weakzone:
    j = weakzone / prm.delta[0] + 1.0
    prm.fieldio += [
        ('=', 'ts',  s_[:j,:,:,0], -66.0),
        ('=', 'mus', s_[:j,:,:,0],  0.6),
        ('=', 'mud', s_[:j,:,:,0],  0.6),
    ]

# sensors
z = 0.03
z = 0.04
for s, x, g in [
   (1, 0.92, 0.020074),
   (2, 0.72, 0.019926),
   (3, 0.42, 0.020350),
   (4, 0.22, 0.020166),
  (15, 0.02, 0.020773),
]:
    j = x / prm.delta[0] + 1.0
    l = z / prm.delta[2] + 2.0
    prm.fieldio += [
        ('=w', 'a2', s_[j,1,l,:], 'sensor%02d.bin' % s),
    ]
prm.fieldio += [
    ('=w', 'u2', s_[1,1,1,:], 'sensor16.bin'),
]

# surface output
k = prm.ihypo[1]
l = 0.8 / prm.delta[2] + 2.0
prm.fieldio += [
    ('=w', 'u2', s_[1,k,2:l,:], 'off-fault.bin'),
    #('=w', 'v2', s_[:,k,2:l.::10], 'xsec.bin'),
]

# launch SORD code
cst.sord.run(prm,
    rundir = os.path.join('run', '%02.0f' % (weakzone * 100))
)

