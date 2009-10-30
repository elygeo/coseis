#!/usr/bin/env python
import sord

# List of runs:
# Column 1 is dx, the spatial step size
# Column 2 is np3, the number of processors in each dimension
runs_ = [ 
    ( 500.0, (1, 1, 2) ),
    ( 300.0, (1, 1, 2) ),
    ( 250.0, (1, 1, 2) ),
    ( 150.0, (1, 1, 2) ),
    ( 100.0, (1, 1, 2) ),
]
runs_ = [ 
    ( 500.0, (1, 4, 4) ),
    ( 300.0, (1, 4, 4) ),
    ( 250.0, (1, 4, 4) ),
    ( 150.0, (1, 4, 4) ),
    ( 100.0, (1, 4, 4) ),
    (  75.0, (1, 4, 4) ),
    (  50.0, (1, 4, 8) ),
    (  30.0, (1, 8, 8) ),
    (  25.0, (1, 8, 16) ),
    (  15.0, (1, 16, 16) ),
    (  10.0, (4, 16, 16) ),
]
runs_ = [ (  50.0, (1, 1, 2) ), ]
runs_ = [ ( 300.0, (1, 1, 2) ), ]
runs_ = [ ( 150.0, (1, 1, 2) ), ]

# Near side boundary conditions:
# PML absorbing boundaries for the x, y and z boundaries
bc1 = 10, 10, 10

# Far side boundary conditions:
# Anti-mirror symmetry for the x and z boundaries
# Mirror symmetry for the y boundary
bc2 = -1, 1, -2

# Loop over multiple runs
for dx, np3 in runs_:

    # Simulation directory
    rundir = '~/run/tpv3-%03.0f' % dx

    # Model dimentions
    dt = dx / 12500.0				# time step size
    dx = 3 * [dx]				# spatial step size
    nt = int( 12.0 / dt + 1.5 )			# number of time steps
    nn = ( 
        int( 16500.0 / dx[0] + 21.5 ),		# number of mesh nodes in x
        int(  9000.0 / dx[1] + 21.5 ),		# number of mesh nodes in y
        int(  6000.0 / dx[2] + 20.5 ),		# number of mesh nodes in z
    )

    # Material properties
    j = -15000.0 / dx[0] - 0.5, -1.5		# X fault extent
    k =  -7500.0 / dx[1] - 0.5, -1.5		# Y fault extent
    l =  -3000.0 / dx[2] - 0.5, -1.5		# Z low viscosity extent
    fieldio = [
        ( '=', 'rho', [],     2670.0  ),	# density
        ( '=', 'vp',  [],     6000.0  ),	# P-wave speed
        ( '=', 'vs',  [],     3464.0  ),	# S-wave speed
        ( '=', 'gam', [],        0.2  ),	# high viscosity
        ( '=', 'gam', [j,k,l,0], 0.02 ),	# low viscosity zone near fault
    ]
    hourglass = 1.0, 2.0    

    # Fault parameters
    faultnormal = 3				# fault plane of constant z
    ihypo = -1, -1, -1.5			# hypocenter indices
    j = -15000.0 / dx[0], -1			# X fault extent
    k =  -7500.0 / dx[1], -1			# Y fault extent
    o =  -1500.0 / dx[0] - 1, -1		# nucleation patch outer extent
    i =  -1500.0 / dx[0], -1			# nucleation patch inner extent
    fieldio += [
        ( '=', 'dc',  [],           0.4   ),	# slip weakening distance
        ( '=', 'mud', [],           0.525 ),	# dynamic friction
        ( '=', 'mus', [],             1e4 ),	# static friction - locked section
        ( '=', 'mus', [j,k,-2,()],  0.677 ),	# static friction - slipping section
        ( '=', 'tn',  [],          -120e6 ),	# normal traction
        ( '=', 'ts',  [],            70e6 ),	# shear traction
        ( '=', 'ts',  [o,o,-2,()], 72.9e6 ),	# shear traction - nucleation patch
        ( '=', 'ts',  [i,o,-2,()], 75.8e6 ),	# shear traction - nucleation patch
        ( '=', 'ts',  [o,i,-2,()], 75.8e6 ),	# shear traction - nucleation patch
        ( '=', 'ts',  [i,i,-2,()], 81.6e6 ),	# shear traction - nucleation patch
    ]

    # Write fault plane output
    fieldio += [
        ( '=w', 'x1',   [j,k,-2,0],  'x1'   ),	# X coordinates
        ( '=w', 'x2',   [j,k,-2,0],  'x2'   ),	# Y coordinates
        ( '=w', 'su1',  [j,k,-2,-1], 'su1'  ),	# final horizontal slip
        ( '=w', 'su2',  [j,k,-2,-1], 'su2'  ),	# final vertical slip
        ( '=w', 'psv',  [j,k,-2,-1], 'psv'  ),	# peak slip velocity
        ( '=w', 'trup', [j,k,-2,-1], 'trup' ),	# rupture time
    ]

    # Write slip, slip velocity, and shear traction time histories
    p1_ = ihypo[0] - 7500.0 / dx[0], -1, -2, ()	# mode II point indices
    p2_ = -1, ihypo[1] - 6000.0 / dx[1], -2, ()	# mode III point indices
    for f in 'su1', 'su2', 'sv1', 'sv2', 'ts1', 'ts2':
        fieldio += [
            ( '=w', f, p1_, 'P1-' + f ),	# mode II point
            ( '=w', f, p2_, 'P2-' + f ),	# mode III point
        ]

    # Launch SORD code
    sord.run( locals() )

