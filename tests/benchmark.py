#!/usr/bin/env python
"""
Benchmarks
"""

import sord, math

_np3 = [ (1,1,1) ]
_np3 = [ (1,1,1), (1,2,2), (1,4,4), (1,8,8), (1,16,16), (1,32,32), (1,64,64) ]
_np3 = [ (1,1,1), (1,2,2), (1,4,4) ]
_np3 = [ (1,1,1), (1,1,2) ]
#machine = 'tacc-ranger'; queue = 'large'; _np3 = [ (1,128,96), (1,128,128) ]
optimize = 'O'
optimize = 'p'
mode = 's'
mode = 'm'
_n = 20
_n = 200
nt = 8
nt = 16
itstats = 2
itstats = 1
oplevel = 2
oplevel = 6

itcheck = -1
itio = nt
debug = 0
dx = 100.
dt = 0.0075
bc1 = bc2 = 0, 0, 0
npml = 0
hourglass = 1., 1.
faultnormal = 0
fieldio = [
    ( '=', 'rho', [],     2670.0 ),      
    ( '=', 'vp',  [],     6000.0 ),      
    ( '=', 'vs',  [],     3464.0 ),      
    ( '=', 'gam', [],        0.0 ),      
    ( '=s', 'v1', [0,0,0,1], 1.0 ),
    ( '=s', 'v2', [0,0,0,1], 1.0 ),
    ( '=s', 'v3', [0,0,0,1], 1.0 ),
]

for np3 in _np3:
    nn = [ _n * _np for _np in np3 ]
    _np = np3[0] * np3[1] * np3[2]
    print '\nBenchmark: %s, %s, %s, %s' % ( np3, math.log(_np,4), _np/16, _np )
    sord.run( locals() )

