#!/usr/bin/env python
"""
Explosion test snapshot plots
"""
import numpy, pylab, sord

exp = 0.5
clim = 0.0, 0.000001
path = 'tmp/1'
meta = sord.util.loadmeta( path )
f1 = open( path + '/out/snap_v1' )
f2 = open( path + '/out/snap_v2' )
f3 = open( path + '/out/snap_v3' )
nn = meta.shape['snap_v1']
ii = meta.indices['snap_v1']
dt = meta.dt * ii[-1][-1]
n  = numpy.product( nn[:-1] )
fig = pylab.gcf()

for it in range( nn[-1] ):
    v1 = numpy.fromfile( f1, meta.dtype, n ).reshape( nn[-2::-1] ).T
    v2 = numpy.fromfile( f2, meta.dtype, n ).reshape( nn[-2::-1] ).T
    v3 = numpy.fromfile( f3, meta.dtype, n ).reshape( nn[-2::-1] ).T
    v  = ( v1 * v1 + v2 * v2 + v3 * v3 ) ** exp
    fig.clf()
    ax = fig.add_subplot( 111 )
    ax.set_title( it * dt )
    im = ax.imshow( v, interpolation='nearest' )
    #im.set_clim( *clim )
    fig.colorbar( im )
    fig.canvas.draw()
    fig.ginput( 1, 0, False )

