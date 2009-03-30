#!/usr/bin/env python
"""
Boundary condition test
"""

import sord

debug = 3
np3 = 1, 1, 1
nt = 8
source = 'moment'
tsource = 0.1
slipvector = 1.0, 0.0, 0.0
fieldio = [
    ( '=', 'rho', [], 2670.0 ),
    ( '=', 'vp',  [], 6000.0 ),
    ( '=', 'vs',  [], 3464.0 ),
    ( '=', 'gam', [], 0.0    ),
    ( '=', 'mus', [], 0.6    ),
    ( '=', 'mud', [], 0.5    ),
    ( '=', 'dc',  [], 0.4    ),
    ( '=', 'ts',  [],  -70e6 ),
    ( '=', 'tn',  [], -120e6 ),
]
bc1 = 0, 0, 0

# Test -2 and 1 with fault
faultnormal = 3
tfunc = ''
ihypo = 2.5, 3, 2.5
nn = 4, 5, 4; bc2 =  0, 0,  0
nn = 3, 3, 3; bc2 = -2, 1, 99

sord.run( locals() )

# Test -1 and 2 with fault
faultnormal = 3
tfunc = ''
ihypo = 3, 2.5, 2.5
nn = 5, 4, 4; bc2 =  0, 0,  0
nn = 3, 3, 3; bc2 = -1, 2, 99

# Test -2 and 2 with fault
faultnormal = 3
tfunc = ''
ihypo = 2.5, 2.5, 2.5
nn = 3, 3, 3; bc2 = -2, 2, 99
nn = 4, 4, 4; bc2 =  0, 0,  0

# Test -1 and 1 with fault
faultnormal = 3
tfunc = ''
ihypo = 3, 3, 2.5
nn = 5, 5, 4; bc2 =  0, 0,  0
nn = 3, 3, 3; bc2 = -1, 1, 99

# Test -1 and 1
faultnormal = 0
tfunc = 'brune'
ihypo = 3, 3, 3
tensor1 = 0.0,  0.0, 0.0
tensor2 = 0.0, 1e18, 0.0
nn = 3, 3, 3; bc2 = -1, 1, -1
nn = 5, 5, 5; bc2 =  0, 0,  0

# Test -2 and 2
faultnormal = 0
tfunc = 'brune'
ihypo = 2.5, 2.5, 2.5
tensor1 = 0.0,  0.0, 0.0
tensor2 = 0.0, 1e18, 0.0
nn = 3, 3, 3; bc2 = -2, 2, -2
nn = 4, 4, 4; bc2 =  0, 0,  0

# Test 1
faultnormal = 0
tfunc = 'brune'
ihypo = 3, 3, 3
tensor1 = 1e18, 1e18, 1e18
tensor2 =  0.0,  0.0,  0.0
nn = 3, 3, 3; bc2 = 1, 1, 1
nn = 5, 5, 5; bc2 = 0, 0, 0

