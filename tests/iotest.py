#!/usr/bin/env python
"""
I/O test
"""

import sord

nt = 10
nn = 50, 50, 50
np = 4, 4, 2
mpin  = 1
mpout = 1
faultnormal = 3
fieldio = []
for _f in 'su1', 'su2', 'su3', 'sv1', 'sv2', 'sv3', 'sa1', 'sa2', 'sa3':
    fieldio += [
        ( '=w', _f, [], _f ),
    ];
for _f in 'u1', 'u2', 'u3', 'v1', 'v2', 'v3', 'a1', 'a2', 'a3':
    fieldio += [
        ( '=w', _f, [1,0,0,0], 'x_'+_f ),
        ( '=w', _f, [0,1,0,0], 'y_'+_f ),
        ( '=w', _f, [0,0,1,0], 'z_'+_f ),
    ]

sord.run( locals() )

