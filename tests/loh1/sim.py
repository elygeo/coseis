#!/usr/bin/env python
"""
PEER LOH.1
"""

import sord

np3 = 1, 2, 1
np3 = 1, 1, 1
np3 = 1, 16, 1
dx = 50.
dt = 0.004
_T = 9.
_ell  = 7000., 9000., 4000.
xhypo =    0.,    0., 2000.
nt    =   int( _T / dt +  1.5 )
nn    = [ int( _x / dx + 21.5 ) for _x in _ell  ]
ihypo = [ int( _x / dx +  1.5 ) for _x in xhypo ]
_reg  = 2
fixhypo = -_reg
bc1 = -_reg, -_reg,  0
bc2 =    10,    10, 10
tfunc = 'brune'
rfunc = 'point'
tsource = 0.1
rsource = dx / _reg
moment1 = 0., 0., 0.
moment2 = 0., 0., 1e18
faultnormal = 0
hourglass = 1., 2.

_l = 1, int( 1000. / dx + 1.5 )
fieldio = [
    ( '=',   'rho', [], 2700. ),
    ( '=',   'vp',  [], 6000. ),
    ( '=',   'vs',  [], 3464. ),
    ( '=',   'gam', [], 0.0   ),
    ( '=',   'rho', [0,0,_l,0], 2600. ),
    ( '=',   'vp',  [0,0,_l,0], 4000. ),
    ( '=',   'vs',  [0,0,_l,0], 2000. ),
    ( '=wx', 'v1',  [], 'v1', (5999., 7999., -1.) ),
    ( '=wx', 'v2',  [], 'v2', (5999., 7999., -1.) ),
    ( '=wx', 'v3',  [], 'v3', (5999., 7999., -1.) ),
]

sord.run( locals() )

