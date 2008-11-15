#!/usr/bin/env python
"""
Miniature point source test
"""

import sord

debug = 3
np = 1, 1, 1
nn = 2, 2, 2
nt = 2
dx = 100.0
dt = 0.0075
bc1 = 0, 0, 0
bc2 = 0, 0, 0
hourglass = 0., 0.
faultnormal = 0
moment1 = 1e16, 1e16, 1e16
moment2 = 0.0, 0.0, 0.0
ihypo = 1, 1, 1
fixhypo = 2
rsource = 50.0

fieldio = [
    ( '=', 'rho', [], 2670.0 ),      
    ( '=', 'vp',  [], 6000.0 ),      
    ( '=', 'vs',  [], 3464.0 ),      
    ( '=', 'gam', [],    0.0 ),      
]
for _f in sord.fieldnames.volume:
    fieldio += [ ( '=w', _f, [], _f ) ]

sord.run( locals() )

