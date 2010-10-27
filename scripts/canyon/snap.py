#!/usr/bin/env python
"""
Snapshot plots
"""
import numpy as np
import matplotlib.pyplot as plt
import cst

exp = 0.5
clim = 0.0, 0.000001
path = 'run/'
meta = cst.util.load( path + 'meta.py' )
dtype = meta.dtype
shape = meta.shapes['snap-v1.bin']
delta = meta.deltas['snap-v1.bin']
nn = shape[:2]
n = shape[0] * shape[1]
fig = plt.figure()
x = np.fromfile( path + 'x.bin', dtype ).reshape( nn[::-1] ).T
y = np.fromfile( path + 'y.bin', dtype ).reshape( nn[::-1] ).T
f1 = open( path + 'snap-v1.bin' )
f2 = open( path + 'snap-v2.bin' )

for it in range( shape[-1] ):
    vx = np.fromfile( f1, dtype, n ).reshape( nn[::-1] ).T
    vy = np.fromfile( f2, dtype, n ).reshape( nn[::-1] ).T
    vm = (vx * vx + vy * vy) ** exp
    fig.clf()
    ax = fig.add_subplot( 111 )
    ax.set_title( it * delta[-1] )
    im = ax.imshow( vm, interpolation='nearest' )
    #im.set_clim( *clim )
    fig.colorbar( im )
    fig.canvas.draw()
    fig.canvas.Update()
    fig.show()
    #fig.ginput( 1, 0, False )


