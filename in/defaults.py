# SORD Defaults

# I/O and Code execution parameters
np = ( 1, 1, 1 )		# number of processors in j k l
mpin = 1			# input:  0=separate files, 1=MPI-IO, -1=non-collective MPI-IO
mpout = 1			# output: 0=separate files, 1=MPI-IO, -1=non-collective MPI-IO
itstats = 10			# interval for calculating statistics
itio = 50			# interval for writing i/o buffers
itcheck = 0			# interval for check-pointing (0=off)
itstop = 0			# for testing check-pointing, simulates code crash
debug = 0			# debugging flag

# Wave model parameters
i1 = (  1,  1,  1,  0 )		# convenience variable not used by SORD
i2 = ( 41, 41, 42, 40 )		# convenience variable not used by SORD
di = (  1,  1,  1,  1 )		# convenience variable not used by SORD
nn = i2[:3]			# nx ny nz (double nodes counted)
nt = i2[3]			# number of time steps
dt = 0.0075			# time step length
dx = 100.			# spatial step length
io = [				# read grid files
  #( 'rz', 'x1', i1, i2, di, 0 ),	# read mesh x coord from file 'data/x1'
  #( 'rz', 'x2', i1, i2, di, 0 ),	# read mesh x coord from file 'data/x2'
  #( 'rz', 'x3', i1, i2, di, 0 ),	# read mesh x coord from file 'data/x3'
]
affine = ( (1.,0.,0.), (0.,1.,0.), (0.,0.,1.) ) # grid transformation
gridnoise = 0.			# random noise added to mesh, assumes planar fault
oplevel = 0			# spatial difference operator level (see below)
vdamp = -1.			# Vs dependent damping
hourglass = ( 1., 1. )		# hourglass stiffness (1) and viscosity (2)
io += [			# set material properties
  ( 'sz', 'vp', 2670.,     i1, i2, di, 0 ),	# density
  ( 'sz', 'vp', 6000.,     i1, i2, di, 0 ),	# P-wave speed
  ( 'sz', 'vs', 3464.1016, i1, i2, di, 0 ),	# S-wave speed
  ( 'sz', 'gam',   0.,     i1, i2, di, 0 ),	# viscosity
]
rho1 = -1.			# min density
rho2 = -1.			# max density
vp1 = -1.			# min P-wave speed
vp2 = -1.			# max P-wave speed
vs1 = -1.			# min S-wave speed
vs2 = -1.			# max S-wave speed
gam1 = -1.			# min viscosity
gam2 = 0.8			# max viscosity
npml = 10			# number of PML daming nodes
bc1 = ( 0, 0, 0 )		# j1 k1 l1 boundary condition (see below)
bc2 = ( 0, 0, 0 )		# j2 k2 l2 boundary condition (see below)
ihypo = ( 0, 0, 0 )		# hypocenter node
xhypo = ( 0., 0., 0. )		# hypocenter location
fixhypo = 1			# 0=none 1=inode, 2=icell, -1=xnode, -2=xcell
rexpand = 1.06			# grid expansion ratio
n1expand = ( 0, 0, 0 )		# n grid expansion nodes for j1 k1 l1
n2expand = ( 0, 0, 0 )		# n grid expansion nodes for j2 k2 l2

# Point source and plane wave parameters
i1source = ( 2, 2, 2 )		# finite source start index
i2source = ( 1, 1, 1 )		# finite source end index
#rfunc = 'box'			# spatial weighting: uniform
#rfunc = 'tent'			# spatial weighting: tapered
rfunc = 'point'			# point source
#tfunc = 'delta'		# source time function: delta
tfunc = 'brune'			# source time function: Brune
#tfunc = 'sbrune'		# source time function: smooth Brune
#rsource = 150.			# source radius: 1.5*dx = 8 nodes
rsource = -1.			# no moment source
tsource = 0.056			# dominant period of 8*dt
moment1 = ( 1e16, 1e16, 1e16 )	# normal components, explosion source
moment2 = ( 0., 0., 0. )	# shear components

# Fault parameters
faultnormal = 3			# normal direction to fault plane (0=no fault)
faultopening = 0		# 0=not allowed, 1=allowed
slipvector = ( 1., 0., 0. )	# shear traction direction for ts1
vrup = 3184.9			# nucleation rupture velocity (using Rayleigh speed here)
rcrit = 1000.			# nucleation critical radius
trelax = 0.07			# nucleation relaxation time
svtol = 0.001			# slip velocity considered rupturing
io += [				# i/o sequence
   ( 'sz', 'mus',    0.6, i1, i2, di, 0 ),	# coef of static friction
   ( 'sz', 'mud',    0.5, i1, i2, di, 0 ),	# coef of dynamic friction
   ( 'sz',  'dc',    0.4, i1, i2, di, 0 ),	# slip-weakening distance
  #( 'sz',  'co',     0., i1, i2, di, 0 ),	# cohesion
   ( 'sz', 'ts1',  -70e6, i1, i2, di, 0 ),	# shear traction component 1
  #( 'sz', 'ts2',     0., i1, i2, di, 0 ),	# shear traction component 2
   ( 'sz',  'tn', -120e6, i1, i2, di, 0 ),	# normal traction
  #( 'sz', 'sxx',     0., i1, i2, di, 0 ),	# prestress Sxx
  #( 'sz', 'syy',     0., i1, i2, di, 0 ),	# prestress Syy
  #( 'sz', 'szz',     0., i1, i2, di, 0 ),	# prestress Szz
  #( 'sz', 'syz',     0., i1, i2, di, 0 ),	# prestress Syz
  #( 'sz', 'szx',     0., i1, i2, di, 0 ),	# prestress Szx
  #( 'sz', 'sxy',     0., i1, i2, di, 0 ),	# prestress Sxy
]

# Spatial difference operator level:
#  0: Auto pick 2 or 6
#  1: Mesh with constant spacing dx
#  2: Rectangular mesh
#  3: Parallelepiped mesh
#  4: One-point quadrature
#  5: Exactly integrated elements
#  6: Saved operators, nearly as fast as 2, but doubles the memory usage

# Boundary conditions:
#  0: Vacuum free surface: zero cell stress
#  1: Mirror symmetry at the node
#  2: Mirror symmetry at the cell
# -1: Anti-mirror symmetry at the node, useful for nodal planes
# -2: Anti-mirror symmetry at the cell, useful for nodal planes and fault planes
#  3: Rigid boundary: zero node displacement
#  4: Continue
# 10: PML absorbing

