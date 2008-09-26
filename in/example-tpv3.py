#!/usr/bin/env python
from sord import _

# TPV3 - SCEC validation problem version 3

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
io = [
  ( '=', 'rho', _[:,:,:,0], 2670. ),	# density
  ( '=', 'vp',  _[:,:,:,0], 6000. ),	# P-wave speed
  ( '=', 'vs',  _[:,:,:,0], 3464. ),	# S-wave speed
  ( '=', 'gam', _[:,:,:,0],  0.2  ),	# viscosity
  ( '=', 'gam', _[:,:,:,0], (-15001.,-7501.,-4000.), (15001.,7501.,4000.), 0.02 ),
]
hourglass = 1., 2.

# Fault parameters
faultnormal = 3				# fault plane of constant z
ihypo = -2, -2, -2			# hypocenter indices
fixhypo = -2				# hypocenter is cell centered
vrup = -1.				# disable circular nucleation
io += [
  ( '=', 'dc',  _[:,:,:,0], 0.4    ),	# slip weakening distance
  ( '=', 'mud', _[:,:,:,0], 0.525  ),	# coefficient of dynamic friction
  ( '=', 'mus', _[:,:,:,0], 10000. ),	# coefficient of static friction
  ( '=', 'mus', _[:,:,:,0], (-15001.,-7501.,-1.), (15001.,7501.,1.), 0.677 ),
  ( '=', 'tn',  _[:,:,:,0], -120e6 ),	# normal traction
  ( '=', 'ts1', _[:,:,:,0],  70e6  ),	# shear traction
  ( '=', 'ts1', _[:,:,:,0], (-1501.,-1501.,-1.),  (1501.,1501.,1.), 81.6e6 ),
]

# Write fault plane output
io += [
  ( 'w', 'x', _[:,:,-2,0] ), 		# Mesh coordinates
  ( 'w', ('sl','psv','trup'), _[:,:,:,-1] ), # Final slip, peak slip velocity, and rupture time
]

# Write slip, slip velocity, and shear traction time history
io += [
  ( 'w', ('su1','su2','sv1','sv2','ts1','ts2'), _[:,:,:,:], (-7499.,-1.,0.) ), # Mode II point
  ( 'w', ('su1','su2','sv1','sv2','ts1','ts2'), _[:,:,:,:], (-1.,-5999.,0.) ), # Mode III point
]

