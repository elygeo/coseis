#!/usr/bin/env python
import cst                                  # import the Coseis module
delta = 100.0, 100.0, 100.0, 0.0075         # step length in (x, y, z, t)
shape = 61, 61, 61, 60                      # mesh size in (x, y, z, t)
fieldio = [                                 # field variable input and output
    ( '=',  'rho', [], 2670.0 ),            # material density
    ( '=',  'vp',  [], 6000.0 ),            # material P-wave velocity
    ( '=',  'vs',  [], 3464.0 ),            # material S-wave velocity
    ( '=',  'gam', [], 0.3    ),            # material viscosity
    ( '=w', 'v1',  [0,0,31,-1], 'vx.bin' ), # write X velocity slice output
    ( '=w', 'v2',  [0,0,31,-1], 'vy.bin' ), # write Y velocity slice output
]
ihypo = 31.0, 31.0, 31.0                    # source location
source = 'potency'                          # source type
source1 = 1e6, 1e6, 1e6                     # source normal components
source2 = 0.0, 0.0, 0.0                     # source shear components
timefunction = 'brune'                      # source time function
period = 6 * delta[3]                       # source dominant period
cst.sord.run( locals() )                    # launch SORD job

# plotting
import numpy as np
import matplotlib.pyplot as plt
n  = shape[1], shape[0]
vx = np.fromfile( 'run/out/vx.bin', 'f' ).reshape( n )
vy = np.fromfile( 'run/out/vy.bin', 'f' ).reshape( n )
vm = np.sqrt( vx * vx + vy * vy )
fig = plt.figure( figsize=(3,3) )
ax = plt.gca()
ax.imshow( vm, extent=(-3,3,-3,3), interpolation='nearest', vmax=1 )
ax.axis( 'image' )
fig.savefig( 'example.png', dpi=80 )

