#!/usr/bin/env python
"""
PML test problem
"""
import numpy, sord

np3 = 1, 1, 2
nt = 500
dx = 100.0, 100.0, 100.0
dt = 0.0075
hourglass = 1.0, 1.0

fieldio = [
    ( '=', 'rho', [], 2670.0 ),      
    ( '=', 'vp',  [], 6000.0 ),      
    ( '=', 'vs',  [], 3464.0 ),      
    ( '=', 'gam', [],    0.0 ),      
]

timefunction = 'brune'
source = 'moment'
source1 = 1e18, 1e18, 1e18
source2 = 0, 0, 0
fixhypo = -1
ihypo = 80.5, 80.5, 80.5
bc1 = 10, 10, 10

if 1:
    nn = 81, 81, 81
    bc2 = 2, 2, 2
    affine = (1.0, 0.0, 0.0), (0.0, 1.0, 0.0), (0.0, 0.0, 1.0) # undeformed
else:
    nn = 161, 161, 161
    bc2 = 10, 10, 10
    affine = (1.0, 0.0, 0.0), (0.0, 1.0, 1.0), (0.0, 0.0, 1.0) # shear 1
    affine = (1.0, 0.0, 1.0), (0.0, 1.0, 0.0), (0.0, 0.0, 1.0) # shear 2
    affine = (1.0, 1.0, 0.0), (0.0, 1.0, 0.0), (0.0, 0.0, 1.0) # shear 3
    affine = (4.0, 0.0, 0.0), (0.0, 1.0, 0.0), (0.0, 0.0, 1.0) # 1D strain
    affine = (2.5, 0.0, 0.9), (0.0, 1.0, 0.0), (0.0, 0.0, 1.6) # 2D strain
    affine = (2.0, 0.5, 0.5), (0.0, 1.5, 1.0 / 6), (0.0, 0.0, 4.0 / 3) # 3D strain

a = numpy.array( affine ).T
b = numpy.linalg.inv( a )
i = numpy.array( ihypo )
d = -6000.0 / dx[0]
i1_ = list( i + sord.coord.matmul( [[d, 0, 0]], b )[0] )
i2_ = list( i + sord.coord.matmul( [[d, d, 0]], b )[0] )
i3_ = list( i + sord.coord.matmul( [[d, d, d]], b )[0] )

for f in 'x1', 'x2', 'x3', 'v1', 'v2', 'v3':
    fieldio += [
        ( '=wi', f, i1_, 'i1_' + f ),
        ( '=wi', f, i2_, 'i2_' + f ),
        ( '=wi', f, i3_, 'i3_' + f ),
        ( '=wx', f, [], 'p1_' + f, (-6001.0,    -1.0,    -1.0) ),
        ( '=wx', f, [], 'p2_' + f, (-6001.0, -6001.0,    -1.0) ),
        ( '=wx', f, [], 'p3_' + f, (-6001.0, -6001.0, -6001.0) ),
        ( '=w',  f, [(), (), ihypo[2], ()], 'surf_' + f ),
    ]

sord.run( locals() )

