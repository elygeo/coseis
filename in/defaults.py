#!/usr/bin/env python
from sord import _

# SORD Defaults

# I/O and Code execution parameters
datadir = ''			# path to data files directory
np = 1, 1, 1			# number of processors in j k l
mpin = 1			# input:  0=separate files, 1=MPI-IO, -1=non-collective MPI-IO
mpout = 1			# output: 0=separate files, 1=MPI-IO, -1=non-collective MPI-IO
itstats = 10			# interval for calculating statistics
itio = 50			# interval for writing i/o buffers
itcheck = 0			# interval for check-pointing (0=off)
itstop = 0			# for testing check-pointing, simulates code crash
debug = 0			# debugging flag

# Wave model parameters
nn = 41, 41, 42			# nx ny nz (double nodes counted)
nt = 40				# number of time steps
dt = 0.0075			# time step length
dx = 100.			# spatial step length
affine = (1.,0.,0.), (0.,1.,0.), (0.,0.,1.) # grid transformation
gridnoise = 0.			# random noise added to mesh, assumes planar fault
oplevel = 0			# *spatial difference operator level (see below)
vdamp = -1.			# Vs dependent damping
hourglass = 1., 1.		# hourglass stiffness (1) and viscosity (2)
io = [				# *I/O sequence (see below)
  ( '=', 'rho', _[:,:,:,0], 2670.     ),	# density
  ( '=', 'vp',  _[:,:,:,0], 6000.     ),	# P-wave speed
  ( '=', 'vs',  _[:,:,:,0], 3464.1016 ),	# S-wave speed
  ( '=', 'gam', _[:,:,:,0],    0.     ),	# viscosity
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
bc1 = 0, 0, 0			# *j1 k1 l1 boundary condition (see below)
bc2 = 0, 0, 0			# *j2 k2 l2 boundary condition (see below)
ihypo = 0, 0, 0			# hypocenter node
xhypo = 0., 0., 0.		# hypocenter location
fixhypo = 1			# 0=none 1=inode, 2=icell, -1=xnode, -2=xcell
rexpand = 1.06			# grid expansion ratio
n1expand = 0, 0, 0		# n grid expansion nodes for j1 k1 l1
n2expand = 0, 0, 0		# n grid expansion nodes for j2 k2 l2

# Point source and plane wave parameters
i1source = 2, 2, 2		# finite source start index
i2source = 1, 1, 1		# finite source end index
#rfunc = 'box'			# spatial weighting: uniform
#rfunc = 'tent'			# spatial weighting: tapered
rfunc = 'point'			# point source
#tfunc = 'delta'		# source time function: delta
tfunc = 'brune'			# source time function: Brune
#tfunc = 'sbrune'		# source time function: smooth Brune
#rsource = 150.			# source radius: 1.5*dx = 8 nodes
rsource = -1.			# no moment source
tsource = 0.056			# dominant period of 8*dt
moment1 = 1e16, 1e16, 1e16	# normal components, explosion source
moment2 = 0., 0., 0.		# shear components

# Fault parameters
faultnormal = 3			# normal direction to fault plane (0=no fault)
faultopening = 0		# 0=not allowed, 1=allowed
slipvector = 1., 0., 0.		# shear traction direction for ts1
vrup = 3184.9			# nucleation rupture velocity (using Rayleigh speed here)
rcrit = 1000.			# nucleation critical radius
trelax = 0.07			# nucleation relaxation time
svtol = 0.001			# slip velocity considered rupturing
io += [				# *I/O sequence (see below)
   ( '=', 'mus', _[:,:,:,0],    0.6 ),	# coef of static friction
   ( '=', 'mud', _[:,:,:,0],    0.5 ),	# coef of dynamic friction
   ( '=', 'dc',  _[:,:,:,0],    0.4 ),	# slip-weakening distance
  #( '=', 'co',  _[:,:,:,0],    0.  ),	# cohesion
   ( '=', 'ts1', _[:,:,:,0],  -70e6 ),	# shear traction component 1
  #( '=', 'ts2', _[:,:,:,0],    0.  ),	# shear traction component 2
   ( '=', 'tn',  _[:,:,:,0], -120e6 ),	# normal traction
  #( '=', 'sxx', _[:,:,:,0],    0.  ),	# prestress Sxx
  #( '=', 'syy', _[:,:,:,0],    0.  ),	# prestress Syy
  #( '=', 'szz', _[:,:,:,0],    0.  ),	# prestress Szz
  #( '=', 'syz', _[:,:,:,0],    0.  ),	# prestress Syz
  #( '=', 'szx', _[:,:,:,0],    0.  ),	# prestress Szx
  #( '=', 'sxy', _[:,:,:,0],    0.  ),	# prestress Sxy
]

# I/O sequence types:
#   ( '=', 'f', _[....], val ):           Set array to val
#   ( '=', 'f', _[....], x1, x2, val ):   Set Cartesian cube to val
#   ( 'r', 'f', _[....], nb ):            Read array from disk
#   ( 'w', 'f', _[....], nb ):            Write array to disk
# Key:
#  'f': Field name
#   _[....]: Slice indices
#   x1: Start coordinate  ( x1, y1, z1, t1 )
#   x2: End coordinate    ( x2, y2, z2, t2 )
#   nb: Number of time steps to buffer

# Spatial difference operator level:
#   0: Auto pick 2 or 6
#   1: Mesh with constant spacing dx
#   2: Rectangular mesh
#   3: Parallelepiped mesh
#   4: One-point quadrature
#   5: Exactly integrated elements
#   6: Saved operators, nearly as fast as 2, but doubles the memory usage

# Boundary conditions:
#   0: Vacuum free surface: zero cell stress
#   1: Mirror symmetry at the node
#   2: Mirror symmetry at the cell
#  -1: Anti-mirror symmetry at the node, useful for nodal planes
#  -2: Anti-mirror symmetry at the cell, useful for nodal planes and fault planes
#   3: Rigid boundary: zero node displacement
#   4: Continue
#  10: PML absorbing

