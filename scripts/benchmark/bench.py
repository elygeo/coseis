#!/usr/bin/env python
"""
Benchmarks
"""
import os
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
power = range(6)     # Challenger

prm = {
    #'oplevel': 5,
    'minutes': 20,
    'oplevel': 6,
    'itstats': 9999,
    'itio': 128,
    'gridnoise': 0.1,
    'debug': 0,
    'delta': [100.0, 100.0, 100.0, 0.0075],
    'bc1': [0, 0, 0],
    'bc2': [0, 0, 0],
    'npml': 0,
    'fieldio': [
        ['=', 'rho', [], 2670.0],
        ['=', 'vp',  [], 6000.0],
        ['=', 'vs',  [], 3464.0],
        ['=', 'gam', [],    0.0],
        ['=s', 'v1', [[],[],[],1], 1.0],
        ['=s', 'v2', [[],[],[],1], 1.0],
        ['=s', 'v3', [[],[],[],1], 1.0],
    ],
}

cwd = os.getcwd()
for i in power[::-1]:
    n = 2 ** i
    prm['nproc3'] = [2, n, n]
    prm['shape'] = [points, n * points, n * points, prm['itio']]
    d = os.path.joing(cwd, 'run', 'bench%s' % i)
    os.makedirs(d)
    os.chdir(d)
    cst.sord.run(prm)

