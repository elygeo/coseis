#!/usr/bin/env python
"""
Find the basin depth from S-wave velocity volume.
Computes the shallowest 2D isosurface.
"""
import numpy, sord

cell = 1
val = 2500.
infile = 'in/vs'
outfile = 'out/z25'

meta = sord.util.loadmeta()
dx = abs( meta.dx[2] )
up = meta.dx[2] > 0
n1 = ( meta.nn[0] - cell ) * ( meta.nn[1] - cell )
n2 = meta.nn[2] - cell

fh = open( infile, 'rb' )
v2 = numpy.fromfile( fh, 'f', n1 )

if up:
    depth = 1e9 * numpy.ones_like( v2 )
    for j in xrange( 1, n2 ):
        v1 = v2
        v2 = numpy.fromfile( fh, 'f', n1 )
        i = ( v2 < val ) & ( v1 >= val )
        depth[i] = ( ( val - v2[i] ) / ( v1[i] - v2[i] ) + n2 - 1 - j + 0.5 * cell ) * dx
    depth[ v2 >= val ] = 0.0
else:
    depth = numpy.zeros_like( v2 )
    depth[ v2 < val ] = 1e9
    for j in xrange( 1, n2 ):
        v1 = v2
        v2 = numpy.fromfile( fh, 'f', n1 )
        i = ( depth > 1e8 ) & ( v1 < val ) & ( v2 >= val )
        depth[i] = ( ( val - v1[i] ) / ( v2[i] - v1[i] ) + j - 1 + 0.5 * cell ) * dx

depth.tofile( outfile )

if 0:
    import pylab
    pylab.imshow( depth.reshape( meta.nn[1::-1] ) ).T
    pylab.axis( 'image' )
    pylab.show()

