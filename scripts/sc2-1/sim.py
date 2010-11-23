#!/usr/bin/env python
"""
PEER Linelines program task 1A02, Problem SC2.1
"""
import os
import cst

# parameters
dx_ = 200.0;  nproc3 = 1, 3, 160
dx_ = 500.0;  nproc3 = 1, 1, 64
dx_ = 1000.0; nproc3 = 1, 1, 1
dx_ = 100.0;  nproc3 = 1, 20, 100

# path
rundir = os.path.join( 'run', 'sim', '%.0f' % dx_ )

# mesh metadata
mesh_ = os.path.join( 'run', 'mesh', '%.0f' % dx_ ) + os.sep
meta = cst.util.load( mesh_ + 'meta.py' )
delta = meta.delta
shape = meta.shape

# dimensions
dt_ = dx_ / 16000.0
dt_ = dx_ / 20000.0
nt_ = int( 50.0 / dt_ + 1.00001 )
delta += (dt_,)
shape += (nt_,)

# moment tensor source
x = 56000.0 / dx_
y = 40000.0 / dx_
z = 14000.0 / dx_
ihypo = x, y, z
source = 'moment'
timefunction = 'brune'
period = 0.2
source1 = 0.0, 0.0, 0.0
source2 = 0.0, 0.0, 1e18

# boundary conditions
bc1 = 10, 10, 0
bc2 = 10, 10, 10

# material
hourglass = 1.0, 1.0
vp1 = 600.0
vs1 = 200.0
fieldio = [
    ( '=r', 'rho', [], 'rho.bin' ),
    ( '=r', 'vp',  [], 'vp.bin'  ),
    ( '=r', 'vs',  [], 'vs.bin'  ),
]

# sites
for i in range( 8 ):
    j = (74.0 - 6 * i) / delta[0]
    k = (16.0 + 8 * i) / delta[1]
    fieldio += [
        ('=wi', 'v1', [j,k,1,()], 'p%s-v1.bin' % (i + 1)),
        ('=wi', 'v2', [j,k,1,()], 'p%s-v2.bin' % (i + 1)),
        ('=wi', 'v3', [j,k,1,()], 'p%s-v3.bin' % (i + 1)),
    ]

# surface output
if 0:
    fieldio += [
        ( '=w', 'v1',  [(1,-1,1), (1,-1,1), 1, (1,-1,20)], 'snap-v1.bin' ),
        ( '=w', 'v2',  [(1,-1,1), (1,-1,1), 1, (1,-1,20)], 'snap-v2.bin' ),
        ( '=w', 'v3',  [(1,-1,1), (1,-1,1), 1, (1,-1,20)], 'snap-v3.bin' ),
    ]

# run job
stagein = [mesh_ + v + '.bin' for v in 'rho', 'vp', 'vs']
post = 'rm rho.bin vp.bin vs.bin'
job = cst.sord.run( locals() )

