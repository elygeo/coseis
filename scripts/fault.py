#!/usr/bin/env python
"""
Fault test
"""
import sord

debug = 4
itstats = 1
np3 = 2, 3, 2
np3 = 1, 2, 1
nn = 8, 8, 9
nt = 10
dx = 100.0, 100.0, 100.0
dt = 0.008
ihypo = 1, 1, 1.5
bc1 = -1,  1, -2
bc2 =  0,  0,  0
fixhypo = -1
faultnormal = 3
vrup = -1.0

fieldio = [
    ( '=',  'rho', [],  2670.0 ),
    ( '=',  'vp',  [],  6000.0 ),
    ( '=',  'vs',  [],  3464.0 ),
    ( '=',  'gam', [],  0.02  ),
    ( '=',  'dc',  [],  0.4   ),
    ( '=',  'mud', [],  0.525 ),
    ( '=',  'mus', [],  1.0e4 ),
    ( '=c', 'mus', [],  0.677, (-601.0, -601.0, -1.0), (601.0, 601.0, 1.0) ),
    ( '=',  'tn',  [], -120e6 ),
    ( '=',  'ts',  [],   70e6 ),
    ( '=c', 'ts',  [], 81.6e6, (-401.0, -401.0, -1.0), (401.0, 401.0, 1.0) ),
]
for f in sord.fieldnames.all:
    fieldio += [( '=w', f, [], f )]

sord.run( locals() )

