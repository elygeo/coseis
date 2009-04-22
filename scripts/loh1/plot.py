#!/usr/bin/env python
"""
PEER LOH.1 - Plot comparison of FK and SOM.
"""
import os, numpy, pylab, scipy, scipy.signal, sord

# Parameters
so_dir = os.path.expanduser( '~/run/loh1/' )
fk_dir = 'fk/'
meta = sord.util.loadmeta( so_dir )
sig = meta.dt * 22.5
T = meta.src_period
ts = 4 * sig

# Setup plot
pylab.clf()
ax = [ pylab.subplot( 3, 1, i ) for i in 1, 2, 3 ]

# SORD results
rotation = numpy.array([[3./5., 4./5., 0.], [-4./5., 3./5., 0.], [0., 0., 1.]])
t = meta.dt * numpy.arange( meta.nt )
x = numpy.fromfile( so_dir+'out/vx', meta.dtype )
y = numpy.fromfile( so_dir+'out/vy', meta.dtype )
z = numpy.fromfile( so_dir+'out/vz', meta.dtype )
v = numpy.vstack((x,y,z))
v = numpy.dot( rotation, v )
tau = t - ts
factor = 1. - 2.*T/sig**2.*tau - ( T/sig )**2. * ( 1. - ( tau/sig )**2. );
b = ( 1. / numpy.sqrt( 2.*numpy.pi ) / sig ) * factor * numpy.exp( -0.5 * ( tau/sig ) ** 2. )
v = meta.dt * scipy.signal.lfilter( b, 1., v )
vm = numpy.sqrt( numpy.sum( v * v, 0 ) )
peakv = numpy.max( vm )
print peakv
for i in 0, 1, 2:
    pylab.axes( ax[i] )
    pylab.plot( t, v[i], 'k' )
    pylab.hold(True)

# Prose F/K results
tm = numpy.fromfile( fk_dir+'time', '<f4' )
v1 =  1e5 * numpy.fromfile( fk_dir+'v-radial', '<f4' )
v2 =  1e5 * numpy.fromfile( fk_dir+'v-transverse', '<f4' )
v3 = -1e5 * numpy.fromfile( fk_dir+'v-vertical', '<f4' )
v = numpy.vstack((v1,v2,v3))
dt = tm[1] - tm[0]
tau = tm - ts
b = ( 1. / numpy.sqrt( 2.*numpy.pi ) / sig ) * numpy.exp( -0.5 * ( tau/sig ) ** 2. )
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

