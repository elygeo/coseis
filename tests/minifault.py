#!/usr/bin/env python
"""
Mini fault test
"""

import sord

debug = 4
np    =  2,  3,  2
nn    =  8,  8,  9
ihypo = -1, -1, -2
bc1   =  0,  0,  0
bc2   = -1,  1, -2
fixhypo = -1
nt = 2
dx = 100
dt = 0.008
hourglass = 1., 1.
faultnormal = 3
vrup = -1.

fieldio = [
    ( '=',  'vp',  [],   6000. ),
    ( '=',  'vs',  [],   3464. ),
    ( '=',  'rho', [],   2670. ),
    ( '=',  'gam', [],   0.1   ),
    ( '=',  'dc',  [],   0.4   ),
    ( '=',  'mud', [],   0.525 ),
    ( '=',  'mus', [],   1.0e4 ),
    ( '=c', 'mus', [],   0.677, (-601.,-601.,-1.), (601.,601.,1.) ),
    ( '=',  'tn',  [],  -120e6 ),
    ( '=',  'ts',  [],   -70e6 ),
    ( '=c', 'ts',  [], -81.6e6, (-401.,-401.,-1.), (401.,401.,1.) ),
]
#for _f in sord.fieldnames.all:
#    fieldio += [ ( '=w', _f, [], _f ), ]

sord.run( locals() )

