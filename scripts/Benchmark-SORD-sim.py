#!/usr/bin/env python
import os
import cst.sord

# MPI
power = range(7, 10)  # Mira
power = range(6, 9)   # Intrepid
power = range(8)      # Vesta, Ranger
power = range(7)      # Surveyor
power = range(6)      # Challenger
power = range(1)      # Serial
points = 100

# MPI + OpenMP
power = [3]  # Vesta 128 nodes, 1 ppn, 32 threads
points = 400
power = range(6)  # Challenger

prm = {
    'minutes': 20,
    'itstats': 9999,
    'itio': 128,
    'gridnoise': 0.1,
    'vx': ([[], [], [], 0], '=~', 1.0),
    'vy': ([[], [], [], 0], '=~', 1.0),
    'vz': ([[], [], [], 0], '=~', 1.0),
}

cwd = os.getcwd()

for i in power[::-1]:
    n = 2 ** i
    prm['nproc3'] = [2, n, n]
    prm['shape'] = [points, n * points, n * points, prm['itio']]
    d = 'repo/Benchmark-SORD-%s' % i
    os.mkdir(d)
    os.chdir(d)
    cst.sord.run(prm)
    os.chdir(cwd)
