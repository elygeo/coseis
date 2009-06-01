#!/usr/bin/env python
"""
Default simulation parameters
"""

# I/O and code execution parameters
np3 = 1, 1, 1			# number of processors in j k l
mpin = 1			# input:  0=separate files, 1=MPI-IO, -1=non-collective MPI-IO
mpout = 1			# output: 0=separate files, 1=MPI-IO, -1=non-collective MPI-IO
itstats = 10			# interval for calculating statistics
itio = 50			# interval for writing i/o buffers
itcheck = 0			# interval for check-pointing (0=off)
itstop = 0			# for testing check-pointing, simulates code crash
debug = 0			# >0 verbose, >1 sync, >2 mpi vars, >3 I/O

# Wave model parameters
nn = 41, 41, 42			# number of nodes in j, k, l (double nodes counted)
nt = 41				# number of time steps
dx = 100.0, 100.0, 100.0	# spatial step length
dt = 0.0075			# time step length
tm0 = 0.0			# initial time
affine = (1.,0.,0.), (0.,1.,0.), (0.,0.,1.) # grid transformation
gridnoise = 0.0			# random noise added to mesh, assumes planar fault
oplevel = 0			# spatial difference operator level (see below)
vdamp = -1.0			# Vs dependent damping
hourglass = 1.0, 1.0		# hourglass stiffness (1) and viscosity (2)
fieldio = [			# field I/O (see below)
    ( '=', 'rho', [], 2670.0 ),	# density
    ( '=', 'vp',  [], 6000.0 ),	# P-wave speed
    ( '=', 'vs',  [], 3464.0 ),	# S-wave speed
    ( '=', 'gam', [],    0.0 ),	# viscosity
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
bc1 = 0, 0, 0			# boundary condition - near side (see below)
bc2 = 0, 0, 0			# boundary condition - far side (see below)
xhypo = 0.0, 0.0, 0.0		# hypocenter coordinates
ihypo = 0, 0, 0			# hypocenter indices (with fractional values), 0 = center
fixhypo = 1			# lock xhypo/ihypo: 1 shift xhypo, -1 shift mesh, 0 unlocked
rexpand = 1.06			# grid expansion ratio
n1expand = 0, 0, 0		# number of grid expansion nodes - near side
n2expand = 0, 0, 0		# number of grid expansion nodes - far side

# Dynamic rupture parameters
faultnormal = 0			# normal direction to fault plane (0=no fault)
faultopening = 0		# 0=not allowed, 1=allowed
slipvector = 1.0, 0.0, 0.0	# shear traction direction for ts1
vrup = 3184.9			# nucleation rupture velocity
rcrit = 1000.0			# nucleation critical radius
trelax = 0.07			# nucleation relaxation time
svtol = 0.001			# slip velocity considered rupturing

# Finite source parameters
src_type = 'potency'		# 'moment', 'potency', 'force', or 'none'
src_n = 0			# number of sub-faults

# Point source parameters
src_w1 = 0.0, 0.0, 0.0		# normal components
src_w2 = 0.0, 0.0, 0.0		# shear components
src_function = 'none'		# time function, see util.f90 for details.
src_period = 10 * dt		# dominant period

# Spatial difference operator level:
#
#   0: Auto pick 2 or 6
#   1: Mesh with constant spacing dx
#   2: Rectangular mesh
#   3: Parallelepiped mesh
#   4: One-point quadrature
#   5: Exactly integrated elements
#   6: Saved operators, nearly as fast as 2, but doubles the memory usage


# Boundary conditions:
#
#   0: Vacuum free surface: zero cell stress
#   1: Mirror symmetry at the node
#   2: Mirror symmetry at the cell
#  -1: Anti-mirror symmetry at the node, useful for nodal planes
#  -2: Anti-mirror symmetry at the cell, useful for nodal planes and fault planes
#   3: Rigid boundary: zero node displacement
#   4: Continue
#  10: PML absorbing


# Field I/O specification:
#
#   ( '=',   'f', [j,k,l,t], val ):                   Set to value
#   ( '=s',  'f', [j,k,l,t], val ):                   Set to random numbers between 0 and val
#   ( '=x',  'f', [j,k,l,t], val, x ):                Set to value at neartest node/cell to x 
#   ( '=sx', 'f', [j,k,l,t], val, x ):                Set to random number at nearest node/cell
#   ( '=c',  'f', [j,k,l,t], val, x1, x2 ):           Set to value inside Cartesian cube
#   ( '=f',  'f', [j,k,l,t], val, tfunc, T ):         Set to time function with period T
#   ( '=fs', 'f', [j,k,l,t], val, tfunc, T ):         Set to time function * random number
#   ( '=fx', 'f', [j,k,l,t], val, tfunc, T, x ):      Set to time function at nearest node/cell
#   ( '=fc', 'f', [j,k,l,t], val, tfunc, T, x1, x2 ): Set to time function inside Cartesian cube
#   ( '=r',  'f', [j,k,l,t], filename ):              Read from filename
#   ( '=w',  'f', [j,k,l,t], filename ):              Write to filename
#   ( '=rx', 'f', [j,k,l,t], filename, x ):           Read at nearest node/cell to x
#   ( '=wx', 'f', [j,k,l,t], filename, x ):           Write at nearest node/cell to x
#
# 'f' is the field name. Options are listed in fieldnames.py.
#
# Input can be added to the existing value by specifying '+' instead of '='.
#
# [j,k,l,t] are 1-based (Fortran style) indices.
# Indices can be a single index, a range (start,end) or a strided range (start,end,step).
# Negative indices count backward from the end of the array.
# () is shorthand for (1,-1,1), i.e., the entire range, with stride 1.
# [] is shorthand for the entire array, more explicitly written as
# [(),(),(),()] or [(1,-1,1),(1,-1,1),(1,-1,1),(1,-1,1)].

# Placeholders
i1pml = None
i2pml = None

