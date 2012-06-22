#!/usr/bin/env python
"""
Benchmarks
"""
import cst

# MPI
power = range(7, 10) # Mira
power = range(6, 9)  # Intrepid
power = range(8)     # Vesta, Ranger
power = range(7)     # Surveyor
power = range(6)     # Challenger
power = range(1)     # Serial
points = 100

# MPI + OpenMP
power = 3, # Vesta 128 nodes, 1 ppn, 32 threads
points = 400

prm = cst.sord.parameters()
prm.oplevel = 5
prm.oplevel = 6
prm.itstats = 1
prm.itcheck = -1
prm.itio = 128
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

for i in power[::-1]:
    n = 2 ** i
    prm.nproc3 = 2, n, n
    prm.shape = points, n * points, n * points, prm.itio
    cst.sord.run(prm, name='bench%s' % i, minutes=20)

