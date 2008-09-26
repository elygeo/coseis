#!/usr/bin/env python
from sord import _

# Test

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

io = [
  ( 'w', 'x',   _[:,:,:,0] ),
  ( 'w', 'rho', _[:,:,:,0] ),
  ( 'w', 'vp',  _[:,:,:,0] ),
  ( 'w', 'vs',  _[:,:,:,0] ),
  ( 'w', 'gam', _[:,:,:,0] ),
  ( 'w', 'u',   _[:,:,:,:] ),
  ( 'w', 'v',   _[:,:,:,:] ),
  ( 'w', 'a',   _[:,:,:,:] ),
  ( 'w', 'su',  _[:,:,:,:] ),
  ( 'w', 'sv',  _[:,:,:,:] ),
  ( 'w', 'sa',  _[:,:,:,:] ),
]

