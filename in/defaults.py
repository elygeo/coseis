# SORD Defaults

# Wave model parameters
nn = [ 41, 41, 42 ]		# nx ny nz (double nodes counted)
nt = 40				# number of time steps
dt = 0.0075			# time step length
dx = 100.			# spatial step length
#x1 = 'read'			# read mesh x coord from file 'data/x1'
#x2 = 'read'			# read mesh y coord from file 'data/x2'
#x3 = 'read'			# read mesh z coord from file 'data/x3'
affine = [[ 1., 0., 0. ], [ 0., 1., 0. ], [ 0., 0., 1. ]] # grid transformation
gridnoise = 0.			# random noise added to mesh, assumes planar fault
oplevel = 0			# spatial difference operator level (see below)
rho = 2670.			# **density
vp = 6000.			# **P-wave speed
vs = 3464.1016			# **S-wave speed
#gam = 0.			# **viscosity
vdamp = -1.			# Vs dependent damping
hourglass = [ 1., 1. ]		# hourglass stiffness (1) and viscosity (2)
rho1 = -1.			# min density
rho2 = -1.			# max density
vp1 = -1.			# min P-wave speed
vp2 = -1.			# max P-wave speed
vs1 = -1.			# min S-wave speed
vs2 = -1.			# max S-wave speed
gam1 = -1.			# min viscosity
gam2 = 0.8			# max viscosity
npml = 10			# number of PML daming nodes
bc1 = [ 0, 0, 0 ]		# j1 k1 l1 boundary condition (see below)
bc2 = [ 0, 0, 0 ]		# j2 k2 l2 boundary condition (see below)
ihypo = [ 0, 0, 0 ]		# hypocenter node
xhypo = [ 0., 0., 0. ]		# hypocenter location
fixhypo = 1			# 0=none 1=inode, 2=icell, -1=xnode, -2=xcell
rexpand = 1.06			# grid expansion ratio
n1expand = [ 0, 0, 0 ]		# n grid expansion nodes for j1 k1 l1
n2expand = [ 0, 0, 0 ]		# n grid expansion nodes for j2 k2 l2

# Point source and plane wave parameters
i1source = [ 2, 2, 2 ]		# finite source start index
i2source = [ 1, 1, 1 ]		# finite source end index
#rfunc = 'box'			# spatial weighting: uniform
#rfunc = 'tent'		# spatial weighting: tapered
rfunc = 'point'		# point source
#tfunc = 'delta'		# source time function: delta
tfunc = 'brune'		# source time function: Brune
#tfunc = 'sbrune'		# source time function: smooth Brune
#rsource = 150.		# source radius: 1.5*dx = 8 nodes
rsource = -1.			# no moment source
tsource = 0.056		# dominant period of 8*dt
moment1 = [ 1e16, 1e16, 1e16 ]	# normal components, explosion source
moment2 = [ 0., 0., 0. ]	# shear components

# Fault parameters
faultnormal = 3		# normal direction to fault plane (0=no fault)
faultopening = 0		# 0=not allowed, 1=allowed
slipvector = [ 1., 0., 0. ]	# shear traction direction for ts1
mus = 0.6			# **coef of static friction
mud = 0.5			# **coef of dynamic friction
dc  = 0.4			# **slip-weakening distance
#co  = 0.			# **cohesion
ts1 = -70e6			# **shear traction component 1
# ts2 = 0.			# **shear traction component 2
tn  = -120e6			# **normal traction
#sxx = 0.			# **prestress Sxx
#syy = 0.			# **prestress Syy
#szz = 0.			# **prestress Szz
#syz = 0.			# **prestress Syz
#szx = 0.			# **prestress Szx
#sxy = 0.			# **prestress Sxy
vrup = 3184.9			# nucleation rupture velocity (using Rayleigh speed here)
rcrit = 1000.			# nucleation critical radius
trelax = 0.07			# nucleation relaxation time
svtol = 0.001			# slip velocity considered rupturing

# I/O and Code execution parameters
np = [ 1, 1, 1 ]		# number of processors in j k l
mpin = 1			# input:  0=separate files, 1=MPI-IO, -1=non-collective MPI-IO
mpout = 1			# output: 0=separate files, 1=MPI-IO, -1=non-collective MPI-IO
itstats = 10			# interval for calculating statistics
itio = 50			# interval for writing i/o buffers
itcheck = 0			# interval for check-pointing (0=off)
itstop = 0			# for testing check-pointing, simulates code crash
debug = 0			# debugging flag
#out = [ 'v', 10,  1,1,1,1,  -1,-1,-1,-1 ]	# write v every 10 steps, 4D zone
#out = [ 'sl',-1,  1,1,1,1,  -1,-1,-1,-1 ]	# write final slip length, 4D zone

# **Optional 3D region arguments for input: 'cube', 'zone', or 'read'
#   when not specified, defaults to the entire volume
#   'cube',x1,y1,z1,  x2,y2,z2
#     specifies physical rectangular box by position coordinates
#   'zone',j1,k1,l1,  j2,k2,l2
#     specifies logical rectangular box by the array indices
#     negative indices count inward from nn
#     an index of zero is replaced by the hypocenter index
#   'read'
#     read from disk file in the directory 'data'
#     optional 'zone' argument

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

