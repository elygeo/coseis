#!/usr/bin/env python3
"""
SCEC Code Validation Workshop, Test Problem Version 3
"""
import os
import cst.sord

s_ = cst.sord.get_slices()
prm = {}

# list of runs:
# column 1 is dx, the spatial step size
# column 2 is nproc3, the number of processors in each dimension
runs = [
    [500.0, [1,  4,  4]],
    [300.0, [1,  4,  4]],
    [250.0, [1,  4,  4]],
    [150.0, [1,  4,  4]],
    [100.0, [1,  4,  4]],
    [75.0,  [1,  4,  4]],
    [50.0,  [1,  4,  8]],
    [30.0,  [1,  8,  8]],
    [25.0,  [1,  8, 16]],
    [15.0,  [1, 16, 16]],
    [10.0,  [4, 16, 16]],
]
runs = [
    [500.0, [1, 1, 1]],
    [300.0, [1, 1, 1]],
    [250.0, [1, 1, 1]],
    [150.0, [1, 1, 1]],
    [100.0, [1, 1, 1]],
]
runs = [[50.0,  [1, 1, 1]]]
runs = [[150.0, [1, 1, 2]]]
runs = [[300.0, [1, 1, 1]]]

# boundary conditions:
prm['bc1'] = ['pml', 'pml', 'pml']
prm['bc2'] = ['-node', '+node', '-cell']

# loop over multiple runs
cwd = os.getcwd()
for dx, np in runs:

    # dimensions
    dt = dx / 12500.0
    nx = int(16500.0 / dx + 21.5)
    ny = int(9000.0 / dx + 21.5)
    nz = int(6000.0 / dx + 20.5)
    nt = int(12.0 / dt + 1.5)
    prm['shape'] = [nx, ny, nz, nt]
    prm['delta'] = [dx, dx, dx, dt]
    prm['nproc3'] = np

    # material properties
    prm['rho'] = [2670.0]
    prm['vp'] = [6000.0]
    prm['vs'] = [3464.0]
    prm['hourglass'] = [1.0, 2.0]

    # fault properties
    prm['faultnormal'] = '+z'
    prm['hypocenter'] = [-1.0, -1.0, -1.5]
    prm['dc'] = [0.4]
    prm['mud'] = [0.525]
    prm['tn'] = [-120.0e+6]

    # static friction for slipping patch
    j = s_[-int(15000.0 / dx + 0.5):]
    k = s_[-int(7500.0 / dx + 0.5):]
    l = s_[:]
    prm['mus'] = [10000.0, ([j, k, l], '=', 0.677)]

    # viscosity lower in slipping patch
    j = s_[-int(15000.0 / dx + 0.5):]
    k = s_[-int(7500.0 / dx + 0.5):]
    l = s_[-int(3000.0 / dx + 0.5):]
    prm['gam'] = [0.2, ([j, k, l], '=', 0.02)]

    # nucleation patch
    i0 = s_[-int(1500.0 / dx + 0.5):]
    i1 = s_[-int(1500.0 / dx + 1.5):]
    prm['ts'] = [
        70.0e+6,
        ([i1, i1], '=', 72.9e+6),
        ([i0, i1], '=', 75.8e+6),
        ([i1, i0], '=', 75.8e+6),
    ]

    # fault plane output
    prm['x'] = ([j, k, -2], '>', 'x.bin')
    prm['y'] = ([j, k, -2], '>', 'y.bin')
    prm['psv'] = ([j, k, -1], '>', 'psv.bin')
    prm['trup'] = ([j, k, -1], '>', 'trup.bin')
    prm['sux'] = [([j, k, -1], '>', 'sux.bin')]
    prm['suy'] = [([j, k, -1], '>', 'suy.bin')]

    # slip, slip velocity, and shear traction time histories
    x, y = prm['hypocenter'][:2]
    x += 7500.0 / dx
    y += 6000.0 / dx
    for f in 'sux', 'suy', 'svx', 'svy', 'tsx', 'tsy':
        if f not in prm:
            prm[f] = []
        prm[f] += [
            ([x, -1, ':'], '.>', 'P1-%s.bin' % f),  # mode II point
            ([-1, y, ':'], '.>', 'P2-%s.bin' % f),  # mode III point
        ]

    # run SORD
    d = os.path.join('..', 'Repository', 'TPV3-%03.0f' % dx)
    os.makedirs(d)
    os.chdir(d)
    cst.sord.run(prm)
    os.chdir(cwd)
