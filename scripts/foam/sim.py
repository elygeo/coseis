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

# weak zone thickness
weakzone_ = 0.2
weakzone_ = 0.0

# number of processors in each dimension
nproc3 = 1, 2, 1

# model dimensions
delta = 0.01, 0.01, 0.01, 0.000075
delta = 0.02, 0.02, 0.02, 0.00015
x, y, z, t = 2.8, 2.2, 2.2, 0.15
shape = (
    int( x / delta[0] + 1.5 ),
    int( y / delta[1] + 1.5 ),
    int( z / delta[2] + 1.5 ),
    int( t / delta[3] + 1.5 ),
)

# material
hourglass = 1.0, 1.0
fieldio = [
    ('=', 'rho', [], 16.0),
    ('=', 'vp',  [], 56.0),
    ('=', 'vs',  [], 30.0),
    ('=', 'gam', [], 0.5),
]

# boundary conditions
bc1 = 0, -1, -2
bc2 = 10, 10, 10

# nucleation
ihypo = 1.4 / delta[0] + 1.0, 1, 1.5
vrup = 15.0
rcrit = 0.4
trelax = 10.0 * delta[-1]

# rupture
faultnormal = 3
slipvector = 0.0, 1.0, 0.0
i = (1, ihypo[0]), (), (), 0
fieldio += [
    ('=', 'ts',  [], -730.0),
    ('=', 'tn',  [], -330.0),
    ('=', 'mus', [],  1e5),
    ('=', 'mud', [],  1e5),
    ('=', 'dc',  [],  0.001),
    ('=', 'mus', i,   2.4),
    ('=', 'mud', i,   1.85),
]

# weak zone
if weakzone_:
    i = (weakzone_ / delta[0] + 1.0), (), (), 0
    [
        ('=', 'ts',  i, -66.0),
        ('=', 'mus', i,  0.6),
        ('=', 'mud', i,  0.6),
    ]

# sensors
z = 0.03 # actual position
z = 0.02 # position used in Day and Ely (2002)
for s, x, g in [
   (1, 0.92, 0.020074),
   (2, 0.72, 0.019926),
   (3, 0.42, 0.020350),
   (4, 0.22, 0.020166),
  (15, 0.02, 0.020773),
]:
    i = x / delta[0] + 1.0, 1, z / delta[2] + 1.0, ()
    fieldio += [
        ('=w', 'a2', i, 'sensor%02d.bin' % s),
    ]
fieldio += [
    ('=w', 'u2', [1, 1, 1, ()], 'sensor16.bin'),
]

# surface output
k = ihypo[1]
l = 2, 0.8 / delta[2] + 1.0
surf_ = 1, k, l, ()
snap_ = (), k, l, (1, -1, 10)
fieldio += [
    ('=w', 'u2', surf_, 'surf.bin'),
    #('=w', 'v2', snap_, 'snap.bin'),
]

# launch SORD code
rundir = os.path.join( 'run', '%02.0f' % (weakzone_ * 100) )
cst.sord.run( locals() )

