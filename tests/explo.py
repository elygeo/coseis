#!/usr/bin/env python
"""
Explosion test problem
"""

import sord

np = 1, 2, 1
nn = 71, 71, 61
dx = 100.
dt = 0.008
nt = 200
nt = 10
fieldio = [
    ( '=', 'rho', [], 2670.0 ),
    ( '=', 'vp',  [], 6000.0 ),
    ( '=', 'vs',  [], 3464.0 ),
    ( '=', 'gam', [],    0.0 ),
]
hourglass = 1.0, 1.0
faultnormal = 0
rexpand = 1.06
n1expand =  0,  0,  0
n2expand = 20, 20, 20
moment1 = 1e18, 1e18, 1e18
moment2 = 0, 0, 0
tfunc = 'brune'
tsource = 0.1
xhypo = 0.0, 0.0, 0.0
bc2 = 0, 0, 0

for _f in 'x1', 'x2', 'x3', 'v1', 'v2', 'v3':
    fieldio += [
        ( '=wx', _f, [], 'p1_'+_f, (   0., 3999., 0.) ),
        ( '=wx', _f, [], 'p2_'+_f, (2999., 3999., 0.) ),
        ( '=wx', _f, [], 'p3_'+_f, (3999., 3999., 0.) ),
    ]

if 1:
    fixhypo = -2
    rsource = 50.0
    ihypo = 1, 1, 1
    bc1   = 2, 2, 2
else:
    fixhypo = -1
    rsource = 100.0
    ihypo = 2, 2, 2
    bc1   = 1, 1, 1

sord.run( locals() )

