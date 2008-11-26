#!/usr/bin/env python
"""
PEER LOH.1 - Plot comparison of FK and SOM.
"""
import math, numpy, pylab, scipy, scipy.signal, sord

# Parameters
so_dir = 'out/'
fk_dir = '../fk/'
cfg = sord.util.objectify( sord.util.load( 'conf.py' ) )
prm = sord.util.objectify( sord.util.load( 'parameters.py' ) )
sig = prm.dt * 22.5
T = prm.tsource
ts = 4 * sig

# Setup plot
pylab.clf()
ax = [ pylab.subplot( 3, 1, i ) for i in 1, 2, 3 ]

# SORD results
fdrot = numpy.array([[3./5., 4./5., 0.], [-4./5., 3./5., 0.], [0., 0., 1.]])
t = prm.dt * numpy.arange( prm.nt )
x = sord.util.ndread( so_dir+'vx', endian=cfg.endian )
y = sord.util.ndread( so_dir+'vy', endian=cfg.endian )
z = sord.util.ndread( so_dir+'vz', endian=cfg.endian )
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
    pylab.hold(True)

# Prose F/K results
tm = sord.util.ndread( fk_dir+'time', endian='l' )
v1 =  1e5 * sord.util.ndread( fk_dir+'v-radial', endian='l' )
v2 =  1e5 * sord.util.ndread( fk_dir+'v-transverse', endian='l' )
v3 = -1e5 * sord.util.ndread( fk_dir+'v-vertical', endian='l' )
v = numpy.vstack((v1,v2,v3))
dt = tm[1] - tm[0]
tau = tm - ts
b = ( 1. / math.sqrt( 2.*math.pi ) / sig ) * numpy.exp( -0.5 * ( tau/sig ) ** 2. )
v = dt * scipy.signal.lfilter( b, 1., v )
vm = numpy.sqrt( numpy.sum( v * v, 0 ) )
peakv = numpy.max( vm )
print peakv
for i in 0, 1, 2:
    pylab.axes( ax[i] )
    pylab.plot( tm, v[i], 'k--' )

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
pylab.savefig( 'loh.pdf', format='pdf' )
pylab.show()

