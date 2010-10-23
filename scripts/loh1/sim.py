#!/usr/bin/env python
"""
PEER LOH.1 - Layer over a halfspace, buried double couple source
"""
import cst

# number of processors in each dimension
nproc3 = 1, 16, 1

# dimensions
delta = 50.0, 50.0, 50.0, 0.004	
x, y, z, t = 8000.0, 10000.0, 6000.0, 9.0
shape = (
    int( x / delta[0] + 20.5 ),
    int( y / delta[1] + 20.5 ),
    int( z / delta[2] + 20.5 ),
    int( t / delta[3] + 1.5 ),
)

# material properties
hourglass = 1.0, 2.0		# hourglass stiffness and viscosity
fieldio = [
    ( '=', 'rho', [], 2700.0 ),	# density
    ( '=', 'vp',  [], 6000.0 ),	# P-wave speed
    ( '=', 'vs',  [], 3464.0 ),	# S-wave speed
    ( '=', 'gam', [],    0.0 ),	# viscosity
]

# material properties of the layer
fieldio += [
    ( '=', 'rho', [(), (), (1.5, 20.5), ()], 2600.0 ),
    ( '=', 'vp',  [(), (), (1.5, 20.5), ()], 4000.0 ),
    ( '=', 'vs',  [(), (), (1.5, 20.5), ()], 2000.0 ),
]

# near side boundary conditions:
# anti-mirror symmetry at the near x and y boundaries
# free surface at the near z boundary
bc1 = -2, -2, 0	

# far side boundary conditions:
# PML absorbing boundaries at x, y and z boundaries
bc2 = 10, 10, 10

# source parameters
ihypo = 1.5, 1.5, 41.5		# hypocenter indices
source = 'moment'		# specify moment source
timefunction = 'brune'		# time function: Brune pulse
period = 0.1			# time function dominant period
source1 = 0.0, 0.0, 0.0		# moment tensor M_xx, M_yy, M_zz
source2 = 0.0, 0.0, 1e18	# moment tensor M_yz, M_zx, M_yz

# velocity time series output for surface station
j = ihypo[0] + 6000.0 / delta[0]
k = ihypo[1] + 8000.0 / delta[1]
l = ihypo[2]
fieldio += [
    ( '=w', 'v1', [(), (), 1, (1, -1, 10)], 'velocity.bin' ),
    ( '=w', 'v1', [j, k, l, ()], 'vx.bin' ),
    ( '=w', 'v2', [j, k, l, ()], 'vy.bin' ),
    ( '=w', 'v3', [j, k, l, ()], 'vz.bin' ),
]

# run job
cst.sord.run( locals() )

