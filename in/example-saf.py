#!/usr/bin/env python
from sord import _

# San Andreas Fault, northward dynamic rupture, topography, SCEC-CVM4

np = 1, 80, 24				# 1920 total processors on DataStar
nn = 3001, 1502, 401			# number of mesh nodes nx ny nz
nt = 15000				# number of time steps
dt = 0.012				# time step length

# Read mesh coordinates from disk
#datadir = 'saf/cvm4/0200'		# directory location
io = [
  ( 'r', ('x1','x1'), _[:,:,1,0] ),	# read 2D x,y coordinate files
  ( 'r',  'x3',       _[:,:,:,0] ),	# read 3D z coordinate file
]

# Boundary conditions, PML on all side except for free surface
bc1 = 10, 10, 10
bc2 = 10, 10,  0

# Material properties
io += [
  ( 'r', ('rho','vp','vs'), _[:,:,:,0] ) # Read 3D material files: density, V_p, and V_s
]
vdamp = 400.				# viscosity = vdamp / vs
vp1  = 1500.				# minimum V_p
vs1  = 500.				# minimum V_s
gam2 = 0.8				# maximum viscosity
hourglass = 1., 1.			# hourglass stiffness and viscosity

# Fault parameters
slipvector = 1., 0., 0.			# vector for resolving pre-traction
faultnormal = 2				# fault plane at k = ihypo(2)
k = 997					# temporary variable
ihypo = 2266, k, -26			# hypocenter indices
io += [
  ( 'r', 'ts1', _[:,k,:,0]        ),	# read initial shear traction file
  ( '=', 'tn',  _[:,k,:,0], -20e6 ),	# initial normal traction
  ( '=', 'dc',  _[:,k,:,0], 0.5   ),	# slip weakening distance
  ( '=', 'mud', _[:,k,:,0], 0.5   ),	# coeff of dynamic friction
  ( '=', 'mus', _[:,k,:,0], 1000. ),	# coeff of static friction, non-slip section
  ( '=', 'mus', _[1217:2311,k,-81:,0], 1.1 ), # coeff of static friction, slipping section
]

# Nucleation
fixhypo = 1				# node registered hypocenter
vrup = 2300.				# nucleation rupture velocity
trelax = 0.12				# time 
rcrit = 3000.				# radius of nucleation patch

# Write fault plane output: final slip, peak slip velocity, rupture time
io += [
  ( 'w', ('sl','psv','trup'), _[:,:,:,-1] )
]

# Write velocity time series
io += [
  ( 'w', ('v1','v2','v3'), _[2642, 813,-1,:] ),		# Mexicali
  ( 'w', ('v1','v2','v3'), _[2028, 979,-1,:] ),		# Coachella
  ( 'w', ('v1','v2','v3'), _[2015, 324,-1,:] ),		# San Diego
  ( 'w', ('v1','v2','v3'), _[1842, 940,-1,:] ),		# Palm Springs
  ( 'w', ('v1','v2','v3'), _[1457, 960,-1,:] ),		# San Bernardino
  ( 'w', ('v1','v2','v3'), _[1476, 852,-1,:] ),		# Riverside
  ( 'w', ('v1','v2','v3'), _[1307,1141,-1,:] ),		# Victorville
  ( 'w', ('v1','v2','v3'), _[1345, 840,-1,:] ),		# Ontario
  ( 'w', ('v1','v2','v3'), _[1278,1341,-1,:] ),		# Barstow
  ( 'w', ('v1','v2','v3'), _[1384, 620,-1,:] ),		# Santa Ana
  ( 'w', ('v1','v2','v3'), _[1205, 668,-1,:] ),		# Montebello
  ( 'w', ('v1','v2','v3'), _[1142, 642,-1,:] ),		# Los Angeles
  ( 'w', ('v1','v2','v3'), _[1262, 532,-1,:] ),		# Long Beach
  ( 'w', ('v1','v2','v3'), _[1079, 589,-1,:] ),		# Westwood
  ( 'w', ('v1','v2','v3'), _[ 951, 961,-1,:] ),		# Lancaster
]

