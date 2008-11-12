#!/usr/bin/env python
"""
Default simulation parameters
"""

# I/O and Code execution parameters
np = 1, 1, 1			# number of processors in j k l
mpin = 1			# input:  0=separate files, 1=MPI-IO, -1=non-collective MPI-IO
mpout = 1			# output: 0=separate files, 1=MPI-IO, -1=non-collective MPI-IO
itstats = 10			# interval for calculating statistics
itio = 50			# interval for writing i/o buffers
itcheck = 0			# interval for check-pointing (0=off)
itstop = 0			# for testing check-pointing, simulates code crash
debug = 0			# debugging flag

# Wave model parameters
nn = 41, 41, 42			# number of nodes in j, k, l (double nodes counted)
nt = 41				# number of time steps
dx = 100.			# spatial step length
dt = 0.0075			# time step length
tm0 = 0.			# initial time
affine = (1.,0.,0.), (0.,1.,0.), (0.,0.,1.) # grid transformation
gridnoise = 0.			# random noise added to mesh, assumes planar fault
oplevel = 0			# spatial difference operator level (see below)
vdamp = -1.			# Vs dependent damping
hourglass = 1., 1.		# hourglass stiffness (1) and viscosity (2)
fieldio = [			# field I/O (see below)
    ( '=', 'rho', [], 2670.     ),	# density
    ( '=', 'vp',  [], 6000.     ),	# P-wave speed
    ( '=', 'vs',  [], 3464.1016 ),	# S-wave speed
    ( '=', 'gam', [],    0.     ),	# viscosity
]
rho1 = -1.			# min density
rho2 = -1.			# max density
vp1 = -1.			# min P-wave speed
vp2 = -1.			# max P-wave speed
vs1 = -1.			# min S-wave speed
vs2 = -1.			# max S-wave speed
gam1 = -1.			# min viscosity
gam2 = 0.8			# max viscosity
npml = 10			# number of PML damping nodes
bc1 = 0, 0, 0			# boundary condition - near side (see below)
bc2 = 0, 0, 0			# boundary condition - far side (see below)
ihypo = 0, 0, 0			# hypocenter node
xhypo = 0., 0., 0.		# hypocenter location
fixhypo = 1			# 0=none 1=inode, 2=icell, -1=xnode, -2=xcell
rexpand = 1.06			# grid expansion ratio
n1expand = 0, 0, 0		# number of grid expansion nodes - near side
n2expand = 0, 0, 0		# number of grid expansion nodes - far side

# Moment source parameters
rfunc = 'point'			# space function
tfunc = 'brune'			# time function, see util.f90 for details.
rsource = -1.			# source radius
tsource = 0.056			# dominant period
moment1 = 1e16, 1e16, 1e16	# normal components
moment2 = 0., 0., 0.		# shear components

# Fault parameters
faultnormal = 3			# normal direction to fault plane (0=no fault)
faultopening = 0		# 0=not allowed, 1=allowed
slipvector = 1., 0., 0.		# shear traction direction for ts1
vrup = 3184.9			# nucleation rupture velocity
rcrit = 1000.			# nucleation critical radius
trelax = 0.07			# nucleation relaxation time
svtol = 0.001			# slip velocity considered rupturing


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
# 0 is shorthand for (1,-1,1), i.e., the entire range, with stride 1.
# [] is shorthand for the entire array, more explicitly written as [0,0,0,0],
# or [(1,-1,1),(1,-1,1),(1,-1,1),(1,-1,1)].

