#!/usr/bin/env python
"""
Decimate surface output and compute PGV, PGD
"""
import os
import numpy as np
import meta

# metatdata
dt = meta.deltas['full-v1.bin'][-1]
nfull = meta.shapes['full-v1.bin']
nhist = meta.shapes['hist-v1.bin']
ifull = meta.indices['full-v1.bin']
ihist = meta.indices['hist-v1.bin']
isnap = meta.indices['snap-v1.bin']
dtype = meta.dtype
out = 'out' + os.sep

# decimation intervals
xdec = ihist[0][2] / ifull[0][2]
tdec = isnap[2][2] / ifull[2][2]

# open full resolution files for reading
f1 = open( out + 'full-v1.bin', 'rb' )
f2 = open( out + 'full-v2.bin', 'rb' )
f3 = open( out + 'full-v3.bin', 'rb' )

# open snapshot files for writing
s1 = open( out + 'snap-v1.bin', 'wb' )
s2 = open( out + 'snap-v2.bin', 'wb' )
s3 = open( out + 'snap-v3.bin', 'wb' )

# open time history files for writing
h1 = open( out + 'hist-v1.bin', 'wb' )
h2 = open( out + 'hist-v2.bin', 'wb' )
h3 = open( out + 'hist-v3.bin', 'wb' )

# initialize displacement, pgv, pgd arrays
nn = nfull[:2]
u1 = np.zeros( nn )
u2 = np.zeros( nn )
u3 = np.zeros( nn )
pgv = np.zeros( nn )
pgd = np.zeros( nn )
pgvh = np.zeros( nn )
pgdh = np.zeros( nn )

# loop over time steps
for it in range( nfull[-1] ):

    # read velocity
    n = nfull[0] * nfull[1]
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
    v1[::xdec,::xdec].T.tofile( h1 )
    v2[::xdec,::xdec].T.tofile( h2 )
    v3[::xdec,::xdec].T.tofile( h3 )

    # snapshots decimated in time
    if np.mod( it, tdec ) == 0:
        v1.T.tofile( s1 )
        v2.T.tofile( s2 )
        v3.T.tofile( s3 )

# close files
f1.close()
f2.close()
f3.close()
s1.close()
s2.close()
s3.close()
h1.close()
h2.close()
h3.close()

# save pgv, pgd
np.asarray( np.sqrt( pgv ), dtype ).T.tofile( 'pgv.bin' )
np.asarray( np.sqrt( pgd ), dtype ).T.tofile( 'pgd.bin' )
np.asarray( np.sqrt( pgvh ), dtype ).T.tofile( 'pgvh.bin' )
np.asarray( np.sqrt( pgdh ), dtype ).T.tofile( 'pgdh.bin' )

# free memory
del( v1, v2, v3, u1, u2, u3, pgv, pgd, pgvh, pgdh )

# transpose time history arrays
x, y, t = nhist
n = t, x * y
np.fromfile( out + 'hist-v1.bin', dtype ).reshape( n ).T.tofile( out + 'hist-v1.bin' )
np.fromfile( out + 'hist-v2.bin', dtype ).reshape( n ).T.tofile( out + 'hist-v2.bin' )
np.fromfile( out + 'hist-v3.bin', dtype ).reshape( n ).T.tofile( out + 'hist-v3.bin' )

# remove full resolution files and lock file
os.unlink( out + 'full-v1.bin' )
os.unlink( out + 'full-v2.bin' )
os.unlink( out + 'full-v3.bin' )

