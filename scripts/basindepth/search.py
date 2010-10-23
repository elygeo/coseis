#!/usr/bin/env python
"""
Locate the shallowest 2D isosurface in a volume.
"""
import os
import numpy as np
import mesh

# parameters
val = 2500.0
cell = 0
up = 0
delta = mesh.delta
shape = mesh.shape
path = os.path.join( mesh.workdir, 'cvm4' ) + os.sep

# setup
dz = delta[2]
n1 = shape[0] * shape[1]
n2 = shape[2]

# iterate over depth planes looking for vertical isosurface crossings
fh = open( path + 'vs.bin', 'rb' )
v2 = np.fromfile( fh, 'f', n1 )
if up:
    z = 1e9 * np.ones_like( v2 )
    for j in xrange( 1, n2 ):
        v1 = v2
        v2 = np.fromfile( fh, 'f', n1 )
        i = (v2 < val) & (v1 >= val)
        z[i] = ( (val - v2[i]) / (v1[i] - v2[i]) + n2 - 1 - j + 0.5 * cell ) * dz
    z[ v2 >= val ] = 0.0
else:
    z = np.zeros_like( v2 )
    z[ v2 < val ] = 1e9
    for j in xrange( 1, n2 ):
        v1 = v2
        v2 = np.fromfile( fh, 'f', n1 )
        i = (z > 1e8) & (v1 < val) & (v2 >= val)
        z[i] = ( (val - v1[i]) / (v2[i] - v1[i]) + j - 1 + 0.5 * cell ) * dz

# write output
z.tofile( 'data/z25.bin' )

