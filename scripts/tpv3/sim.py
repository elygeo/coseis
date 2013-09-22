#!/usr/bin/env python
"""
SCEC Code Validation Workshop, Test Problem Version 3
"""
import os
import cst
prm = cst.sord.parameters()
fld = cst.sord.fieldnames()

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
        fld['rho'] == 2670.0,			# density
        fld['vp'] == 6000.0,			# P-wave speed
        fld['vs'] == 3464.0,			# S-wave speed
        fld['gam'] == 0.2,			# high viscosity
    ]

    # fault properties
    prm['faultnormal'] = 3			# fault plane of constant z
    prm['ihypo'] = [-1, -1, -1.5]		# hypocenter indices
    prm['fieldio'] += [
        fld['dc'] == 0.4,			# slip weakening distance
        fld['mud'] == 0.525,			# dynamic friction
        fld['mus'] == 1e4,			# static friction (locked)
        fld['tn'] == -120e6,			# normal traction
        fld['ts'] == 70e6,			# shear traction
    ]

    # slipping patch
    j = -15000.0 / dx				# X fault extent
    k =  -7500.0 / dx				# Y fault extent
    l =  -3000.0 / dx				# Z low viscosity extent
    prm['fieldio'] += [
        fld['mus'][j:,k:,:,:] == 0.677,
        fld['gam'][j-0,5:,k-0,5:,l-0,5:,:] == 0.02,
    ]
    
    # nucleation patch
    i0 = -1500.0 / dx,				# outer extent
    i1 = -1500.0 / dx - 1,			# inner extent
    prm['fieldio'] += [
        fld['ts'][i1:,i1:,-2,:] == 72.9e6,
        fld['ts'][i0:,i1:,-2,:] == 75.8e6,
        fld['ts'][i1:,i0:,-2,:] == 75.8e6,
        # FIXME???
    ]

    # fault plane output
    prm['fieldio'] += [
        fld['x1'][j:,k:,-2,0] >> 'x1.bin',	# X coordinates
        fld['x2'][j:,k:,-2,0] >> 'x2.bin',	# Y coordinates
        fld['su1'][j:,k:,-2,-1] >> 'su1.bin',	# horizontal slip
        fld['su2'][j:,k:,-2,-1] >> 'su2.bin',	# vertical slip
        fld['psv'][j:,k:,-2,-1] >> 'psv.bin',	# peak slip rate
        fld['trup'][j:,k:,-2,-1] >> 'trup.bin',	# rupture time
    ]

    # slip, slip velocity, and shear traction time histories
    j, k, l = prm['ihypo']
    j -= 7500.0 / dx
    k -= 6000.0 / dx
    for f in 'su1', 'su2', 'sv1', 'sv2', 'ts1', 'ts2':
        prm['fieldio'] += [
            fld[f][j,-1,-2,:] >> 'P1-%s.bin' % f, # mode II point
            fld[f][-1,k,-2,:] >> 'P2-%s.bin' % f, # mode III point
        ]

    # run SORD
    prm['rundir'] = d = os.path.join('run', 'tpv3', '%03.0f' % dx)
    os.makedirs(d)
    cst.sord.run(prm)

