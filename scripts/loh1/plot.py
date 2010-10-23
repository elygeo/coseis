#!/usr/bin/env python
"""
PEER LOH.1 - Plot comparison of FK and SOM.
"""
import numpy as np
import scipy.signal
import matplotlib.pyplot as plt
import cst

# parameters
fk_dir = 'fk/'
so_dir = 'run/'
meta = cst.util.load( so_dir + 'meta.py' )
dt = meta.dt
nt = meta.nt
T = meta.period
dtype = meta.dtype
sig = dt * 22.5
ts = 4 * sig

# setup plot
fig = plt.figure()
axes = [ fig.add_subplot( 3, 1, i ) for i in 1, 2, 3 ]

# SORD results
rotation = np.array( [[3.0/5.0, 4.0/5.0, 0.0], [-4.0/5.0, 3.0/5.0, 0.0], [0.0, 0.0, 1.0]] )
t = dt * np.arange( nt )
x = np.fromfile( so_dir + 'out/vx.bin', dtype )
y = np.fromfile( so_dir + 'out/vy.bin', dtype )
z = np.fromfile( so_dir + 'out/vz.bin', dtype )
v = np.vstack( (x, y, z) )
v = np.dot( rotation, v )
tau = t - ts
factor = 1.0 - 2.0*T/sig**2.*tau - (T / sig) ** 2. * (1. - (tau / sig) ** 2.0);
b = (1.0 / np.sqrt( 2.0 * np.pi ) / sig) * factor * np.exp( -0.5 * (tau / sig) ** 2.0 )
v = dt * scipy.signal.lfilter( b, 1.0, v )
vm = np.sqrt( np.sum( v * v, 0 ) )
peakv = np.max( vm )
print peakv
for ax in axes:
    ax.plot( t, v[i], 'k' )
    ax.hold( True )

# Prose F/K results
tm = np.fromfile( fk_dir + 'time.bin', '<f' )
v1 =  1e5 * np.fromfile( fk_dir + 'v-radial', '<f' )
v2 =  1e5 * np.fromfile( fk_dir + 'v-transverse', '<f' )
v3 = -1e5 * np.fromfile( fk_dir + 'v-vertical', '<f' )
v = np.vstack((v1,v2,v3))
dt = tm[1] - tm[0]
tau = tm - ts
b = (1.0 / np.sqrt( 2.0 * np.pi ) / sig) * np.exp( -0.5 * (tau / sig) ** 2.0 )
v = dt * scipy.signal.lfilter( b, 1.0, v )
vm = np.sqrt( np.sum( v * v, 0 ) )
peakv = np.max( vm )
print peakv
for ax in axes:
    ax.plot( tm, v[i], 'k--' )

# decorations
axes[0].axis( [1.5, 8.5, -1.0, 1.0] )
axes[0].set_title( 'Radial',     position=(0.98,0.83), ha='right', va='center' )
axes[1].axis( [ 1.5, 8.5, -1., 1. ] )
axes[1].set_title( 'Transverse', position=(0.98,0.83), ha='right', va='center' )
axes[1].set_ylabel( 'Velocity (m/s)' )
axes[2].axis( [ 1.5, 8.5, -1., 1. ] )
axes[2].set_title( 'Vertical',   position=(0.98,0.83), ha='right', va='center' )
axes[2].set_xlabel( 'Time (/s)' )
fig.canvas.draw()
fig.savefig( 'loh.pdf', format='pdf' )
fig.show()

