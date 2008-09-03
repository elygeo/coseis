# San Andreas Fault, northward dynamic rupture, topography, SCEC-CVM4

iii = 88

np = ( 1, 80, 24 )			# 1920 total processors on DataStar
nn = ( 3001, 1502, 401 )		# number of mesh nodes nx ny nz
nt = 15000				# number of time steps
dt = 0.012				# time step length

# Read mesh coordinates from disk
#datadir = 'saf/cvm4/0200'		# directory location
io = [
  ( 'rz', 'x1', 1,1,1,0, -1,-1,1,0, 1,1,1,1, 1 ),	# read 2D x coordinate file
  ( 'rz', 'x2', 1,1,1,0, -1,-1,1,0, 1,1,1,1, 1 ),	# read 2D y coordinate file
  ( 'r0', 'x3' ),					# read 3D z coordinate file
]

# Boundary conditions, PML on all side except for free surface
bc1 = ( 10, 10, 10 )
bc2 = ( 10, 10,  0 )

# Material model
io += [
  ( 'r0', 'rho' ),			# read 3D density file
  ( 'r0', 'vp' ),			# read 3D V_p file
  ( 'r0', 'vs' ),			# read 3D V_s file
]
vdamp = 400.				# set viscosity = vdamp / vs
vp1  = 1500.				# set minimum V_p
vs1  = 500.				# set minimum V_s
gam2 = 0.8				# set maximum viscosity
hourglass = ( 1., 1. )			# hourglass stiffness and viscosity

# Fault parameters
ihypo = ( 2266, 997, -26 )		# hypocenter indices
faultnormal = 2				# fault plane at k = ihypo(2) = 997
j = ( 1317, ihypo[faultnormal], -81 )	# temporary variable
k = ( 2311, ihypo[faultnormal],  -1 )	# temporary variable
d = ( 1, 1, 1, 1 )			# temporary variable
slipvector = ( 1., 0., 0. )		# vector for resolving pre-traction
io += [
  ( 's0', 'tn', -20e6                ),	# initial normal traction
  ( 'r0', 'ts1'                      ),	# read initial shear traction file
  ( 's0', 'dc',  0.5                 ),	# slip weakening distance
  ( 's0', 'mud', 0.5                 ),	# coefficient of dynamic friction
  ( 's0', 'mus', 1000.               ),	# coefficient of static friction, non-slip section
  ( 'sz', 'mus', j,0,  k,0,  d,  1.1 ),	# coefficient of static friction, slipping section
]

# Nucleation
fixhypo = 1				# node registered hypocenter
vrup = 2300.				# nucleation rupture velocity
trelax = 0.12				# time 
rcrit = 3000.				# radius of nucleation patch

# Fault plane output
io += [
  ( 'w1', 'su',   10 ),			# final slip
  ( 'w1', 'psv',  10 ),			# peak slip velocity
  ( 'w1', 'trup', 10 ),			# rupture time
]

# Velocity time series output
io += [
  ( 'wn', 'v', 2642, 813, -1 ),		# Mexicali
  ( 'wn', 'v', 2028, 979, -1 ),		# Coachella
  ( 'wn', 'v', 2015, 324, -1 ),		# San Diego
  ( 'wn', 'v', 1842, 940, -1 ),		# Palm Springs
  ( 'wn', 'v', 1457, 960, -1 ),		# San Bernardino
  ( 'wn', 'v', 1476, 852, -1 ),		# Riverside
  ( 'wn', 'v', 1307,1141, -1 ),		# Victorville
  ( 'wn', 'v', 1345, 840, -1 ),		# Ontario
  ( 'wn', 'v', 1278,1341, -1 ),		# Barstow
  ( 'wn', 'v', 1384, 620, -1 ),		# Santa Ana
  ( 'wn', 'v', 1205, 668, -1 ),		# Montebello
  ( 'wn', 'v', 1142, 642, -1 ),		# Los Angeles
  ( 'wn', 'v', 1262, 532, -1 ),		# Long Beach
  ( 'wn', 'v', 1079, 589, -1 ),		# Westwood
  ( 'wn', 'v',  951, 961, -1 ),		# Lancaster
]

