#!/usr/bin/env python
"""
Wnechuan earthquake
"""

import sord

_L = 400., 300., 60.,
_T = 180.
dx = 100.
dt = dx / 12500.
nt = int( _T / dt + 1.5 )
nn = [ int( _X / dx + 1.5 ), for x in _L ]
faultnormal = 0
hourglass = 1., 1.
bc1     = 10, 10, 10
bc2     = 10, 10, 0
fixhypo = -2

# Velocity model
fieldio = [
    ( '=',  'rho', [], 2670. ),
    ( '=',  'gam', [], 0.2   ),
for _depth, _vp, _vs in [
    (  0., 5.8, 3.37 ),
    ( 10., 6.2, 3.60 ),
    ( 16., 6.6, 3.84 ),
    ( 24., 7.0, 3.94 ),
    ( 33., 7.8, 4.38 ),
]
    _i = int( _depth + 1.5 )
    fieldio += [
        ( '=', 'vp', [0,0,(_i,-1),0], _vp ),
        ( '=', 'vs', [0,0,(_i,-1),0], _vs ),
    ]

sord.run( locals() )

