#!/usr/bin/env python
"""
TPV3 - SCEC validation problem version 3
"""

import sord

np = 1, 1, 32				# number of processors in each dimension
nn = 351, 201, 128			# number of mesh nodes, nx ny nz
nt = 3000				# number of time steps
dx = 50.				# spatial step size
dt = 0.004				# time step size

# Near side boundary conditions:
# PML absorbing boundaries for the x, y and z boundaries
bc1 = 10, 10, 10

# Far side boundary conditions:
# Anti-mirror symmetry for the x and z boundaries
# Mirror symmetry for the y boundary
bc2 = -2, 2, -2

# Material properties
fieldio = [
    ( '=',  'rho', [], 2670. ),		# density
    ( '=',  'vp',  [], 6000. ),		# P-wave speed
    ( '=',  'vs',  [], 3464. ),		# S-wave speed
    ( '=',  'gam', [], 0.2   ),		# viscosity
    ( '=c', 'gam', [], 0.02, (-15001.,-7501.,-4000.), (15001.,7501.,4000.) ),
]
hourglass = 1., 2.

# Fault parameters
faultnormal = 3				# fault plane of constant z
ihypo = -2, -2, -2			# hypocenter indices
fixhypo = -2				# hypocenter is cell centered
vrup = -1.				# disable circular nucleation
fieldio += [
    ( '=',  'dc',  [], 0.4    ),	# slip weakening distance
    ( '=',  'mud', [], 0.525  ),	# coefficient of dynamic friction
    ( '=',  'mus', [], 10000. ),	# coefficient of static friction
    ( '=c', 'mus', [], 0.677, (-15001.,-7501.,-1.), (15001.,7501.,1.) ),
    ( '=',  'tn',  [], -120e6 ),	# normal traction
    ( '=',  'ts',  [],   70e6 ),	# shear traction
    ( '=c', 'ts',  [], 81.6e6, (-1501.,-1501.,-1.), (1501.,1501.,1.) ),
]

# Write fault plane output
fieldio += [
    ( '=w', 'x1',   [0,0,-2, 0], 'x1'   ),	# mesh coordinate X
    ( '=w', 'x2',   [0,0,-2, 0], 'x2'   ),	# mesh coordinate Y
    ( '=w', 'su1',  [0,0,-2,-1], 'su1'  ),	# final horizontal slip
    ( '=w', 'su2',  [0,0,-2,-1], 'su2'  ),	# final vertical slip
    ( '=w', 'psv',  [0,0,-2,-1], 'psv'  ),	# peak slip velocity
    ( '=w', 'trup', [0,0,-2,-1], 'trup' ),	# rupture time
]

# Write slip, slip velocity, and shear traction time history
for _f in 'su1', 'su2', 'sv1', 'sv2', 'ts1', 'ts2':
    fieldio += [
        ( '=wx', _f, [], 'P1_'+_f, (-7499.,-1.,0.) ), # mode II point
        ( '=wx', _f, [], 'P2_'+_f, (-1.,-5999.,0.) ), # mode III point
    ]

sord.run( locals() )

