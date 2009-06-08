#!/usr/bin/env python
"""
PEER UHS.1
"""
import sord

np3 = 1, 16, 1
np3 = 1, 2, 1
dx = 50.0, 50.0, 50.0
dt = 0.004
L = 7000.0, 9000.0, 4000.0
nn = [ int( x / dx[0] + 21.001 ) for x in L ]
nt =   int( 5.0 / dt +  1.001 )
bc1 = -2, -2,  0
bc2 = 10, 10, 10

# source
fixhypo = -1
ihypo = 0.5, 0.5,   40.5
xhypo = 0.0, 0.0, 2000.0
source = 'moment'
timefunction = 'brune'
period = 0.1
source1 = 0.0, 0.0, 0.0
source2 = 0.0, 0.0, 1e18

# material
hourglass = 1.0, 2.0
fieldio = [
    ( '=',   'rho', [], 2700.0 ),
    ( '=',   'vp',  [], 6000.0 ),
    ( '=',   'vs',  [], 3464.0 ),
    ( '=',   'gam', [],    0.0 ),
]

# output
fieldio += [
    ( '=wx', 'v1',  [], 'p1-v1', (5999., 7999., -1.) ),
    ( '=wx', 'v2',  [], 'p1-v2', (5999., 7999., -1.) ),
    ( '=wx', 'v3',  [], 'p1-v3', (5999., 7999., -1.) ),
    ( '=wx', 'v1',  [], 'p2-v1', (6001., 8001., -1.) ),
    ( '=wx', 'v2',  [], 'p2-v2', (6001., 8001., -1.) ),
    ( '=wx', 'v3',  [], 'p2-v3', (6001., 8001., -1.) ),
]

sord.run( locals() )

