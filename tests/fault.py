#!/usr/bin/env python
"""
Fault test
"""

import sord

debug = 0
np    =  2,  3,  2
np    =  1,  1,  1
nn    =  8,  8,  9
ihypo = -1, -1, -2
bc1   =  0,  0,  0
bc2   = -1,  1, -2
fixhypo = -1
itstats = 1
nt = 10
dx = 100.0
dt = 0.008
hourglass = 1.0, 1.0
faultnormal = 3
vrup = -1.

fieldio = [
    ( '=',  'rho', [],  2670.0 ),
    ( '=',  'vp',  [],  6000.0 ),
    ( '=',  'vs',  [],  3464.0 ),
    ( '=',  'gam', [],   0.02  ),
    ( '=',  'dc',  [],   0.4   ),
    ( '=',  'mud', [],   0.525 ),
    ( '=',  'mus', [],   1.0e4 ),
    ( '=c', 'mus', [],   0.677, (-601., -601., -1.), (601., 601., 1.) ),
    ( '=',  'tn',  [],  -120e6 ),
    ( '=',  'ts',  [],    70e6 ),
    ( '=c', 'ts',  [],  81.6e6, (-401., -401., -1.), (401., 401., 1.) ),
]
for _f in sord.fieldnames.all:
    fieldio += [ ( '=w', _f, [], _f ), ]

sord.run( locals() )

