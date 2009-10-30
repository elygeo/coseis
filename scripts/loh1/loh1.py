#!/usr/bin/env python
"""
PEER LOH.1 - Layer over a halfspace, buried double couple source
"""
import sord

rundir = '~/run/loh1'		# simulation directory 
np3 = 1, 16, 1			# number of processors in each dimension
dx = 50.0, 50.0, 50.0		# spatial step size
dt = 0.004			# time step size
L = 8000.0, 10000.0, 6000.0	# problem dimentions
T = 9.0				# time length dimentions
nn = [ int( x / dx[0] + 20.5 ) for x in L  ]	# number of mesh nodes, nx ny nz
nt =   int( T / dt +  1.5 )			# number of time steps

# Material properties
hourglass = 1.0, 2.0		# hourglass stiffness and viscosity
fieldio = [
    ( '=', 'rho', [], 2700.0 ),	# density
    ( '=', 'vp',  [], 6000.0 ),	# P-wave speed
    ( '=', 'vs',  [], 3464.0 ),	# S-wave speed
    ( '=', 'gam', [],    0.0 ),	# viscosity
]

# Material properties of the layer
fieldio += [
    ( '=', 'rho', [(), (), (1.5, 20.5), ()], 2600.0 ),
    ( '=', 'vp',  [(), (), (1.5, 20.5), ()], 4000.0 ),
    ( '=', 'vs',  [(), (), (1.5, 20.5), ()], 2000.0 ),
]

# Near side boundary conditions:
# Anti-mirror symmetry at the near x and y boundaries
# Free surface at the near z boundary
bc1 = -2, -2, 0	

# Far side boundary conditions:
# PML absorbing boundaries at x, y and z boundaries
bc2 = 10, 10, 10

# Source parameters
ihypo = 1.5, 1.5, 41.5		# hypocenter indices
source = 'moment'		# specify moment source
timefunction = 'brune'		# time function: Brune pulse
period = 0.1			# time function dominant period
source1 = 0.0, 0.0, 0.0		# moment tensor M_xx, M_yy, M_zz
source2 = 0.0, 0.0, 1e18	# moment tensor M_yz, M_zx, M_yz

# Velocity time series output for surface station
j = ihypo[0] + 6000.0 / dx[0]
k = ihypo[1] + 8000.0 / dx[1]
l = ihypo[2]
fieldio += [
    ( '=w', 'v1', [(), (), 1, (1, -1, 10)], 'velocity' ),
    ( '=w', 'v1', [j, k, l, ()], 'vx' ),
    ( '=w', 'v2', [j, k, l, ()], 'vy' ),
    ( '=w', 'v3', [j, k, l, ()], 'vz' ),
]

sord.run( locals() )

