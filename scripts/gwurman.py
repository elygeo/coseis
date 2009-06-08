#!/usr/bin/env python
"""
Wurman and Oglesby problem
"""
import sord, os

np3 = 4, 7, 2
dx = 100.0, 100.0, 100.0
dt = 0.008
nt = 3200
nn = 421, 271, 128
bc1 = 10, 10, 10
bc2 = 10, 10, 10

# material
hourglass = 1.0, 0.15
fieldio = [
  ( '=',  'rho', [], 2670.0 ),
  ( '=',  'vp',  [], 6000.0 ),
  ( '=',  'vs',  [], 3464.0 ),
  ( '=',  'gam', [], 0.15   ),
]

# rupture
ihypo = 314, 135, 64.5
faultnormal = 3;
vrup = 1500.0
rcrit = 1500.0
trelax = 0.08
j, k, l = (61,-61), (61,-61), 64
infiles = [ 'ts' ]
fieldio += [
  ( '=r', 'ts',  [], 'ts'   ),
  ( '=',  'tn',  [], -120e6 ),
  ( '=',  'td',  [], 0.0    ),
  ( '=',  'mus', [], 1e4    ),
  ( '=',  'mud', [], 1e4    ),
  ( '=',  'mus', [j,k,l,()], 0.677  ),
  ( '=',  'mud', [j,k,l,()], 0.4    ),
]

# output
fieldio += [
  ( '=w', 'x1',  [j,k,l,()], 'x1' ),
  ( '=w', 'x2',  [j,k,l,()], 'x2' ),
  ( '=w', 'su1', [j,k,l,-1], 'su1' ),
  ( '=w', 'su2', [j,k,l,-1], 'su2' ),
  ( '=w', 'sv1', [j,k,l,-1], 'sv1' ),
  ( '=w', 'sv2', [j,k,l,-1], 'sv2' ),
  ( '=w', 'su1', [j,k,l,250], 'su1-2s' ),
  ( '=w', 'su2', [j,k,l,250], 'su2-2s' ),
  ( '=w', 'ts1', [j,k,l,(1,-1,10)], 'ts1' ),
  ( '=w', 'ts2', [j,k,l,(1,-1,10)], 'ts2' ),
]

_home = os.path.expanduser('~')
i = 0
while True:
    i += 1
    f = _home + 'sord/stresses/initial.stressx.%02d' % i
    print f
    if not os.path.isfile( f ): break
    os.system( _home + 'sord/bin/asc2flt < %r > ts' % f )
    rundir = _home + 'sord/run/%02d' % i
    sord.run( locals() )

