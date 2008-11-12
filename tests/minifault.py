#!/usr/bin/env python
"""
Miniture fault problem
"""

import sys
sys.path.insert( 0, '../..' )
import sord

nt = 0
debug = 3
faultnormal = 2
np = 2, 2, 3
np = 1, 3, 4
nn = 3, 6, 3
ihypo = 2, 2, 2
gridnoise = -0.1
gridnoise = 0.1

# affine = ( 1., 0., 1. ), ( 1., 1., 0. ), ( 0., 0., 1. )
# n1expand = 2, 2, 2
# n2expand = 2, 2, 2

fieldio = []
for _f in sord.fieldnames.all:
    fieldio += [ ( '=w', _f, [], _f ) ]

sord.run( locals() )

