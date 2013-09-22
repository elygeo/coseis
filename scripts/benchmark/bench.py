#!/usr/bin/env python
"""
Benchmarks
"""
import os
import cst
prm = cst.sord.parameters()
fld = cst.sord.fieldnames()

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

prm['oplevel'] = 5
prm['minutes'] = 20
prm['oplevel'] = 6
prm['itstats'] = 9999
prm['itio'] = 128
prm['gridnoise'] = 0.1
prm['debug'] = 0
prm['delta'] = [100.0, 100.0, 100.0, 0.0075]
prm['bc1'] = [0, 0, 0]
prm['bc2'] = [0, 0, 0]
prm['npml'] = 0
prm['fieldio'] = [
    fld['rho'] == 2670.0,
    fld['vp']  == 6000.0,
    fld['vs']  == 3464.0,
    fld['gam'] == 0.0,
    fld['v1'][:,:,:,1] == cst.sord.func.rand(1.0),
    fld['v2'][:,:,:,1] == cst.sord.func.rand(1.0),
    fld['v3'][:,:,:,1] == cst.sord.func.rand(1.0),
]

for i in power[::-1]:
    n = 2 ** i
    prm['nproc3'] = [2, n, n]
    prm['shape'] = [points, n * points, n * points, prm['itio']]
    d = os.path.joing('run', 'bench%s' % i)
    os.makedirs(d)
    cst.sord.run(prm)

