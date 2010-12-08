#!/usr/bin/env ipython -wthread
import os
import numpy as np
import matplotlib.pyplot as plt
import cst

# metadata
path = os.path.join( 'run', '00' ) + os.sep
meta = cst.util.load( path + 'meta.py' )
dtype = meta.dtype

# off-fault displacement plot
file = 'surf.bin'
n = meta.shapes[file]
d = meta.deltas[file]
s = np.fromfile( path + file, dtype ).reshape( n[::-1] )
s = -1000.0 * s[:,2:43]
n = s.shape
extent = 0, n[0] * d[0], 0, n[1] * d[1] * 1000.0
fig = plt.figure()
ax = fig.add_subplot( 111 )
im = ax.imshow( s, interpolation='nearest', origin='lower', aspect='auto', extent=extent )
ax.set_title( 'Surface displacement (mm)' )
ax.set_xlabel( 'Distance from fault (cm)' )
ax.set_ylabel( 'Time (ms)' )
fig.colorbar( im )
fig.savefig( path + 'foam-off-fault.png' )
fig.show()

# acceleration plots
fig = plt.figure()
ax = fig.add_subplot( 111 )
for s, x, g in [
   (1, 92, 0.020074),
   (2, 72, 0.019926),
   (3, 42, 0.020350),
   (4, 22, 0.020166),
  (15,  2, 0.020773),
]:
    file = 'sensor%02d.bin' % s
    dt = meta.deltas[file][-1] * 1000.0
    a = -np.fromfile( path + file, dtype ) / 9.81
    t = np.arange( a.size ) * dt
    ax.plot( t, x + a * 0.1, 'k-' )
    ax.text( 20, x - 1, '%.0f' % abs( a ).max() )
    axis = 18, 82, 110, -20
    ax.axis( axis )
    ax.set_title( 'Acceleration' )
    ax.set_xlabel( 'Time (ms)' )
    ax.set_ylabel( 'Depth along fault (cm)' )
fig.savefig( path + 'foam-acceleration.pdf' )
fig.show()

