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
vol_ = (1.5, -1.5, 3), (1.5, -1.5, 3), (1.5, -1.5, 3), (1, -1, 5)

# source
ihypo = 51.2, 50.3, 50.9
source1 = 1.0, 0.0, 0.0
source = 'force'
timefunction = 'delta'

sta_ = 44, 7, -1
fieldio = [
    ( '=r', 'rho', [], 'rho' ),			# density
    ( '=r', 'vp',  [], 'vp'  ),			# P-wave speed
    ( '=r', 'vs',  [], 'vs'  ),			# S-wave speed
    ( '=',  'gam', [], 0.0   ),			# viscosity
    ( '=w', 'u1',  sta_, 'sta-u1' ),		# ux displacement at receiver
    ( '=w', 'u2',  sta_, 'sta-u2' ),		# uy displacement at receiver
    ( '=w', 'u3',  sta_, 'sta-u3' ),		# uz displacement at receiver
    ( '=w', 'e11', vol_, 'e11' ),		# du: strain tensor
    ( '=w', 'e22', vol_, 'e22' ),		# du: strain tensor
    ( '=w', 'e33', vol_, 'e33' ),		# du: strain tensor
    ( '=w', 'e23', vol_, 'e23' ),		# du: strain tensor
    ( '=w', 'e31', vol_, 'e31' ),		# du: strain tensor
    ( '=w', 'e12', vol_, 'e12' ),		# du: strain tensor
]

sord.run( locals() )

