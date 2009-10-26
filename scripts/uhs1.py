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
ihypo = 0.5, 0.5, 40.5
source = 'moment'
timefunction = 'brune'
period = 0.1
source1 = 0.0, 0.0, 0.0
source2 = 0.0, 0.0, 1e18

# material
hourglass = 1.0, 2.0
fieldio = [
    ( '=', 'rho', [], 2700.0 ),
    ( '=', 'vp',  [], 6000.0 ),
    ( '=', 'vs',  [], 3464.0 ),
    ( '=', 'gam', [],    0.0 ),
]

# output
j = ihypo[0] + 5999.0 / dx[0]
k = ihypo[1] + 7999.0 / dx[0]
k = ihypo[2]
fieldio += [
    ( '=w', 'v1', [j,k,l,()], 'p1-v1' ),
    ( '=w', 'v2', [j,k,l,()], 'p1-v2' ),
    ( '=w', 'v3', [j,k,l,()], 'p1-v3' ),
]

sord.run( locals() )

