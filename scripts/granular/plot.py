#!/usr/bin/env python
"""
Velocity plot
"""
import os, numpy, pylab, sord
from sord.extras import viz

comp = 0
clim = 10
path = os.path.expanduser( os.path.join( '~', 'run', 'granular' ) )
path = os.path.expanduser( os.path.join( '~', 'run', 'granular-shear' ) )
path = os.path.expanduser( os.path.join( '~', 'run', 'granular-vol' ) )
meta = sord.util.loadmeta( path )
path = os.path.join( path, 'out' ) + os.sep

nn = meta['shape']['vs']
n = nn[0] * nn[1]
v = numpy.fromfile( path + 'vs', 'f' ).reshape( nn[::-1] ).T
pylab.clf()
pylab.imshow( v )
pylab.ginput( 1, 0, 0 )

nn = meta['shape']['v1'][:-1]
nt = meta['shape']['v1'][-1]
n  = nn[0] * nn[1]

f1 = open( path + 'v1', 'rb' )
f2 = open( path + 'v2', 'rb' )
f3 = open( path + 'v3', 'rb' )

for i in xrange( nt ):
    v1 = numpy.fromfile( f1, 'f', n ).reshape( nn[::-1] ).T
    v2 = numpy.fromfile( f2, 'f', n ).reshape( nn[::-1] ).T
    v3 = numpy.fromfile( f3, 'f', n ).reshape( nn[::-1] ).T
    v  = numpy.array([ v1, v2, v3 ])
    pylab.clf()
    if comp:
        v = v[comp-1]
        cmap=viz.colormap( 'w2', 2.0, 'pylab' )
        pylab.imshow( v, cmap=cmap )
        pylab.clim( -clim, clim )
    else:
        v = numpy.sqrt( (v*v).sum(0) )
        cmap=viz.colormap( 'w0', 2.0, 'pylab' )
        pylab.imshow( v, cmap=cmap )
        pylab.clim( 0, clim )
    pylab.colorbar()
    pylab.draw()
    print i, v.max()

pylab.show()

