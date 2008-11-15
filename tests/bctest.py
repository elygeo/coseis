#!/usr/bin/env python
"""
Boundary condition test
"""

import sord

debug = 3
np = 1, 1, 1
nt = 8
tsource = 0.1
tfunc = 'brune'
slipvector = 1., 0., 0.
fieldio = [
    ( '=', 'rho', [], 2670.0 ),
    ( '=', 'vp',  [], 6000.0 ),
    ( '=', 'vs',  [], 3464.0 ),
    ( '=', 'gam', [],    0.0 ),
    ( '=', 'mus', [],    0.6 ),
    ( '=', 'mud', [],    0.5 ),
    ( '=', 'dc',  [],    0.4 ),
    ( '=', 'ts',  [],  -70e6 ),
    ( '=', 'tn',  [], -120e6 ),
]
bc1 = 0, 0, 0
ihypo = 1, 1, 2
fixhypo = 0

# Test -2 and 1 with fault
faultnormal = 3
rsource = -1.
xhypo = 150., 200., 100.
nn = 4, 5, 4; bc2 =  0, 0,  0
nn = 3, 3, 3; bc2 = -2, 1, 99

sord.run( locals() )

# Test -1 and 2 with fault
faultnormal = 3
rsource = -1.
xhypo = 200., 150., 100.
nn = 5, 4, 4; bc2 =  0, 0,  0
nn = 3, 3, 3; bc2 = -1, 2, 99

# Test -2 and 2 with fault
faultnormal = 3
rsource = -1.
xhypo = 150., 150., 100.
nn = 3, 3, 3; bc2 = -2, 2, 99
nn = 4, 4, 4; bc2 =  0, 0,  0

# Test -1 and 1 with fault
faultnormal = 3
rsource = -1.
xhypo = 200., 200., 100.
nn = 5, 5, 4; bc2 =  0, 0,  0
nn = 3, 3, 3; bc2 = -1, 1, 99

# Test -1 and 1
faultnormal = 0
rsource = 100.
xhypo = 200., 200., 200.
moment1 = 0., 0., 0.
moment2 = 0., 1e18, 0.
nn = 3, 3, 3; bc2 = -1, 1, -1
nn = 5, 5, 5; bc2 =  0, 0,  0

# Test -2 and 2
faultnormal = 0
rsource = 50.
xhypo = 150., 150., 150.
moment1 = 0., 0., 0.
moment2 = 0., 1e18, 0.
nn = 3, 3, 3; bc2 = -2, 2, -2
nn = 4, 4, 4; bc2 =  0, 0,  0

# Test 1
faultnormal = 0
rsource = 100.
xhypo = 200., 200., 200.
moment1 = 1e18, 1e18, 1e18
moment2 = 0., 0., 0.
nn = 3, 3, 3; bc2 = 1, 1, 1
nn = 5, 5, 5; bc2 = 0, 0, 0

