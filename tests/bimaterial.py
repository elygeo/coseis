#!/usr/bin/env python
"""
Bimaterial problem
"""

import sord

np3 = 1, 1, 1
np3 = 1, 2, 1
dx = 0.15
dt = 0.008
_X, _Y, _T = 400., 400., 200.
nn = int( _X / dx + 1.5 ), int( _Y / dx + 2.5 ), 2
nt = int( _T / dt + 1.5 )
ihypo = nn[0]/2, nn[1]/2, 1
fixhypo = -1
xhypo = 0., 0., -0.5*dx
trelax = 0.1
vrup = 0.5
rcrit = 1.5
faultnormal = 2	
hourglass = 1., 2.
bc1 = 10, 10, 1
bc2 = 10, 10, 1
itio = 1
itstats = 1
debug = 0

_k = ihypo[1]
fieldio = [
    ( '=', 'rho', [], 1.    ),
    ( '=', 'vp',  [], 1.732 ),
    ( '=', 'vs',  [], 1.    ),
#   ( '=', 'rho', [0,(1,_k),0,0],  1.        ),
#   ( '=', 'vp',  [0,(1,_k),0,0],  1.732     ),
#   ( '=', 'vs',  [0,(1,_k),0,0],  1.        ),
#   ( '=', 'rho', [0,(_k+1,-1),0,0], 1./1.2    ),
#   ( '=', 'vp',  [0,(_k+1,-1),0,0], 1.732/1.2 ),
#   ( '=', 'vs',  [0,(_k+1,-1),0,0], 1./1.2    ),
    ( '=', 'gam', [], 0.   ),
    ( '=', 'dc',  [], 1e8  ),
    ( '=', 'mus', [], 0.75 ),
    ( '=', 'mud', [], 0.5  ),
    ( '=', 'tn',  [], -1.  ),
    ( '=', 'ts',  [],  0.7 ),
    ( '=w', 'sl', [0,201,1,0], 'slip' ),
]

sord.run( locals() )

