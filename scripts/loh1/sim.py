#!/usr/bin/env python
"""
PEER LOH.1
"""
import sord

rundir = '~/run/loh1'
np3 = 1, 16, 1
np3 = 1, 2, 1
dx = 50.0, 50.0, 50.0
dt = 0.004
L = 8000.0, 10000.0, 6000.0
T = 9.0
nn = [ int( x / dx[0] + 20.5 ) for x in L  ]
nt =   int( T / dt +  1.5 )
bc1 = -2, -2,  0
bc2 = 10, 10, 10

# source
ihypo = 1.5, 1.5,   41.5
source = 'moment'
timefunction = 'brune'
period = 0.1
source1 = 0.0, 0.0, 0.0
source2 = 0.0, 0.0, 1e18

# material
hourglass = 1.0, 2.0
l = 1.5, 1000.0 / dx[2] + 0.5
fieldio = [
    ( '=', 'rho', [], 2700.0 ),
    ( '=', 'vp',  [], 6000.0 ),
    ( '=', 'vs',  [], 3464.0 ),
    ( '=', 'gam', [],    0.0 ),
    ( '=', 'rho', [(),(),l,()], 2600.0 ),
    ( '=', 'vp',  [(),(),l,()], 4000.0 ),
    ( '=', 'vs',  [(),(),l,()], 2000.0 ),
]

# output
j = ihypo[0] + 5999.0 / dx[0]
k = ihypo[1] + 7999.0 / dx[1]
l = ihypo[2]
fieldio += [
    ( '=w', 'v1', [j,k,l,()], 'vx' ),
    ( '=w', 'v2', [j,k,l,()], 'vy' ),
    ( '=w', 'v3', [j,k,l,()], 'vz' ),
]

# run job
if __name__ == '__main__':
    sord.run( locals() )

