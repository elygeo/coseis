#!/usr/bin/env python
"""
PEER LOH.1 - Plot comparison of FK and SOM.
"""

import numpy, pylab, scipy, scipy.signal, sord
import sord.util as util

p = util.objectify( util.load( 'run/parameters.py' ) )

sig = p.dt * 11.25
sig = p.dt * 45.
sig = p.dt * 28.
sig = p.dt * 22.5
T = p.tsource
ts = 4 * sig

pylab.clf()
ax = [ pylab.subplot( 3, 1, i ) for i in 1,2,3 ]

fkrot = 1e5 * numpy.array([[0., 1., 0.], [0., 0., 1.], [-1., 0., 0.]])

t = util.ndread( 'fk-t',  endian='l' )
x = util.ndread( 'fk-v1', endian='l' )
y = util.ndread( 'fk-v2', endian='l' )
z = util.ndread( 'fk-v3', endian='l' )
v = numpy.vstack((x,y,z))
v = numpy.dot( fkrot, v )
dt = t[1] - t[0]

tau = t - ts
a = ( 1. / numpy.sqrt( 2.*pi ) / sig ) * numpy.exp( -0.5 * ( tau/sig ) ** 2. )
v = dt * filter( a, 1, v )
v = scipy.signal.lfilter( 1., a, v )

vm = sqrt( numpy.sum( v * v, 0 ) )
peakv = numpy.max( vm )

#filt = 0.015 / dt
#fb, fa = scipy.signal.butter( 4, filt * 2. * dt )
#v = scipy.signal.lfilter( fb, fa, v )

for i in 0, 1, 2:
    pylab.axes( ax[i] )
    pylab.plot( t, v[i] )
    pylab.xlim( 1.5, 8.5 )
    pylab.ylim( -1, 1 )
pylab.draw()
pylab.show()
