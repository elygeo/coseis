#!/usr/bin/env python
"""
Tomography Frechet kernel computation
"""
import sord

np = 1, 1, 1			# number of processors in each dimension
nn = 301, 201, 151		# number of mesh nodes, nx ny nz
nt = 1000			# number of time steps
dx = 200.			# spatial step size
dt = 0.01			# time step size
hourglass = 1., 2.		# hourglass stiffness and viscosity
bc1 = 10, 10, 10		# PML boundary conditions
bc2 = 10, 10, 0			# PML boundary conditions & free surface in Z
faultnormal = 0			# disable rupture dynamics
_src = 51, 51, 51, 0
_vol = (1,-1,3), (1,-1,3), (1,-1,3), (1,-1,5)

for _f in 'f1', 'f2', 'f3':
    fieldio = [
        ( '=r', 'rho', [],   'rho' ),		# density
        ( '=r', 'vp',  [],   'vp'  ),		# P-wave speed
        ( '=r', 'vs',  [],   'vs'  ),		# S-wave speed
        ( '=',  'gam', [],   0.    ),		# viscosity
        ( '=',  'f1', _src, 1., 'brune', 0.1 ),	# point source time function
        ( '=w', 'e11', _vol, 'g11' ),		# dG: Green's function
        ( '=w', 'e22', _vol, 'g22' ),		# dG: Green's function
        ( '=w', 'e33', _vol, 'g33' ),		# dG: Green's function
        ( '=w', 'e23', _vol, 'g23' ),		# dG: Green's function
        ( '=w', 'e31', _vol, 'g31' ),		# dG: Green's function
        ( '=w', 'e12', _vol, 'g12' ),		# dG: Green's function
    ]
    setup( locals(), argv )

_sta = 44, 7, -1
_src = 23, 11, 30
_xx, _yy, _zz = 0., 0., 0.
_yz, _zx, _xy = 0., 8., 2.

fieldio = [
    ( '=r', 'rho', [], 'rho' ),			# density
    ( '=r', 'vp',  [], 'vp'  ),			# P-wave speed
    ( '=r', 'vs',  [], 'vs'  ),			# S-wave speed
    ( '=',  'gam', [], 0.    ),			# viscosity
    ( '=',  'w11', _src, _xx, 'brune', 0.1 ),	# Moment tensor source
    ( '=',  'w22', _src, _yy, 'brune', 0.1 ),	# Moment tensor source
    ( '=',  'w33', _src, _zz, 'brune', 0.1 ),	# Moment tensor source
    ( '=',  'w23', _src, _yz, 'brune', 0.1 ),	# Moment tensor source
    ( '=',  'w31', _src, _zx, 'brune', 0.1 ),	# Moment tensor source
    ( '=',  'w12', _src, _xy, 'brune', 0.1 ),	# Moment tensor source
    ( '=w', 'u1',  _sta, 'sta-u1' ),		# ux displacement at receiver
    ( '=w', 'u2',  _sta, 'sta-u2' ),		# uy displacement at receiver
    ( '=w', 'u3',  _sta, 'sta-u3' ),		# uz displacement at receiver
    ( '=w', 'e11', _vol, 'e11' ),		# du: strain tensor
    ( '=w', 'e22', _vol, 'e22' ),		# du: strain tensor
    ( '=w', 'e33', _vol, 'e33' ),		# du: strain tensor
    ( '=w', 'e23', _vol, 'e23' ),		# du: strain tensor
    ( '=w', 'e31', _vol, 'e31' ),		# du: strain tensor
    ( '=w', 'e12', _vol, 'e12' ),		# du: strain tensor
]

sord.run( locals() )

