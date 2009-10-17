#!/usr/bin/env python
"""
TPV3 - SCEC validation problem version 3
"""
import sord

rundir = '~/run/tpv3'			# simulation directory 
np3 = 1, 1, 32				# number of processors in each dimension
nn = 351, 201, 128			# number of mesh nodes, nx ny nz
dx = 50.0, 50.0, 50.0			# spatial step size
nt = 3001				# number of time steps
dt = 0.004				# time step size

# Near side boundary conditions:
# PML absorbing boundaries for the x, y and z boundaries
bc1 = 10, 10, 10

# Far side boundary conditions:
# Anti-mirror symmetry for the x and z boundaries
# Mirror symmetry for the y boundary
bc2 = -2, 2, -2

# Define some mesh indices
o = -1.5				# origin index
j = o - 15000.0 / dx[0], -1 		# X fault extent
k = o -  7500.0 / dx[1], -1		# Y fault extent
l = o -  4000.0 / dx[2], -1		# Z low viscosity extent
p = o -  1500.0 / dx[0], -1		# nucleation path extent

# Material properties
fieldio = [
    ( '=', 'rho', [], 2670.0 ),		# density
    ( '=', 'vp',  [], 6000.0 ),		# P-wave speed
    ( '=', 'vs',  [], 3464.0 ),		# S-wave speed
    ( '=', 'gam', [], 0.2    ),		# high viscosity
    ( '=', 'gam', [j,k,l,0], 0.02 ),	# low viscosity zone near fault
]
hourglass = 1.0, 2.0

# Fault parameters
ihypo = o, o, o				# hypocenter indices
faultnormal = 3				# fault plane of constant z
fieldio += [
    ( '=', 'dc',  [],            0.4   ),	# slip weakening distance
    ( '=', 'mud', [],            0.525 ),	# dynamic friction
    ( '=', 'mus', [],              1e4 ),	# static friction - locked section
    ( '=', 'mus', [j, k, o, 0],  0.677 ),	# static friction - slipping section
    ( '=', 'tn',  [],           -120e6 ),	# normal traction
    ( '=', 'ts',  [],             70e6 ),	# shear traction
    ( '=', 'ts',  [p, p, o, 0], 81.6e6 ),	# shear traction - nucleation patch
]

# Write fault plane output
fieldio += [
    ( '=w', 'x1',   [(), (), o, ()], 'x1'   ),	# mesh coordinate X
    ( '=w', 'x2',   [(), (), o, ()], 'x2'   ),	# mesh coordinate Y
    ( '=w', 'su1',  [(), (), o, -1], 'su1'  ),	# final horizontal slip
    ( '=w', 'su2',  [(), (), o, -1], 'su2'  ),	# final vertical slip
    ( '=w', 'psv',  [(), (), o, -1], 'psv'  ),	# peak slip velocity
    ( '=w', 'trup', [(), (), o, -1], 'trup' ),	# rupture time
]

# Write slip, slip velocity, and shear traction time history
for f in 'su1', 'su2', 'sv1', 'sv2', 'ts1', 'ts2':
    fieldio += [
        ( '=w', f, [j, o, o, ()], 'P1_' + f ),	# mode II point
        ( '=w', f, [o, k, o, ()], 'P2_' + f ),	# mode III point
    ]

sord.run( locals() )

