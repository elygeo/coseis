#!/usr/bin/env python
"""
Benchmarks
"""

import sord, numpy

dx = 100.
dt = 0.0075
faultnormal = 0
debug = 0
bc1 = bc2 = 0, 0, 0
hourglass = 1., 1.
oplevel = 2
npml = 0
itstats = 1
fieldio = [
    ( '=', 'rho', [],     2670.0 ),      
    ( '=', 'vp',  [],     6000.0 ),      
    ( '=', 'vs',  [],     3464.0 ),      
    ( '=', 'gam', [],        0.0 ),      
    ( '=s', 'v1', [0,0,0,1], 1.0 ),
    ( '=s', 'v2', [0,0,0,1], 1.0 ),
    ( '=s', 'v3', [0,0,0,1], 1.0 ),
]

nt = 4

_n = 4
_n = 32
_n = 128
_n = 64
_n = 96

_np = [
    ( 1,   1,   1 ),
    ( 1,   2,   2 ),
    ( 1,   4,   4 ),
    ( 1,   8,   8 ),
    ( 1,  16,  16 ),
    ( 1,  32,  32 ),
    ( 1,  64,  64 ),
    ( 1, 128,  96 ),
#   ( 1, 128, 128 ),
]

_np = [
#   ( 1,  1,  1 ),
    ( 1,  1,  2 ),
]

#for np in _np:
#    _np = numpy.prod( np )
#    print numpy.log2(_np), _np / 16, _np

for np in _np:
    nn = [ _n * _p for _p in np ]
    sord.run( locals() )

