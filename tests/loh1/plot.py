#!/usr/bin/env python
"""
PEER LOH.1 - Plot comparison of FK and SOM.
"""
import math, numpy, pylab, scipy, scipy.signal, sord

# Parameters
cfg = sord.util.objectify( sord.util.load( 'run/conf.py' ) )
prm = sord.util.objectify( sord.util.load( 'run/parameters.py' ) )
sig = prm.dt * 22.5
T = prm.tsource
ts = 4 * sig

# Setup plot
pylab.clf()
ax = [ pylab.subplot( 3, 1, i ) for i in 1, 2, 3 ]

# SORD results
fdrot = numpy.array([[3./5., 4./5., 0.], [-4./5., 3./5., 0.], [0., 0., 1.]])
t = prm.dt * numpy.arange( prm.nt )
x = sord.util.ndread( 'run/out/vx', endian=cfg.endian )
y = sord.util.ndread( 'run/out/vy', endian=cfg.endian )
z = sord.util.ndread( 'run/out/vz', endian=cfg.endian )
v = numpy.vstack((x,y,z))
v = numpy.dot( fdrot, v )
tau = t - ts
factor = 1. - 2.*T/sig**2.*tau - ( T/sig )**2. * ( 1. - ( tau/sig )**2. );
b = ( 1. / math.sqrt( 2.*math.pi ) / sig ) * factor * numpy.exp( -0.5 * ( tau/sig ) ** 2. )
v = prm.dt * scipy.signal.lfilter( b, 1., v )
vm = numpy.sqrt( numpy.sum( v * v, 0 ) )
peakv = numpy.max( vm )
print peakv
for i in 0, 1, 2:
    pylab.axes( ax[i] )
    pylab.plot( t, v[i], 'k' )
    pylab.hold()

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
print peakv
for i in 0, 1, 2:
    pylab.axes( ax[i] )
    pylab.plot( t, v[i], 'k--' )
    pylab.hold()

# Decorations
pylab.axes( ax[0] )
pylab.axis( [ 1.5, 8.5, -1., 1. ] )
pylab.title( 'Radial',     position=(.98,.83), ha='right', va='center' )
pylab.axes( ax[1] )
pylab.axis( [ 1.5, 8.5, -1., 1. ] )
pylab.title( 'Transverse', position=(.98,.83), ha='right', va='center' )
pylab.ylabel( 'Velocity (m/s)' )
pylab.axes( ax[2] )
pylab.axis( [ 1.5, 8.5, -1., 1. ] )
pylab.title( 'Vertical',   position=(.98,.83), ha='right', va='center' )
pylab.xlabel( 'Time (/s)' )
pylab.draw()
pylab.show()
