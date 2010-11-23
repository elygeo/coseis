#!/usr/bin/env python
"""
PEER LOH.1 - Plot comparison of FK and SOM.
"""
import os
import numpy as np
import scipy.signal
import matplotlib.pyplot as plt
import cst

# parameters
path = 'run' + os.sep
meta = os.path.join( path, 'meta.py' )
meta = cst.util.load( 'meta.py' )
dt = meta.delta[-1]
nt = meta.shape[-1]
T = meta.period
dtype = meta.dtype
sigma = dt * 22.5

# setup figure
fig = plt.figure()
ax = [fig.add_subplot( 3, 1, i ) for i in 1, 2, 3]
ax[2].set_xlabel( 'Time (/s)' )
ax[1].set_ylabel( 'Velocity (m/s)' )
ax[0].set_title( 'Radial',     position=(0.98, 0.83), ha='right', va='center' )
ax[1].set_title( 'Transverse', position=(0.98, 0.83), ha='right', va='center' )
ax[2].set_title( 'Vertical',   position=(0.98, 0.83), ha='right', va='center' )

# read SORD results
x = np.fromfile( path + 'vx.bin', dtype )
y = np.fromfile( path + 'vy.bin', dtype )
z = np.fromfile( path + 'vz.bin', dtype )
v = np.array( [x, y, z] )
t = dt * np.arange( nt )

# rotate to radial coordinates
rotation = np.array( [
    (3.0 / 5.0, 4.0 / 5.0, 0.0),
    (-4.0 / 5.0, 3.0 / 5.0, 0.0),
    (0.0, 0.0, 1.0),
] )
v = np.dot( rotation, v )

# replace Brune source with Gaussian source
tau = t - 4.0 * sigma
G = ( 1.0 - 2.0 * T / sigma ** 2.0 * tau
    - (T / sigma) ** 2.0 * (1.0 - (tau / sigma) ** 2.0) )
b = ( (1.0 / np.sqrt( 2.0 * np.pi ) / sigma) * G
    * np.exp( -0.5 * (tau / sigma) ** 2.0 ) )
v = dt * scipy.signal.lfilter( b, 1.0, v )
print np.sqrt( np.sum( v * v, 0 ).max() )

# plot waveforms
ax[0].plot( t, v[0], 'k' )
ax[1].plot( t, v[1], 'k' )
ax[2].plot( t, v[2], 'k' )

# read Prose F/K results
p = 'fk' + os.sep
t = np.fromfile( p + 'time.bin', '<f' )
v1 =  1e5 * np.fromfile( p + 'v-radial.bin', '<f' )
v2 =  1e5 * np.fromfile( p + 'v-transverse.bin', '<f' )
v3 = -1e5 * np.fromfile( p + 'v-vertical.bin', '<f' )
v = np.array( [v1, v2, v3] ) # XXX transpose?

# convolve with Gaussian source
dt = t[1] - t[0]
tau = t - 4.0 * sigma
b = ( (1.0 / np.sqrt( 2.0 * np.pi ) / sigma)
    * np.exp( -0.5 * (tau / sigma) ** 2.0 ) )
v = dt * scipy.signal.lfilter( b, 1.0, v )
print np.sqrt( np.sum( v * v, 0 ).max() )

# plot waveforms
ax[0].plot( t, v[0], 'k--' )
ax[1].plot( t, v[1], 'k--' )
ax[2].plot( t, v[2], 'k--' )

# axes limits
axis = 1.5, 8.5, -1.0, 1.0
ax[0].axis( axis )
ax[1].axis( axis )
ax[2].axis( axis )

# finish up
fig.canvas.draw()
fig.savefig( 'loh.pdf', format='pdf' )
fig.show()

