#!/usr/bin/env python
"""
Explosion test plot
"""
import numpy, pylab, sord

rho, vp, vs = 2670.0, 6000.0, 3464.0
runs = 'tmp/1', 'tmp/3', 'tmp/2', 'tmp/4'
stations = 'p5',
stations = 'p1', 'p2', 'p3', 'p4', 'p5', 'p6'

for path in runs:
    meta = sord.util.loadmeta( path )
    nt = meta.nt
    dt = meta.dt
    period = meta.period
    source = meta.source
    source1 = meta.source1
    cutoff = 0
    cutoff = vp / (20 * dx[0])
    if source == 'moment':
        m0 = source1[0]
    else:
        m0 = source1[0] * (3*rho*vp*vp - 4*rho*vs*vs)
    for sta in stations:
        x1 = numpy.fromfile( path + '/out/' + sta + '_x1', 'f' )
        x2 = numpy.fromfile( path + '/out/' + sta + '_x2', 'f' )
        x3 = numpy.fromfile( path + '/out/' + sta + '_x3', 'f' )
        v1 = numpy.fromfile( path + '/out/' + sta + '_v1', 'f' )
        v2 = numpy.fromfile( path + '/out/' + sta + '_v2', 'f' )
        v3 = numpy.fromfile( path + '/out/' + sta + '_v3', 'f' )
        x  = numpy.array([ x1, x2, x3 ]).squeeze()
        r  = numpy.sqrt( (x*x).sum() )
        t  = dt * numpy.arange( nt ) + 0.5 * dt
        ta = t + r / vp
        v  = numpy.array( [v1, v2, v3] ).squeeze()
        v  = sord.coord.matmul( sord.coord.rotmat( x ), v )
        va = ( m0 * numpy.exp( -t / period ) * (t * vp / r - t / period + 1.0)
             / (4.0 * numpy.pi * rho * vp**3.0 * period**2.0 * r) )
        if cutoff:
            v  = sord.lowpass( v,  dt, cutoff, 2, 1 )
            va = sord.lowpass( va, dt, cutoff, 2, 1 )
        pylab.clf()
        pylab.plot( t - dt, v.T, '-', ta - dt, va, 'k--' )
        pylab.xlim( 0.5, dt * nt )
        pylab.title( path + '   %s, %s, %s' % tuple(x) )
        pylab.draw()
        pylab.ginput(1,0,False)

pylab.xlim( 0.5, dt * nt )
pylab.draw()

