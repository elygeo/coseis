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

# source
o = 31
o = 31.5
ihypo = o, o, o
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
j = o + 2999.0 / dx[0]
k = o + 3999.0 / dx[1]
for f in 'x1', 'x2', 'x3', 'v1', 'v2', 'v3':
    fieldio += [
        ( '=w', f, [o, k, o, ()], 'p1_' + f ),
        ( '=w', f, [j, k, o, ()], 'p2_' + f ),
        ( '=w', f, [k, k, o, ()], 'p3_' + f ),
    ]

sord.run( locals() )

