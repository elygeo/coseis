#!/usr/bin/env python
"""
LOH.1 - Plot FK/SOM comparison.
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
sigma = dt * 22.5

# setup figure
plt.rcdefaults()
plt.rc( 'font', size=7 )
plt.rc( 'axes', linewidth=0.5, titlesize=7 )
plt.rc( 'lines', linewidth=0.5 )
plt.rc( 'ytick.major', size=2 )
plt.rc( 'xtick.major', size=2 )
plt.rc( 'legend', fontsize='medium', handletextpad=0.2 )

fig = plt.figure( None, figsize=(3.2, 3.2), dpi=200 )
fig.subplots_adjust( left=0.12, right=0.92, top=0.92, bottom=0.12 )
ax = [fig.add_subplot( 3, 1, i ) for i in 1, 2, 3]

# annotations
ax[0].set_title( 'Radial',     position=(0.98, 0.75), ha='right', va='center' )
ax[1].set_title( 'Transverse', position=(0.98, 0.75), ha='right', va='center' )
ax[2].set_title( 'Vertical',   position=(0.98, 0.75), ha='right', va='center' )
ax[2].set_xlabel( 'Time (/s)' )
ax[1].set_ylabel( 'Velocity (m/s)' )
ax[0].set_xticklabels( [] )
ax[1].set_xticklabels( [] )
for i in 0, 1, 2:
    ax[i].axis( [1.5, 8.5, -1.0, 1.0] )
    ax[i].set_yticks( [-1, -0.5, 0, 0.5, 1] )
    ax[i].set_yticklabels( [-1, '', 0, '', 1] )

# read SORD results
x = np.fromfile( path + 'p9-v1.bin', dtype )
y = np.fromfile( path + 'p9-v2.bin', dtype )
z = np.fromfile( path + 'p9-v3.bin', dtype )
v = np.array( [x, y, z] )
t = dt * np.arange( nt )

# rotate to radial coordinates
m = (3, 4, 0), (-4, 3, 0), (0, 0, 5)
m = np.array( m ) * 0.2
v = np.dot( m, v )

# replace Brune source with Gaussian source
if 1:
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
v = np.array( [v1, v2, v3] )

# convolve with Gaussian source
dt = t[1] - t[0]
tau = t - 4.0 * sigma
b = ( (1.0 / np.sqrt( 2.0 * np.pi ) / sigma)
    * np.exp( -0.5 * (tau / sigma) ** 2.0 ) )
v = dt * scipy.signal.lfilter( b, 1.0, v )
#v = dt * np.convolve( v, b, 'same' )
print np.sqrt( np.sum( v * v, 0 ).max() )

# plot waveforms
ax[0].plot( t, v[0], 'k--' )[0].set_dashes( (2,0.5) )
ax[1].plot( t, v[1], 'k--' )[0].set_dashes( (2,0.5) )
ax[2].plot( t, v[2], 'k--' )[0].set_dashes( (2,0.5) )

# finish up
ax[1].legend( ['SOM', 'FK'], loc='lower left', frameon=False )
fig.canvas.draw()
fig.savefig( path + 'loh.1.pdf', format='pdf' )
fig.show()

