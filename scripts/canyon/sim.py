#!/usr/bin/env python
"""
Semi-cylindrical canyon with vertically incident P-wave.
"""
import sord, mesh

# model dimensions
np3 = 2, 1, 1			# number of processes
nn = 301, 321, 2		# number of mesh nodes
nt = 6000			# number of time steps
dt = 0.002			# time step length
dx = 0.0075, 0.0075, 0.0075	# spatial step length

# boundary conditions
bc1 = 0,  0, 1			# free surface and mirror
bc2 = 1, -1, 1			# mirror

# material properties
hourglass = 1.0, 2.0		# hourglass stiffness and viscosity
fieldio = [
    ( '=', 'rho', [], 1.0 ),	# density
    ( '=', 'vp',  [], 2.0 ),	# P-wave speed
    ( '=', 'vs',  [], 1.0 ),	# S-wave speed
    ( '=', 'gam', [], 0.0 ),	# viscosity
]

# Ricker wavelet source, 2 s period
fieldio += [
    ( '=f', 'v2', [-1,(161,-1),0,0], 1.0, 'ricker1', 2.0 ),
]

# read mesh from disk
fieldio += [
    ( '=R', 'x1', [0,0,1,0], 'x' ),
    ( '=R', 'x2', [0,0,1,0], 'y' ),
]

# specify output
for c in '12':
    fieldio += [
        ( '=w', 'u'+c, [-1,-1,1,0], 'source-u'+c ),
        ( '=w', 'u'+c, [1,0,1,0], 'canyon-u'+c ),
        ( '=w', 'u'+c, [(2,158),1,1,0], 'flank-u'+c ),
        ( '=w', 'v'+c, [0,0,1,(1,-1,10)], 'snap-v'+c ),
        ( '=w', 'u'+c, [0,0,1,(1,-1,10)], 'snap-u'+c ),
    ]

# continue if not imported
if __name__ == '__main__':

    # stage, save mesh to input directory, and launch
    cfg = sord.stage( locals() )
    path = cfg.rundir + '/in/'
    mesh.x.T.tofile( path + 'x' )
    mesh.y.T.tofile( path + 'y' )
    sord.launch( cfg )

