#!/usr/bin/env python
"""
Benchmarks
"""
import math
import cst

nproc3 = (1,1,1),
nproc3 = (1,1,1), (1,2,2), (1,4,4)
nproc3 = (1,1,1), (1,2,2), (1,4,4), (1,8,8), (1,16,16), (1,32,32), (1,64,64)
nproc3 = (1,1,1), (1,1,2)
nproc3 = (1,16,128),
nproc3 = (8,16,16),
npp = 20
npp = 200
npp = 100

prm = cst.sord.parameters()
prm.oplevel = 6
prm.oplevel = 2
prm.itstats = 1
prm.itcheck = -1
prm.itio = 16
prm.debug = 0
prm.delta = 100.0, 100.0, 100.0, 0.0075
prm.bc1 = prm.bc2 = 0, 0, 0
prm.npml = 0
prm.fieldio = [
    ('=', 'rho', [], 2670.0),
    ('=', 'vp',  [], 6000.0),
    ('=', 'vs',  [], 3464.0),
    ('=', 'gam', [],    0.0),
    ('=s', 'v1', [(),(),(),1], 1.0),
    ('=s', 'v2', [(),(),(),1], 1.0),
    ('=s', 'v3', [(),(),(),1], 1.0),
]

for np in nproc3:
    prm.nproc3 = np
    prm.shape = np[0] * npp, np[1] * npp, np[2] * npp, prm.itio
    n = np[0] * np[1] * np[2]
    print '\nBenchmark: %s, %s, %s, %s' % (np, math.log(n,2), n / 16, n)
    cst.sord.run(
        prm,
        rundir = 'run/%05d' % n,
        optimize = 'O',
        #optimize = 'p',
        mode = 'm',
    )

