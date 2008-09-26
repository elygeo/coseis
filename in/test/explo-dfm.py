#!/usr/bin/env python
from sord import _

# Explosion test problem for comparison with DFM
np = 1, 2, 1
nn = 101, 101, 61
dx = 100.
dt = 0.008
nt = 200
io = [
  ( '=', 'vp',  _[:,:,:,0], 6000. ),
  ( '=', 'vs',  _[:,:,:,0], 3464. ),
  ( '=', 'rho', _[:,:,:,0], 2700. ),
  ( '=', 'gam', _[:,:,:,0], 0.3   ),
]

hourglass = 1., 0.3
faultnormal = 0
rexpand = 1.06
n1expand = 20, 20, 20
n2expand = 20, 20, 20
moment1 = 1e18, 1e18, 1e18
moment2 = 0, 0, 0
tfunc = 'brune'
tsource = 0.1
xhypo = 0., 0., 0.
bc1 = 0, 0, 0
bc2 = 0, 0, 0
ihypo = 31, 31, 31

io += [
  ( 'w', ('x1','x2','x3','v1','v2','v3'), _[:,:,:,:], (   0.,3999.,0.) ),
  ( 'w', ('x1','x2','x3','v1','v2','v3'), _[:,:,:,:], (2999.,3999.,0.) ),
  ( 'w', ('x1','x2','x3','v1','v2','v3'), _[:,:,:,:], (3999.,3999.,0.) ),
]

fixhypo = -1; rsource = 100.
fixhypo = -2; rsource = 50.

