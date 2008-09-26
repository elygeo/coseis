#!/usr/bin/env python
from sord import _

# Kostrov constant rupture velocity test

np = 1, 1, 1
nt = 400
j, k, l = 61, 61, 21
ihypo = j, k, l
nn = 2*j, 2*k, 2*l
bc1 = 10, 10, 10
bc2 = 10, 10, 10
faultnormal = 3
vrup = 3117.6914
rcrit = 1e9
trelax = 0.

io = [
  ( '=',  'mus',           _[:,:,:,0],    1e9 ),
  ( '=',  'mud',           _[:,:,:,0],    0.  ),
  ( '=',  'dc',            _[:,:,:,0],    1e9 ),
  ( '=',  'co',            _[:,:,:,0],    0.  ),
  ( '=',  'tn',            _[:,:,:,0], -100e6 ),
  ( '=',  'ts1',           _[:,:,:,0],  -90e6 ),
  ( 'w', ('sl','svm'),     _[:,:,:,-1]        ),
  ( 'w', ('x1','x2','x3'), _[:,:,l,0]         ),
  ( 'w', ('v1','v2','v3'), _[:,:,:,::20], 1   ),
]

