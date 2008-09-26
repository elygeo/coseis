#!/usr/bin/env python
from sord import _

# PEER LOH.1 - Layer over a halfspace, buried double couple source

np = 1, 16, 1			# number of processors in each dimension
nn = 261, 301, 161		# number of mesh nodes, nx ny nz
nt = 2250			# number of time steps
dx = 50.			# spatial step size
dt = 0.004			# time step size

# Material properties
hourglass = 1., 2.		# hourglass stiffness and viscosity
io = [
  ( '=', 'rho', _[:,:,:,0], 2700. ),	# density
  ( '=', 'vp',  _[:,:,:,0], 6000. ),	# P-wave speed
  ( '=', 'vs',  _[:,:,:,0], 3464. ),	# S-wave speed
  ( '=', 'gam', _[:,:,:,0], 0.    ),	# viscosity
]

# Material properties of the layer
io += [
  ( '=', 'rho', _[:,:,:21,0], 2600. ),
  ( '=', 'vp',  _[:,:,:21,0], 4000. ),
  ( '=', 'vs',  _[:,:,:21,0], 2000. ),
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
xhypo = 0., 0., 2000.		# hypocenter coordinates
fixhypo = -2			# fix source at element center
tfunc = 'brune'			# Brune pulse time function
tsource = 0.1			# dominant period
moment1 = 0., 0., 0.		# moment tensor M_xx, M_yy, M_zz
moment2 = 0., 0., 1e18		# moment tensor M_yz, M_zx, M_yz

# Velocity time series output for surface station
io += [
  ( 'w', ('v1','v2','v3'), _[:,:,:,:], (6000.,80000.,0.) ),
]

