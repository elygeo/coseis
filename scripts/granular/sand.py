#!/usr/bin/env python
"""
Granular 
sampling: 2-40 MHz = 5e-7 to 2.5e-8 s
sources: 500kHz
"""
import numpy, Image, sord

dx = 0.00025, 0.00025, 0.00025 ; np3 = 1, 32, 1 # spatial resolution and number of processors
dx = 0.001,   0.001,   0.001   ; np3 = 1, 32,  1 # spatial resolution and number of processors
dt = dx[0] / 12500.0		# time step length

_T = 0.0001			# time duration 
_T = 0.00001			# time duration
_L = 0.15, 0.0, 0.11		# model dimensions
bc1 = 0, 1, 0			# reflecting boundary condition
bc2 = 0, 1, 0			# reflecting boundary condition
nt = int( _T / dt + 1.00001 )	# number of time steps
nn = [				# number of sample points 
    int( _L[0] / dx[0] + 0.00001 ),
    2,
    int( _L[2] / dx[2] + 0.00001 ),
]

# source
ihypo = (nn[0]+1)/2.0, (nn[1]+1)/2.0, 0.035 / dx[2] + 1.0 # hypocenter location
src_type = 'potency'
src_function = 'brune'
src_w1 = 3 * [ 0.0  ]; src_w2 = 0.0, 1e-9, 0.0; rundir = '~/run/shear'
#src_w1 = 3 * [ 1e-9 ]; src_w2 = 3 * [ 0.0 ];   rundir = '~/run/vol'
src_period = 2e-6

# material model
_im = Image.open( 'data/granular1.png' )
_im = numpy.array( _im.resize( (nn[0], nn[2]) ).convert( 'L' ), 'f' )
_im = _im / _im.max()
_vp = 1250.0 + 1000.0 * _im
_vs = 0.0 + 500.0 * _im
_vp.T.tofile( 'vp' )
_vs.T.tofile( 'vs' )
fieldio = [
    ( '=',  'gam', [],    0.2 ),
    ( '=',  'rho', [], 1800.0 ),
    ( '=r', 'vp',  [], 'vp' ),
    ( '=r', 'vs',  [], 'vs' ),
]

# output
_k = int( ihypo[1] + 0.0000001 )
fieldio += [
    ( '=w', 'vs',  [(),_k,(),()], 'vs' ),
    ( '=w', 'v1',  [(),_k,(),(1,-1,10)], 'v1' ),
    ( '=w', 'v2',  [(),_k,(),(1,-1,10)], 'v2' ),
    ( '=w', 'v3',  [(),_k,(),(1,-1,10)], 'v3' ),
]

# sensors
for _x, _y, _z, _name in [
    (  0.50*_L[0], 0.0, 0.50*_L[2], 'steel-1' ),
    (  0.25*_L[0], 0.0, 0.50*_L[2], 'steel-2' ),
    (  0.32*_L[0], 0.0, 0.50*_L[2], 'steel-3' ),
    (  0.33*_L[0], 0.0, 0.50*_L[2], 'gouge-1' ),
    (  0.50*_L[0], 0.0, 0.75*_L[2], 'steel-4' ),
    (  0.25*_L[0], 0.0, 0.75*_L[2], 'steel-5' ),
    (  0.32*_L[0], 0.0, 0.75*_L[2], 'gouge-6' ),
    (  0.33*_L[0], 0.0, 0.75*_L[2], 'gouge-2' ),
]:
    _j = int( _x / dx[0] + 1.0000001 )
    _k = int( _y / dx[1] + 1.0000001 )
    _l = int( _z / dx[2] + 1.0000001 )
    fieldio += [
        ( '=w', 'v1',  [_j,_k,_l,()], _name+'v1'  ),
        ( '=w', 'v2',  [_j,_k,_l,()], _name+'v2'  ),
        ( '=w', 'v3',  [_j,_k,_l,()], _name+'v3'  ),
        ( '=w', 'u1',  [_j,_k,_l,()], _name+'u1'  ),
        ( '=w', 'u2',  [_j,_k,_l,()], _name+'u2'  ),
        ( '=w', 'u3',  [_j,_k,_l,()], _name+'u3'  ),
        ( '=w', 'w11', [_j,_k,_l,()], _name+'w11' ),
        ( '=w', 'w22', [_j,_k,_l,()], _name+'w22' ),
        ( '=w', 'w33', [_j,_k,_l,()], _name+'w33' ),
    ]

sord.run( locals() )

