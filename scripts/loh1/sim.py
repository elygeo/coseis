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
xhypo = 0.0, 0.0, 2000.0
fixhypo = -1
src_type = 'moment'
src_function = 'brune'
src_period = 0.1
src_w1 = 0.0, 0.0, 0.0
src_w2 = 0.0, 0.0, 1e18

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
fieldio += [
    ( '=wx', 'v1',  [], 'vx', (5999., 7999., -1.) ),
    ( '=wx', 'v2',  [], 'vy', (5999., 7999., -1.) ),
    ( '=wx', 'v3',  [], 'vz', (5999., 7999., -1.) ),
]

# run job
if __name__ == '__main__':
    sord.run( locals() )

