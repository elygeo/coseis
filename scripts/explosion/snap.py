#!/usr/bin/env ipython -wthread
"""
Explosion test snapshot plots
"""
import os
import numpy as np
import matplotlib.pyplot as plt
import cst

# parameters
exp = 0.5
clim = 0.0, 0.000001
path = os.path.join( 'run', 'point-potency' ) + os.sep

# metadata
meta = cst.util.load( path + 'meta.py' )
shape = meta.shapes['snap_v1.bin']
delta = meta.deltas['snap_v1.bin']
indices = meta.indices['snap_v1.bin']
dtype = meta.dtype

# open snapshot files
f1 = open( path + 'snap_v1.bin' )
f2 = open( path + 'snap_v2.bin' )
f3 = open( path + 'snap_v3.bin' )

# setup figure
fig = plt.figure()

# loop over time steps
for it in range( shape[-1] ):

    # read snapshot
    nn = shape[1], shape[0]
    n = shape[0] * shape[1]
    x = np.fromfile( f1, dtype, n ).reshape( nn ).T
    y = np.fromfile( f2, dtype, n ).reshape( nn ).T
    z = np.fromfile( f3, dtype, n ).reshape( nn ).T
    s = (x * x + y * y + z * z) ** exp

    # plot image
    fig.clf()
    ax = fig.add_subplot( 111 )
    ax.set_title( it * delta[-1] )
    im = ax.imshow( s, interpolation='nearest' )
    fig.colorbar( im )
    if clim:
        im.set_clim( *clim )

    # wait for mouse click
    fig.canvas.draw()
    fig.ginput( 1, 0, False )

