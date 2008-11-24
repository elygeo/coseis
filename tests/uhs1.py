#!/usr/bin/env python
"""
PEER UHS.1
"""

import sord

np3 = 1, 16, 1
np3 = 1, 2, 1
dx = 50.
dt = 0.004
_ell  = 7000., 9000., 4000.
xhypo =    0.,    0., 20000
nn    = [ int( _x / dx + 21.5 ) for _x in _ell  ]
ihypo = [ int( _x / dx +  1.5 ) for _x in xhypo ]
nt    =   int( 5. / dt +  1.5 )
fixhypo = -2
bc1 = -2, -2,  0
bc2 = 10, 10, 10
tfunc = 'brune'
rfunc = 'point'
tsource = 0.1
rsource = dx
moment1 = 0., 0., 0.
moment2 = 0., 0., 1e18
faultnormal = 0
hourglass = 1., 2.

fieldio = [
    ( '=',   'rho', [], 2700. ),
    ( '=',   'vp',  [], 6000. ),
    ( '=',   'vs',  [], 3464. ),
    ( '=',   'gam', [], 0.    ),
    ( '=wx', 'v1',  [], 'p1-v1', (5999., 7999., -1.) ),
    ( '=wx', 'v2',  [], 'p1-v2', (5999., 7999., -1.) ),
    ( '=wx', 'v3',  [], 'p1-v3', (5999., 7999., -1.) ),
    ( '=wx', 'v1',  [], 'p2-v1', (6001., 8001., -1.) ),
    ( '=wx', 'v2',  [], 'p2-v2', (6001., 8001., -1.) ),
    ( '=wx', 'v3',  [], 'p2-v3', (6001., 8001., -1.) ),
]

sord.run( locals() )

