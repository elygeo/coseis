"""
Default simulation parameters

Spatial difference operator level:

  0: Auto pick 2 or 6
  1: Mesh with constant spacing dx
  2: Rectangular mesh
  3: Parallelepiped mesh
  4: One-point quadrature
  5: Exactly integrated elements
  6: Saved operators, nearly as fast as 2, but doubles the memory usage
"""

# I/O and code execution parameters
nproc3 = 1, 1, 1		# number of processors in (j, k, l)
mpin = 1			# input:  0=separate files, 1=MPI-IO, -1=non-collective MPI-IO
mpout = 1			# output: 0=separate files, 1=MPI-IO, -1=non-collective MPI-IO
itstats = 10			# interval for calculating statistics
itio = 50			# interval for writing i/o buffers
itcheck = 0			# interval for check-pointing (0=off)
itstop = 0			# for testing check-pointing, simulates code crash
itbuff = 10
debug = 0			# >0 verbose, >1 sync, >2 mpi vars, >3 I/O

# Wave model parameters
shape = 41, 41, 42, 41		# mesh size (nx, ny, nz, nt)
delta = 100.0, 100.0, 100.0, 0.0075	# step length (dx, dy, dz, dt)
tm0 = 0.0			# initial time
affine = (1.0, 0.0, 0.0), (0.0, 1.0, 0.0), (0.0, 0.0, 1.0) # grid transformation
gridnoise = 0.0			# random noise added to mesh, assumes planar fault
oplevel = 0			# spatial difference operator level
vdamp = -1.0			# Vs dependent damping
hourglass = 1.0, 1.0		# hourglass stiffness (1) and viscosity (2)
fieldio = [			# field I/O
    ('=', 'rho', [], 2670.0),	# density
    ('=', 'vp',  [], 6000.0),	# P-wave speed
    ('=', 'vs',  [], 3464.0),	# S-wave speed
    ('=', 'gam', [],    0.0),	# viscosity
]
rho1 = -1.0			# min density
rho2 = -1.0			# max density
vp1 = -1.0			# min P-wave speed
vp2 = -1.0			# max P-wave speed
vs1 = -1.0			# min S-wave speed
vs2 = -1.0			# max S-wave speed
gam1 = -1.0			# min viscosity
gam2 = 0.8			# max viscosity
npml = 10			# number of PML damping nodes
ppml = 2			# PML exponend, 1-4. Generally 2 is best.
vpml = -1.0			# PML damping velocity, <0 default to min, max V_s harmonic mean
bc1 = 0, 0, 0			# boundary condition - near side
bc2 = 0, 0, 0			# boundary condition - far side
ihypo = 0, 0, 0			# hypocenter indices (with fractional values), 0 = center
rexpand = 1.06			# grid expansion ratio
n1expand = 0, 0, 0		# number of grid expansion nodes - near side
n2expand = 0, 0, 0		# number of grid expansion nodes - far side

# Dynamic rupture parameters
faultnormal = 0			# normal direction to fault plane (0=no fault)
faultopening = 0		# 0=not allowed, 1=allowed
slipvector = 1.0, 0.0, 0.0	# shear traction direction for ts1
vrup = -1.0			# nucleation rupture velocity, negative = no nucleation
rcrit = 1000.0			# nucleation critical radius
trelax = 0.07			# nucleation relaxation time
svtol = 0.001			# slip velocity considered rupturing

# Finite source parameters
source = 'potency'		# 'moment', 'potency', 'force', or 'none'
nsource = 0			# number of sub-faults

# Point source parameters
source1 = 0.0, 0.0, 0.0		# normal components
source2 = 0.0, 0.0, 0.0		# shear components
timefunction = 'none'		# time function, see util.f90 for details.
period = 10 * delta[3]		# dominant period

# Placeholders
i1pml = None
i2pml = None

