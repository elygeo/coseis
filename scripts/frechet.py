#!/usr/bin/env python
"""
Tomography Frechet kernel computation
"""
import sord

np3 = 1, 1, 1			# number of processors in each dimension
nn = 301, 201, 151		# number of mesh nodes, nx ny nz
nt = 1000			# number of time steps
dx = 200.0, 200.0, 200.0	# spatial step size
dt = 0.01			# time step size
hourglass = 1.0, 2.0		# hourglass stiffness and viscosity
bc1 = 10, 10, 10		# PML boundary conditions
bc2 = 10, 10, 0			# PML boundary conditions & free surface in Z
_vol = (1.5,-1.5,3), (1.5,-1.5,3), (1.5,-1.5,3), (1,-1,5)

# source
ihypo = 51.2, 50.3, 50.9
src_w1 = 1.0, 0.0, 0.0
src_type = 'force'
src_function = 'delta'

_sta = 44, 7, -1
fieldio = [
    ( '=r', 'rho', [], 'rho' ),			# density
    ( '=r', 'vp',  [], 'vp'  ),			# P-wave speed
    ( '=r', 'vs',  [], 'vs'  ),			# S-wave speed
    ( '=',  'gam', [], 0.0   ),			# viscosity
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

