#!/usr/bin/env python
"""
Explosion test problem for comparison with DFM
"""

import sys
sys.path.insert( 0, '../..' )
import sord

np = 1, 2, 1
nn = 101, 101, 61
dx = 100.
dt = 0.008
nt = 200
fieldio = [
    ( '=', 'vp',  [], 6000. ),
    ( '=', 'vs',  [], 3464. ),
    ( '=', 'rho', [], 2700. ),
    ( '=', 'gam', [], 0.3   ),
]

hourglass = 1., 0.3
faultnormal = 0
rexpand = 1.06
n1expand = 20, 20, 20
n2expand = 20, 20, 20
moment1 = 1e18, 1e18, 1e18
moment2 = 0, 0, 0
tfunc = 'brune'
tsource = 0.1
xhypo = 0., 0., 0.
bc1 = 0, 0, 0
bc2 = 0, 0, 0
ihypo = 31, 31, 31

for _f in 'x1', 'x2', 'x3', 'v1', 'v2', 'v3':
    fieldio += [
        ( '=wx', _f, [], 'p1_'+_f, (   0.,3999.,0.) ),
        ( '=wx', _f, [], 'p2_'+_f, (2999.,3999.,0.) ),
        ( '=wx', _f, [], 'p3_'+_f, (3999.,3999.,0.) ),
    ]

fixhypo = -1; rsource = 100.
fixhypo = -2; rsource = 50.

sord.run( locals() )

