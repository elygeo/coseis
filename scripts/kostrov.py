#!/usr/bin/env python
"""
Kostrov constant rupture velocity test
"""

import sord

np3 = 1, 1, 1
nt = 400
xihypo = 60., 60., 20.
irup = 21
nn = 121, 121, 41
bc1 = 10, 10, 10
bc2 = 10, 10, 10
faultnormal = 3
vrup = 3117.7
rcrit = 1e9
trelax = 0.

fieldio = [
    ( '=',  'rho', [],  2670. ),      
    ( '=',  'vp',  [],  6000. ),      
    ( '=',  'vs',  [],  3464. ),      
    ( '=',  'gam', [],     0. ),      
    ( '=',  'mus', [],   1e9  ),
    ( '=',  'mud', [],     0. ),
    ( '=',  'dc',  [],   1e9  ),
    ( '=',  'co',  [],     0. ),
    ( '=',  'tn',  [], -100e6 ),
    ( '=',  'ts',  [],  -90e6 ),
    ( '=w', 'sl',  [ (), (), (), -1 ],         'sl'  ),
    ( '=w', 'svm', [ (), (), (), -1 ],         'svm' ),
    ( '=w', 'x1',  [ (), (), irup ,() ],         'x1'  ),
    ( '=w', 'x2',  [ (), (), irup ,() ],         'x2'  ),
    ( '=w', 'x3',  [ (), (), irup ,() ],         'x3'  ),
    ( '=w', 'v1',  [ (), (), irup, (1,-1,20) ], 'v1'  ),
    ( '=w', 'v2',  [ (), (), irup, (1,-1,20) ], 'v2'  ),
    ( '=w', 'v3',  [ (), (), irup, (1,-1,20) ], 'v3'  ),
]

sord.run( locals() )

