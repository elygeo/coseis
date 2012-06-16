#!/usr/bin/env python
"""
Benchmarks
"""
import cst

power = 0 # Serial
power = 9 # Mira
power = 8 # Intrepid
power = 5 # Challenger
power = 6 # Surveyor
power = 7 # Vesta, Ranger
points = 100

prm = cst.sord.parameters()
prm.oplevel = 5
prm.oplevel = 6
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

for i in range(power, -1, -1):
    n = 2 ** i
    prm.nproc3 = 1, n, n
    prm.shape = points, n * points, n * points, prm.itio
    cst.sord.run(prm, name='%s' % i, optimize='p')

