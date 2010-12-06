#!/usr/bin/env python
"""
Benchmarks
"""
import math
import cst

np3_ = (1,1,1),
np3_ = (1,1,1), (1,2,2), (1,4,4)
np3_ = (1,1,1), (1,2,2), (1,4,4), (1,8,8), (1,16,16), (1,32,32), (1,64,64)
np3_ = (1,128,128),
np3_ = (1,1,1), (1,1,2)
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
itio = 16
debug = 0
delta = 100.0, 100.0, 100.0, 0.0075
bc1 = bc2 = 0, 0, 0
npml = 0
fieldio = [
    ('=', 'rho', [], 2670.0),
    ('=', 'vp',  [], 6000.0),
    ('=', 'vs',  [], 3464.0),
    ('=', 'gam', [],    0.0),
    ('=s', 'v1', [(),(),(),1], 1.0),
    ('=s', 'v2', [(),(),(),1], 1.0),
    ('=s', 'v3', [(),(),(),1], 1.0),
]

for nproc3 in np3_:
    shape = nproc3[0] * npp_, nproc3[1] * npp_, nproc3[2] * npp_, itio
    n = nproc3[0] * nproc3[1] * nproc3[2]
    print '\nBenchmark: %s, %s, %s, %s' % (nproc3, math.log(n,2), n / 16, n)
    rundir = 'run/%05d' % n
    cst.sord.run( locals() )

