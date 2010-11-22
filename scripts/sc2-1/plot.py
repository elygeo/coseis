#!/usr/bin/env python
"""
PEER Linelines program task 1A02, Problem SC2.1
"""
import os
import numpy as np
import scipy.signal
import matplotlib.pyplot as plt
import cst

# parameters
path = 'run' + os.sep
meta = os.path.join( path, 'meta.py' )
meta = cst.util.load( meta )
dt = meta.delta[-1]
nt = meta.shape[-1]
T = meta.period
dtype = meta.dtype
sigma = 0.5

# read time history
x = np.fromfile( path + 'p5-v1.bin', dtype )
y = np.fromfile( path + 'p5-v2.bin', dtype )
z = np.fromfile( path + 'p5-v3.bin', dtype )
v = np.array( [x, y, z] ) # XXX transpose?
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
factor = ( 1.0 - 2.0 * T / sigma ** 2.0 * tau
    - (T / sigma) ** 2.0 * (1.0 - (tau / sigma) ** 2.0) )
b = ( (1.0 / np.sqrt( 2.0 * np.pi ) / sigma) * factor
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
fig.savefig( 'sc2-1.pdf', format='pdf' )
fig.show()

