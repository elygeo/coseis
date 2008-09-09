# TPV3 - SCEC validation problem version 3

np = ( 1, 1, 32 )		# number of processors in each dimension
nn = ( 351, 201, 128 )		# number of mesh nodes, nx ny nz
nt = 3000			# number of time steps
dx = 50.			# spatial step size
dt = 0.004			# time step size

# Near side boundary conditions:
# PML absorbing boundaries for the x, y and z boundaries
bc1 = ( 10, 10, 10 )

# Far side boundary conditions:
# Anti-mirror symmetry for the x and z boundaries
# Mirror symmetry for the y boundary
bc2 = ( -2, 2, -2 )

# Material properties
io = [
  ( 's0', 'rho', 2670. ),	# density
  ( 's0', 'vp',  6000. ),	# P-wave speed
  ( 's0', 'vs',  3464. ),	# S-wave speed
  ( 's0', 'gam',  0.2  ),	# viscosity
  ( 'sc', 'gam', (-15001.,-7501.,-4000.), (15001.,7501.,4000.), 0.02 )
]
hourglass = ( 1., 2. )

# Fault parameters
faultnormal = 3			# fault plane of constant z
ihypo = ( -2, -2, -2 )		# hypocenter indices
fixhypo = -2			# hypocenter is cell centered
vrup = -1.			# disable circular nucleation
io += [
  ( 's0', 'dc',   0.4    ),	# slip weakening distance
  ( 's0', 'mud',  0.525  ),	# coefficient of dynamic friction
  ( 's0', 'mus',  10000. ),	# coefficient of static friction
  ( 'sc', 'mus', (-15001.,-7501.,-1.), (15001.,7501.,1.), 0.677 ),
  ( 's0', 'tn',  -120e6  ),	# normal traction
  ( 's0', 'ts1',   70e6  ),	# shear traction
  ( 'sc', 'ts1',  (-1501.,-1501.,-1.),  (1501.,1501.,1.), 81.6e6 ),
]

# Fault plane output
io += [
  ( 'wi', 'x', (1,1,-2,0), (-1,-1,-2,0), (1,1,1,1), 1 ), # Mesh coordinates
  ( 'w1', ('sl','psv','trup') ), # Final slip, peak slip velocity, and rupture time
]

# Slip, slip velocity, and shear traction time history output
io += [
  ( 'wx', ('su1','su2','sv1','sv2','ts1','ts2'), (-7499.,-1.,0.) ), # Mode II point
  ( 'wx', ('su1','su2','sv1','sv2','ts1','ts2'), (-1.,-5999.,0.) ), # Mode III point
]

