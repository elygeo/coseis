#!/usr/bin/env python
import os
import cst
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
    [ 75.0, [1,  4,  4]],
    [ 50.0, [1,  4,  8]],
    [ 30.0, [1,  8,  8]],
    [ 25.0, [1,  8, 16]],
    [ 15.0, [1, 16, 16]],
    [ 10.0, [4, 16, 16]],
]
runs = [
    [500.0, [1, 1, 1]],
    [300.0, [1, 1, 1]],
    [250.0, [1, 1, 1]],
    [150.0, [1, 1, 1]],
    [100.0, [1, 1, 1]],
]
runs = [[ 50.0, [1, 1, 1]]]
runs = [[300.0, [1, 1, 1]]]
runs = [[150.0, [1, 1, 2]]]

# near side boundary conditions:
# PML absorbing boundaries for the x, y and z boundaries
prm['bc1'] = [10, 10, 10]

# far side boundary conditions:
# anti-mirror symmetry for the x and z boundaries
# mirror symmetry for the y boundary
prm['bc2'] = [-1, 1, -2]

# loop over multiple runs
cwd = os.getcwd()
for dx, np in runs:

    # dimensions
    dt = dx / 12500.0
    prm['nproc3'] = np
    prm['delta'] = [dx, dx, dx, dt]             # step size
    prm['shape'] = [
        int(16500.0 / dx + 21.5),               # number of mesh nodes in x
        int( 9000.0 / dx + 21.5),               # number of mesh nodes in y
        int( 6000.0 / dx + 20.5),               # number of mesh nodes in z
        int(   12.0 / dt +  1.5),               # number of time steps
    ]

    # material properties
    prm['hourglass'] = [1.0, 2.0]
    prm['fieldio'] = [
        'rho = 2670.0',				# density
        'vp  = 6000.0',				# P-wave speed
        'vs  = 3464.0',				# S-wave speed
        'gam = 0.2',				# high viscosity
    ]

    # fault properties
    prm['faultnormal'] = 3			# fault plane of constant z
    prm['ihypo'] = [-1, -1, -1.5]		# hypocenter indices
    prm['fieldio'] += [
        'dc = 0.4',				# slip weakening distance
        'mud = 0.525',				# dynamic friction
        'mus = 1e4',				# static friction (locked)
        'tn = -120e6',				# normal traction
        'ts = 70e6',				# shear traction
    ]

    # slipping patch
    j = -15000.0 / dx				# X fault extent
    k =  -7500.0 / dx				# Y fault extent
    l =  -3000.0 / dx				# Z low viscosity extent
    prm['fieldio'] += [
        'mus[{}:,{}:,:,:] = 0.677'.format(j, k),
        'gam[{}:,{}:,{}:,:] = 0.02'.format(j-0.5, k-0.5, l-0.5)
    ]
    
    # nucleation patch
    i0 = -1500.0 / dx,				# outer extent
    i1 = -1500.0 / dx - 1,			# inner extent
    prm['fieldio'] += [
        'ts[{}:,{}:,-2,:] = 72.9e6'.format(i1, i1),
        'ts[{}:,{}:,-2,:] = 75.8e6'.format(i1, i0),
        'ts[{}:,{}:,-2,:] = 75.8e6'.format(i0, i1),
    ]

    # fault plane output
    prm['fieldio'] += [
        'x1[{}:,{}:,-2,0] write x1.bin'.format(j, k),		# X coordinates
        'x2[{}:,{}:,-2,0] write x2.bin'.format(j, k),		# Y coordinates
        'su1[{}:,{}:,-2,-1] write su1.bin'.format(j, k),	# horizontal slip
        'su2[{}:,{}:,-2,-1] write su2.bin'.format(j, k),	# vertical slip
        'psv[{}:,{}:,-2,-1] write psv.bin'.format(j, k),	# peak slip rate
        'trup[{}:,{}:,-2,-1] write trup.bin'.format(j, k),	# rupture time
    ]

    # slip, slip velocity, and shear traction time histories
    j, k, l = prm['ihypo']
    j -= 7500.0 / dx
    k -= 6000.0 / dx
    for f in 'su1', 'su2', 'sv1', 'sv2', 'ts1', 'ts2':
        prm['fieldio'] += [
            '{}[{},-1,-2,:] write P1-{}.bin'.format(f, j, f), # mode II point
            '{}[-1,{},-2,:] write P2-{}.bin'.format(f, k, f), # mode III point
        ]

    # run SORD
    prm['rundir'] = d = os.path.join('run', 'tpv3', '{:03.0f}'.format(dx))
    os.makedirs(d)
    cst.sord.run(prm)

