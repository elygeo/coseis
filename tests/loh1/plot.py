#!/usr/bin/env python
"""
PEER LOH.1 - Plot comparison of FK and SOM.
"""
import math, numpy, pylab, scipy, scipy.signal, sord

# Parameters
p = sord.util.objectify( sord.util.load( 'run/parameters.py' ) )
sig = p.dt * 22.5
T = p.tsource
ts = 4 * sig

# Setup plot
pylab.clf()
ax  = [ pylab.subplot( 3, 1, 1 ) ]
pylab.title( 'Radial',     position=(.98,.83), ha='right', va='center' )
ax += [ pylab.subplot( 3, 1, 2 ) ]
pylab.title( 'Transverse', position=(.98,.83), ha='right', va='center' )
pylab.ylabel( 'Velocity (m/s)' )
ax += [ pylab.subplot( 3, 1, 3 ) ]
pylab.title( 'Vertical',   position=(.98,.83), ha='right', va='center' )
pylab.xlabel( 'Time (/s)' )

# Prose F/K results
fkrot = 1e5 * numpy.array([[0., 1., 0.], [0., 0., 1.], [-1., 0., 0.]])
t = sord.util.ndread( 'fk-t',  endian='l' )
x = sord.util.ndread( 'fk-v1', endian='l' )
y = sord.util.ndread( 'fk-v2', endian='l' )
z = sord.util.ndread( 'fk-v3', endian='l' )
v = numpy.vstack((x,y,z))
v = numpy.dot( fkrot, v )
dt = t[1] - t[0]
tau = t - ts
b = ( 1. / math.sqrt( 2.*math.pi ) / sig ) * numpy.exp( -0.5 * ( tau/sig ) ** 2. )
v = dt * scipy.signal.lfilter( b, 1., v )
vm = numpy.sqrt( numpy.sum( v * v, 0 ) )
peakv = numpy.max( vm )
for i in 0, 1, 2:
    pylab.axes( ax[i] )
    pylab.plot( t, v[i], '--' )
    pylab.xlim( 1.5, 8.5 )
    pylab.ylim( -1, 1 )
    pylab.hold()

pylab.draw()
pylab.show()
