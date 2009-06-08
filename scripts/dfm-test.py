#!/usr/bin/env python
"""
Explosion test problem for comparison with DFM
"""
import sord

np3 = 1, 2, 1
nn = 101, 101, 61
dx = 100.0, 100.0, 100.0
nt = 200
dt = 0.008
rexpand = 1.06
n1expand = 20, 20, 20
n2expand = 20, 20, 20
fixhypo = -1

# source
ihypo = 31, 31, 31
ihypo = 31.5, 31.5, 31.5
source = 'moment'
source1 = 1e18, 1e18, 1e18
source2 =  0.0,  0.0,  0.0
timefunction = 'brune'
period = 0.1

# material
hourglass = 1.0, 0.3
fieldio = [
    ( '=', 'rho', [], 2700.0 ),
    ( '=', 'vp',  [], 6000.0 ),
    ( '=', 'vs',  [], 3464.0 ),
    ( '=', 'gam', [],    0.3 ),
]

# output
for f in 'x1', 'x2', 'x3', 'v1', 'v2', 'v3':
    fieldio += [
        ( '=wx', f, [], 'p1_'+f, (   0., 3999., -1.) ),
        ( '=wx', f, [], 'p2_'+f, (2999., 3999., -1.) ),
        ( '=wx', f, [], 'p3_'+f, (3999., 3999., -1.) ),
    ]

sord.run( locals() )

