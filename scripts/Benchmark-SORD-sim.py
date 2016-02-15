#!/usr/bin/env python
"""
Benchmarks
"""
import os
import cst.sord
s_ = cst.sord.get_slices()

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
power = range(6) # Challenger

# SORD parameters
prm = {}
prm['minutes'] = 20
prm['diffop'] = 'exac'
prm['diffop'] = 'save'
prm['itstats'] = 9999
prm['itio'] = 128
prm['gridnoise'] = 0.1
prm['vx'] = (s_[:,:,:,0], '=~', 1.0)
prm['vy'] = (s_[:,:,:,0], '=~', 1.0)
prm['vz'] = (s_[:,:,:,0], '=~', 1.0)

for i in power[::-1]:
    n = 2 ** i
    prm['nproc3'] = [2, n, n]
    prm['shape'] = [points, n * points, n * points, prm['itio']]
    d = os.path.joing('run', 'Benchmark-SORD-%s' % i)
    os.makedirs(d)
    os.chdir(d)
    cst.sord.run(prm)

