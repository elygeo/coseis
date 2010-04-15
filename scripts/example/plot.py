#!/usr/bin/env python
import numpy as np
import matplotlib.pyplot as plt
n  = 61, 61
vx = np.fromfile( 'tmp/out/vx', 'f' ).reshape( n )
vy = np.fromfile( 'tmp/out/vy', 'f' ).reshape( n )
vm = np.sqrt( vx * vx + vy * vy )
fig = plt.figure( figsize=(3, 3) )
ax = fig.add_subplot( 111 )
ax.imshow( vm, extent=(-3, 3, -3, 3), interpolation='nearest', vmax=1 )
ax.axis( 'image' )
f = 'tmp/example.png'
print f
fig.savefig( f, dpi=80 )

