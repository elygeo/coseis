#!/usr/bin/env python
"""
Snapshot plots
"""
import os
import numpy as np
import matplotlib.pyplot as plt
import cst

# parameters
file = 'hold/xsec-ew-vs.bin'
file = 'hold/xsec-ns-vs.bin'
file = 'hold/xsec-ns-v3.bin'
file = 'hold/xsec-ns-v1.bin'
file = 'hold/xsec-ew-v3.bin'
clim = 0.0, 0.000001
clim = None
path = os.path.join( 'run', 'sim', 'chino-cvm-1000-flat' ) + os.sep
path = os.path.join( 'run', 'sim', 'chino-cvm-4000-flat' ) + os.sep

# metadata
meta = cst.util.load( path + 'meta.py' )
shape = meta.shapes[file]
delta = meta.deltas[file]
dtype = meta.dtype

# open snapshot files
f1 = open( path + file )

# setup figure
fig = plt.figure()

# loop over time steps
for it in range( shape[-1] ):

    # read snapshot
    nn = shape[1], shape[0]
    n = shape[0] * shape[1]
    s = np.fromfile( f1, dtype, n ).reshape( nn )

    # plot image
    fig.clf()
    ax = fig.add_subplot( 111 )
    ax.set_title( '%s %s' % (file, it * delta[-1]) )
    im = ax.imshow( s, interpolation='nearest' )
    fig.colorbar( im )
    if clim:
        im.set_clim( *clim )

    # wait for mouse click
    fig.canvas.draw()
    fig.canvas.Update()
    fig.show()
    fig.ginput( 1, 0, False )

