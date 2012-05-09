#!/usr/bin/env python
import cst
prm = cst.sord.parameters()

# list of runs:
# column 1 is dx, the spatial step size
# column 2 is nproc3, the number of processors in each dimension
runs = [
    (500.0, (1,  4,  4)),
    (300.0, (1,  4,  4)),
    (250.0, (1,  4,  4)),
    (150.0, (1,  4,  4)),
    (100.0, (1,  4,  4)),
    ( 75.0, (1,  4,  4)),
    ( 50.0, (1,  4,  8)),
    ( 30.0, (1,  8,  8)),
    ( 25.0, (1,  8, 16)),
    ( 15.0, (1, 16, 16)),
    ( 10.0, (4, 16, 16)),
]
runs = [
    (500.0, (1, 1, 2)),
    (300.0, (1, 1, 2)),
    (250.0, (1, 1, 2)),
    (150.0, (1, 1, 2)),
    (100.0, (1, 1, 2)),
]
runs = [( 50.0, (1, 1, 2))]
runs = [(150.0, (1, 1, 2))]
runs = [(300.0, (1, 1, 2))]

# near side boundary conditions:
# PML absorbing boundaries for the x, y and z boundaries
prm.bc1 = 10, 10, 10

# far side boundary conditions:
# anti-mirror symmetry for the x and z boundaries
# mirror symmetry for the y boundary
prm.bc2 = -1, 1, -2

# loop over multiple runs
for dx, np in runs:

    # model dimensions
    dt = dx / 12500.0
    prm.nproc3 = np
    prm.delta = dx, dx, dx, dt                  # step size
    prm.shape = (
        int(16500.0 / dx + 21.5),               # number of mesh nodes in x
        int( 9000.0 / dx + 21.5),               # number of mesh nodes in y
        int( 6000.0 / dx + 20.5),               # number of mesh nodes in z
        int(   12.0 / dt +  1.5),               # number of time steps
    )

    # material properties
    j = -15000.0 / dx - 0.5, -1.5               # X fault extent
    k =  -7500.0 / dx - 0.5, -1.5               # Y fault extent
    l =  -3000.0 / dx - 0.5, -1.5               # Z low viscosity extent
    prm.hourglass = 1.0, 2.0
    prm.fieldio = [
        ('=', 'rho', [],      2670.0),          # density
        ('=', 'vp',  [],      6000.0),          # P-wave speed
        ('=', 'vs',  [],      3464.0),          # S-wave speed
        ('=', 'gam', [],         0.2),          # high viscosity
        ('=', 'gam', [j,k,l,()], 0.02),         # low viscosity zone near fault
    ]

    # fault parameters
    prm.faultnormal = 3                          # fault plane of constant z
    prm.ihypo = -1, -1, -1.5                     # hypocenter indices
    j = -15000.0 / dx, -1                        # X fault extent
    k =  -7500.0 / dx, -1                        # Y fault extent
    o =  -1500.0 / dx - 1, -1                    # nucleation patch outer extent
    i =  -1500.0 / dx, -1                        # nucleation patch inner extent
    prm.fieldio += [
        ('=', 'dc',  [],             0.4),       # slip weakening distance
        ('=', 'mud', [],           0.525),       # dynamic friction
        ('=', 'mus', [],             1e4),       # static friction - locked section
        ('=', 'mus', [j,k,-2,()],  0.677),       # static friction - slipping section
        ('=', 'tn',  [],          -120e6),       # normal traction
        ('=', 'ts',  [],            70e6),       # shear traction
        ('=', 'ts',  [o,o,-2,()], 72.9e6),       # shear traction - nucleation patch
        ('=', 'ts',  [i,o,-2,()], 75.8e6),       # shear traction - nucleation patch
        ('=', 'ts',  [o,i,-2,()], 75.8e6),       # shear traction - nucleation patch
        ('=', 'ts',  [i,i,-2,()], 81.6e6),       # shear traction - nucleation patch
    ]

    # write fault plane output
    i0 = j, k, -2, 0
    i1 = j, k, -2, -1
    prm.fieldio += [
        ('=w', 'x1',   i0, 'x1.bin'),           # X coordinates
        ('=w', 'x2',   i0, 'x2.bin'),           # Y coordinates
        ('=w', 'su1',  i1, 'su1.bin'),          # final horizontal slip
        ('=w', 'su2',  i1, 'su2.bin'),          # final vertical slip
        ('=w', 'psv',  i1, 'psv.bin'),          # peak slip velocity
        ('=w', 'trup', i1, 'trup.bin'),         # rupture time
    ]

    # write slip, slip velocity, and shear traction time histories
    j, k, l = prm.ihypo
    j -= 7500.0 / dx
    k -= 6000.0 / dx
    for f in 'su1', 'su2', 'sv1', 'sv2', 'ts1', 'ts2':
        prm.fieldio += [
            ('=w', f, [j,-1,-2,()], 'P1-%s.bin' % f),     # mode II point
            ('=w', f, [-1,k,-2,()], 'P2-%s.bin' % f),     # mode III point
        ]

    # launch SORD code
    cst.sord.run(prm,
        rundir = 'run/tpv3/%03.0f' % dx
    )

