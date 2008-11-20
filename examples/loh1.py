#!/usr/bin/env python
"""
PEER LOH.1 - Layer over a halfspace, buried double couple source
"""

import sord

np3 = 1, 16, 1			# number of processors in each dimension
nn = 261, 301, 161		# number of mesh nodes, nx ny nz
nt = 2250			# number of time steps
dx = 50.0			# spatial step size
dt = 0.004			# time step size

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
    ( '=', 'rho', [0,0,(1,21),0], 2600.0 ),
    ( '=', 'vp',  [0,0,(1,21),0], 4000.0 ),
    ( '=', 'vs',  [0,0,(1,21),0], 2000.0 ),
]

# Near side boundary conditions:
# Anti-mirror symmetry at the near x and y boundaries
# Free surface at the near z boundary
bc1 = -2, -2, 0	

# Far side boundary conditions:
# PML absorbing boundaries at x, y and z boundaries
bc2 = 10, 10, 10

# Source parameters
faultnormal = 0			# disable rupture dynamics
ihypo = 1, 1, 41		# hypocenter indices
xhypo = 0.0, 0.0, 2000.0	# hypocenter coordinates
fixhypo = -2			# fix source at element center
tfunc = 'brune'			# Brune pulse time function
tsource = 0.1			# dominant period
moment1 = 0.0, 0.0, 0.0		# moment tensor M_xx, M_yy, M_zz
moment2 = 0.0, 0.0, 1e18	# moment tensor M_yz, M_zx, M_yz

# Velocity time series output for surface station
fieldio += [
    ( '=wx', 'v1', [], 'station1-v1', (6001.0, 80001.0, -1.0) ),
    ( '=wx', 'v2', [], 'station1-v2', (6001.0, 80001.0, -1.0) ),
    ( '=wx', 'v3', [], 'station1-v3', (6001.0, 80001.0, -1.0) ),
]

sord.run( locals() )

