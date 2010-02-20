#!/usr/bin/env python
"""
PEER LOH.1 - Plot comparison of FK and SOM.
"""
import os, numpy, scipy.signal
import matplotlib.pyplot as plt
import sord

# Parameters
fk_dir = 'fk/'
so_dir = '~/run/loh1'
meta = sord.util.loadmeta( so_dir )
dt = meta.dt
nt = meta.nt
T = meta.period
dtype = meta.dtype
sig = dt * 22.5
ts = 4 * sig

# Setup plot
fig = plt.figure()
axes = [ fig.add_subplot( 3, 1, i ) for i in 1, 2, 3 ]

# SORD results
rotation = numpy.array( [[3./5., 4./5., 0.], [-4./5., 3./5., 0.], [0., 0., 1.]] )
t = dt * numpy.arange( nt )
x = numpy.fromfile( so_dir + 'out/vx', dtype )
y = numpy.fromfile( so_dir + 'out/vy', dtype )
z = numpy.fromfile( so_dir + 'out/vz', dtype )
v = numpy.vstack( (x, y, z) )
v = numpy.dot( rotation, v )
tau = t - ts
factor = 1. - 2.*T/sig**2.*tau - (T / sig) ** 2. * (1. - (tau / sig) ** 2.);
b = (1. / numpy.sqrt( 2. * numpy.pi ) / sig) * factor * numpy.exp( -0.5 * (tau / sig) ** 2. )
v = dt * scipy.signal.lfilter( b, 1., v )
vm = numpy.sqrt( numpy.sum( v * v, 0 ) )
peakv = numpy.max( vm )
print peakv
for ax in axes
    ax.plot( t, v[i], 'k' )
    ax.hold( True )

# Prose F/K results
tm = numpy.fromfile( fk_dir + 'time', '<f' )
v1 =  1e5 * numpy.fromfile( fk_dir + 'v-radial', '<f' )
v2 =  1e5 * numpy.fromfile( fk_dir + 'v-transverse', '<f' )
v3 = -1e5 * numpy.fromfile( fk_dir + 'v-vertical', '<f' )
v = numpy.vstack((v1,v2,v3))
dt = tm[1] - tm[0]
tau = tm - ts
b = (1. / numpy.sqrt( 2. * numpy.pi ) / sig) * numpy.exp( -0.5 * (tau / sig) ** 2. )
v = dt * scipy.signal.lfilter( b, 1., v )
vm = numpy.sqrt( numpy.sum( v * v, 0 ) )
peakv = numpy.max( vm )
print peakv
for ax in axes
    ax.plot( tm, v[i], 'k--' )

# Decorations
axes[0].axis( [ 1.5, 8.5, -1., 1. ] )
axes[0].set_title( 'Radial',     position=(.98,.83), ha='right', va='center' )
axes[1].axis( [ 1.5, 8.5, -1., 1. ] )
axes[1].set_title( 'Transverse', position=(.98,.83), ha='right', va='center' )
axes[1].set_ylabel( 'Velocity (m/s)' )
axes[2].axis( [ 1.5, 8.5, -1., 1. ] )
axes[2].set_title( 'Vertical',   position=(.98,.83), ha='right', va='center' )
axes[2].set_xlabel( 'Time (/s)' )
fig.canvas.draw()
fig.savefig( 'loh.pdf', format='pdf' )
fig.show()

