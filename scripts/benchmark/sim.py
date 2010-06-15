#!/usr/bin/env python
"""
Benchmarks
"""
import math
import cst

np3_ = (1,1,1),
np3_ = (1,1,1), (1,2,2), (1,4,4)
np3_ = (1,1,1), (1,2,2), (1,4,4), (1,8,8), (1,16,16), (1,32,32), (1,64,64)
np3_ = (1,1,1), (1,1,2)
#machine = queue = 'large'; np3_all = (1,128,128),
optimize = 'p'
optimize = 'O'
mode = 's'
mode = 'm'
oplevel = 6
oplevel = 2
npp_ = 20
npp_ = 200

nt = 16
itstats = 1
itcheck = -1
itio = nt
debug = 0
dx = 100.0, 100.0, 100.0
dt = 0.0075
bc1 = bc2 = 0, 0, 0
npml = 0
fieldio = [
    ( '=', 'rho', [], 2670.0 ),
    ( '=', 'vp',  [], 6000.0 ),
    ( '=', 'vs',  [], 3464.0 ),
    ( '=', 'gam', [],    0.0 ),
    ( '=s', 'v1', [(),(),(),1], 1.0 ),
    ( '=s', 'v2', [(),(),(),1], 1.0 ),
    ( '=s', 'v3', [(),(),(),1], 1.0 ),
]

for np3 in np3_:
    nn = np3[0] * npp_, np3[1] * npp_, np3[2] * npp_
    n  = np3[0] * np3[1] * np3[2]
    print '\nBenchmark: %s, %s, %s, %s' % ( np3, math.log(n,2), n/16, n )
    rundir = 'run/%05d' % n
    cst.sord.run( locals() )

