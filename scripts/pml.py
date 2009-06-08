#!/usr/bin/env python
"""
PML test problem
"""
import sord

nt = 500
dx = 100.0, 100.0, 100.0
dt = 0.0075
hourglass = 1.0, 1.0

timefunction = 'brune'
source = 'moment'
source1 = 1e18, 1e18, 1e18
source2 = 0, 0, 0
fixhypo = -1

l = 1 # FIXME
np3 = 1, 1, 2
fieldio = [
    ( '=', 'rho', [], 2670.0 ),      
    ( '=', 'vp',  [], 6000.0 ),      
    ( '=', 'vs',  [], 3464.0 ),      
    ( '=', 'gam', [],    0.0 ),      
]
for f in 'x1', 'x2', 'x3', 'v1', 'v2', 'v3':
    fieldio += [
        ( '=w',  f, [(),(),_l,()], 'surf_'+f ),
        ( '=wx', f, [], 'p1_'+f, (-6001.0,    -1.0,    -1.0) ),
        ( '=wx', f, [], 'p2_'+f, (-6001.0, -6001.0,    -1.0) ),
        ( '=wx', f, [], 'p3_'+f, (-6001.0, -6001.0, -6001.0) ),
    ]

# Rect
ihypo = 80.5, 80.5, 80.5
nn  = 81, 81, 81
bc1 = 10, 10, 10
bc2 = 2, 2, 2
bc2 = 0, 0, 0
ihypo = 0, 0, 0

sord.run( locals() )

# Non-rect
ihypo = 20.5, 20.5, 20.5 # check
nn = 40, 40, 40
affine = (1.,0.,0.), (0.,1.,1.), (0.,0.,1.) # shear, 1
affine = (1.,0.,1.), (0.,1.,0.), (0.,0.,1.) # shear, 2
affine = (1.,1.,0.), (0.,1.,0.), (0.,0.,1.) # shear, 3
# affine = ( 25., 0., 9. ), ( 0., 10., 0. ), ( 0., 0., 16. ), 10. # 2D, strain, FIXME
# affine = (  4., 0., 0. ), ( 0.,  1., 0. ), ( 0., 0.,  1. ),  1. # 1D, strain, FIXME
# affine = ( 12., 3., 3. ), ( 0.,  9., 1. ), ( 0., 0.,  8. ),  6. # 3D, strain, FIXME
bc1 = 10, 10, 10
bc2 = 10, 10, 10
bc1 = 0, 0, 0
bc2 = 0, 0, 0

# Junk
ihypo = 25.5, 25.5, 25.5
nn = 50, 50, 50
bc1 = 10, 10, 10
bc2 = 10, 10, 10

# Mixed rect
ihypo = 80.5, 80.5, 80.5
nn = 160, 160, 160
bc1 = 10, 10, 10
bc2 = 0, 0, 0

