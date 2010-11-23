#!/usr/bin/env python
"""
PEER Lifelines program task 1A02, Problem SC2.1
"""
import os
import numpy as np
import scipy.signal
import matplotlib.pyplot as plt
import cst

# parameters
path = os.path.join( 'run', 'sim', '100' ) + os.sep
path = os.path.join( 'run', 'sim', '200' ) + os.sep
path = os.path.join( 'run', 'sim', '2000' ) + os.sep
path = os.path.join( 'run', 'sim', '500' ) + os.sep
meta = os.path.join( path, 'meta.py' )
meta = cst.util.load( meta )
dt = meta.delta[-1]
nt = meta.shape[-1]
T = meta.period
dtype = meta.dtype
sigma = 0.5

# read time history
x = np.fromfile( path + 'p4-v1.bin', dtype )
y = np.fromfile( path + 'p4-v2.bin', dtype )
z = np.fromfile( path + 'p4-v3.bin', dtype )
v = np.array( [x, y, z] )
t = dt * np.arange( nt )

# rotate to radial coordinates
m = (-3, 4, 0), (-4, -3, 0), (0, 0, 5)
m = np.array( m ) * 0.2
v = np.dot( m, v )

# replace Brune source with Gaussian source
tau = t - 4.0 * sigma
G = ( 1.0 - 2.0 * T / sigma ** 2.0 * tau
    - (T / sigma) ** 2.0 * (1.0 - (tau / sigma) ** 2.0) )
b = ( (1.0 / np.sqrt( 2.0 * np.pi ) / sigma) * G
    * np.exp( -0.5 * (tau / sigma) ** 2.0 ) )
v = dt * scipy.signal.lfilter( b, 1.0, v )
print np.sqrt( np.sum( v * v, 0 ).max() )

# setup figure
fig = plt.figure()
ax = [fig.add_subplot( 3, 1, i ) for i in 1, 2, 3]
ax[2].set_xlabel( 'Time (/s)' )
ax[1].set_ylabel( 'Velocity (m/s)' )
ax[0].set_title( 'Radial',     position=(0.98, 0.83), ha='right', va='center' )
ax[1].set_title( 'Transverse', position=(0.98, 0.83), ha='right', va='center' )
ax[2].set_title( 'Vertical',   position=(0.98, 0.83), ha='right', va='center' )

# plot waveforms
ax[0].plot( t[:v[0].size], v[0], 'k' )
ax[1].plot( t[:v[1].size], v[1], 'k' )
ax[2].plot( t[:v[2].size], v[2], 'k' )

# axes limits
if 0:
    axis = 0, 50, -0.1, 0.1
    ax[0].axis( axis )
    ax[1].axis( axis )
    ax[2].axis( axis )

# finish up
fig.canvas.draw()
fig.savefig( path + 'sc2.1.pdf', format='pdf' )
fig.show()

