#!/usr/bin/env python
"""
Decimate surface output and compute PGV, PGD
"""
import os, meta
import numpy as np

# parameters
nproc = 4
decimate = 4
tstep = 0.125

# locations
out = 'out' + os.sep

# metadata
dtype = meta.dtype
shape = meta.shapes['full-v1']
delta = meta.deltas['full-v1']

# decimation intervals
d = decimate
m = max( 1, int( tstep / delta[-1] + 0.5 ) )
x, y, t = delta
x_delta = x, y, m*t
t_delta = t, d*x, d*y
x, y, t = shape
t_shape = t, (x-1)/d+1, (y-1)/d+1
x_shape = x, y, (t-1)/m+1

# update metadata
open( 'meta.py', 'a' ). write(
    '\n# cooked file dimensions\n' +
    "shapes.update( {\n    'snap': %s,\n    'hist': %s,\n} )\n" % (x_shape, t_shape) +
    "deltas.update( {\n    'snap': %s,\n    'hist': %s,\n} )\n" % (x_delta, t_delta)
)

# open full resolution files for reading
f1 = open( out + 'full-v1', 'rb' )
f2 = open( out + 'full-v2', 'rb' )
f3 = open( out + 'full-v3', 'rb' )

# open snapshot files for writing
x1 = open( out + 'snap-v1', 'wb' )
x2 = open( out + 'snap-v2', 'wb' )
x3 = open( out + 'snap-v3', 'wb' )

# open time history files for writing
t1 = open( out + 'hist-v1', 'wb' )
t2 = open( out + 'hist-v2', 'wb' )
t3 = open( out + 'hist-v3', 'wb' )

# initialize displacement, pgv, pgd arrays
nn = shape[:2]
u1 = np.zeros( nn )
u2 = np.zeros( nn )
u3 = np.zeros( nn )
pgv = np.zeros( nn )
pgd = np.zeros( nn )
pgvh = np.zeros( nn )
pgdh = np.zeros( nn )

# decimate arrays and compute pgv, pgd
d  = decimate
n  = nn[0] * nn[1]
dt = delta[-1]
nt = shape[-1]

# loop over time steps
for it in range( nt ):

    # read velocity
    v1 = np.fromfile( f1, dtype, n ).reshape( nn[::-1] ).T
    v2 = np.fromfile( f2, dtype, n ).reshape( nn[::-1] ).T
    v3 = np.fromfile( f3, dtype, n ).reshape( nn[::-1] ).T

    # integrate to displacement
    u1 = u1 + dt * v1
    u2 = u2 + dt * v2
    u3 = u3 + dt * v3

    # peak ground motions
    pgv = np.maximum( pgv, v1*v1 + v2*v2 + v3*v3 )
    pgd = np.maximum( pgd, u1*u1 + u2*u2 + u3*u3 )

    # peak horizontal ground motions
    pgvh = np.maximum( pgvh, v1*v1 + v2*v2 )
    pgdh = np.maximum( pgdh, u1*u1 + u2*u2 )

    # time histories decimates in space
    v1[::d,::d].T.tofile( t1 )
    v2[::d,::d].T.tofile( t2 )
    v3[::d,::d].T.tofile( t3 )

    # snapshots decimated in time
    if np.mod( it, m ) == 0:
        v1.T.tofile( x1 )
        v2.T.tofile( x2 )
        v3.T.tofile( x3 )

# close files
f1.close()
f2.close()
f3.close()
x1.close()
x2.close()
x3.close()
t1.close()
t2.close()
t3.close()

# save pgv, pgd
np.asarray( np.sqrt( pgv ), dtype ).T.tofile( 'pgv' )
np.asarray( np.sqrt( pgd ), dtype ).T.tofile( 'pgd' )
np.asarray( np.sqrt( pgvh ), dtype ).T.tofile( 'pgvh' )
np.asarray( np.sqrt( pgdh ), dtype ).T.tofile( 'pgdh' )

# free memory
del( v1, v2, v3, u1, u2, u3, pgv, pgd, pgvh, pgdh )

# transpose time history arrays
t, x, y = t_shape
n = t, x * y
np.fromfile( out + 'hist-v1', dtype ).reshape( n ).T.tofile( out + 'hist-v1' )
np.fromfile( out + 'hist-v2', dtype ).reshape( n ).T.tofile( out + 'hist-v2' )
np.fromfile( out + 'hist-v3', dtype ).reshape( n ).T.tofile( out + 'hist-v3' )

# remove full resolution files and lock file
os.unlink( out + 'full-v1' )
os.unlink( out + 'full-v2' )
os.unlink( out + 'full-v3' )

