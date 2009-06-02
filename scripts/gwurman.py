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
_j, _k, _l = (61,-61), (61,-61), 64
infiles = [ 'ts' ]
fieldio += [
  ( '=r', 'ts',  [], 'ts'   ),
  ( '=',  'tn',  [], -120e6 ),
  ( '=',  'td',  [], 0.0    ),
  ( '=',  'mus', [], 1e4    ),
  ( '=',  'mud', [], 1e4    ),
  ( '=',  'mus', [_j,_k,_l,()], 0.677  ),
  ( '=',  'mud', [_j,_k,_l,()], 0.4    ),
]

# output
fieldio += [
  ( '=w', 'x1',  [_j,_k,_l,()], 'x1' ),
  ( '=w', 'x2',  [_j,_k,_l,()], 'x2' ),
  ( '=w', 'su1', [_j,_k,_l,-1], 'su1' ),
  ( '=w', 'su2', [_j,_k,_l,-1], 'su2' ),
  ( '=w', 'sv1', [_j,_k,_l,-1], 'sv1' ),
  ( '=w', 'sv2', [_j,_k,_l,-1], 'sv2' ),
  ( '=w', 'su1', [_j,_k,_l,250], 'su1-2s' ),
  ( '=w', 'su2', [_j,_k,_l,250], 'su2-2s' ),
  ( '=w', 'ts1', [_j,_k,_l,(1,-1,10)], 'ts1' ),
  ( '=w', 'ts2', [_j,_k,_l,(1,-1,10)], 'ts2' ),
]

_home = os.path.expanduser('~')
_i = 0
while True:
    _i += 1
    _f = _home + 'sord/stresses/initial.stressx.%02d' % _i
    print _f
    if not os.path.isfile( _f ): break
    os.system( _home + 'sord/bin/asc2flt < %r > ts' % _f )
    rundir = _home + 'sord/run/%02d' % _i
    sord.run( locals() )

