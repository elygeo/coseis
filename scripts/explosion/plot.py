#!/usr/bin/env python
"""
Explosion test plot
"""
import os
from sord import util

dir = '~/run/explosion'
dir = os.path.expanduser( dir )
prm = util.loadmeta( dir )
m0 = meta.src_w1[0]
T = prm.src_period
pylan.clf()

for sta in 'p1_', 'p2_', 'p3_':
    x1 = numpy.fromfile( dir + '/out/' + sta + 'x1' )
    x2 = numpy.fromfile( dir + '/out/' + sta + 'x2' )
    x3 = numpy.fromfile( dir + '/out/' + sta + 'x3' )
    v1 = numpy.fromfile( dir + '/out/' + sta + 'v1' )
    v2 = numpy.fromfile( dir + '/out/' + sta + 'v2' )
    v3 = numpy.fromfile( dir + '/out/' + sta + 'v3' )
    t  = prm.dt * numpy.arange( prm.nt )
    v  = coord.matmul( coord.rotmat( [x1, x2, x3] ), [v1, v2, v3] )
    pylab.plot( t, v, 'k-' )
    pylab.hold( True )
    x  = numpy.array([ x1, x2, x3 ])
    r  = numpy.sqrt( (x*x).sum() )
    v  = m0 * numpy.exp( -t / T ) * ( t * vp / r - t / T + 1.0 ) \
       / ( 4.0 * numpy.pi * rho * vp**3.0 * T**2.0 * r )
    t  = t + r / vp
    pylab.plot( t, v, 'k--' )

pylab.draw()
pylab.savefig( 'explosion.pdf', format='pdf' )
pylab.show()

