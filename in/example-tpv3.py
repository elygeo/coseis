# TPV3 - SCEC validation problem version 3

np = [ 1, 1, 32 ]		# number of processors in each dimension
nn = [ 351, 201, 128 ]		# number of mesh nodes, nx ny nz
nt = 3000			# number of time steps
dx = 50.			# spatial step size
dt = 0.004			# time step size

# Near side boundary conditions:
# PML absorbing boundaries for the x, y and z boundaries
bc1 = [ 10, 10, 10 ]

# Far side boundary conditions:
# Anti-mirror symmetry for the x and z boundaries
# Mirror symmetry for the y boundary
bc2 = [ -2, 2, -2 ]

# Material properties
rho = 2670.			# density
vp  = 6000.			# P-wave speed
vs  = 3464.			# S-wave speed
gam = 0.2			# viscosity
gam = [ 0.02, 'cube',-15001., -7501., -4000.,  15001., 7501., 4000. ]
hourglass = [ 1., 2. ]

# Fault parameters
faultnormal = 3		# fault plane of constant z
ihypo = [ -2, -2, -2 ]		# hypocenter indices
fixhypo = -2			# hypocenter is cell centered
vrup = -1.			# disable circular nucleation
dc  = 0.4			# slip weakening distance
mud = 0.525			# coefficient of dynamic friction
mus = 10000.			# coefficient of static friction
mus = [ 0.677, 'cube',-15001.,-7501.,-1., 15001.,7501.,1. ]
tn  = -120e6			# normal traction
ts1 = 70e6			# shear traction
ts1 = [ 81.6e6,'cube', -1501.,-1501.,-1.,  1501.,1501.,1. ]

# Fault plane output
out = [ 'x',    1,  1, 1,-2, 0,  -1,-1,-2, 0 ] # Mesh coordinates
out = [ 'su',   1,  1, 1, 0,-1,  -1,-1, 0,-1 ] # Final slip
out = [ 'psv',  1,  1, 1, 0,-1,  -1,-1, 0,-1 ] # Peak slip velocity
out = [ 'trup', 1,  1, 1, 0,-1,  -1,-1, 0,-1 ] # Rupture time

# Time series output, mode II point
timeseries = [ 'su',-7499.,-1.,0. ] # Slip
timeseries = [ 'sv',-7499.,-1.,0. ] # Slip velocity
timeseries = [ 'ts',-7499.,-1.,0. ] # Shear traction

# Time series output, mode III point
timeseries = [ 'su',-1.,-5999.,0. ] # Slip
timeseries = [ 'sv',-1.,-5999.,0. ] # Slip velocity
timeseries = [ 'ts',-1.,-5999.,0. ] # Shear traction

