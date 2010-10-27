#!/usr/bin/env python
"""
Semi-cylindrical canyon with vertically incident P-wave.
"""
import os
import cst

# model dimensions
nproc2 = 2, 1, 1			# number of processes
shape = 301, 321, 2, 6000		# nx, ny, nz, nt
delta = 0.0075, 0.0075, 0.0075, 0.002	# spatial step length

# boundary conditions
bc1 = 0,  0, 1				# free surface and mirror
bc2 = 1, -1, 1				# mirror

# material properties
hourglass = 1.0, 2.0			# hourglass stiffness and viscosity
fieldio = [
    ( '=', 'rho', [], 1.0 ),		# density
    ( '=', 'vp',  [], 2.0 ),		# P-wave speed
    ( '=', 'vs',  [], 1.0 ),		# S-wave speed
    ( '=', 'gam', [], 0.0 ),		# viscosity
]

# Ricker wavelet source, 2 s period
fieldio += [
    ( '=f', 'v2', [-1,(161,-1),0,0], 1.0, 'ricker1', 2.0 ),
]

# read mesh from disk
fieldio += [
    ( '=R', 'x1', [0,0,1,0], 'x.bin' ),
    ( '=R', 'x2', [0,0,1,0], 'y.bin' ),
]

# specify output
for c in '12':
    fieldio += [
        ( '=w', 'u' + c, [-1,-1,1,0], 'source-u%s.bin' % c ),
        ( '=w', 'u' + c, [1,0,1,0], 'canyon-u%s.bin' % c ),
        ( '=w', 'u' + c, [(2,158),1,1,0], 'flank-u%s.bin' % c ),
        ( '=w', 'v' + c, [0,0,1,(1,-1,10)], 'snap-v%s.bin' % c ),
        ( '=w', 'u' + c, [0,0,1,(1,-1,10)], 'snap-u%s.bin' % c ),
    ]

# continue if command line
if __name__ == '__main__':

    # stage job, copy mesh files, and run job
    rundir = os.path.join( 'run', 'sim' )
    job = cst.sord.stage( locals() )
    for f in 'x.bin', 'y.bin':
        a = os.path.join( 'run', 'mesh', f )
        b = os.path.join( 'run', 'sim', f )
        os.link( a, b )
    cst.sord.run( job )

