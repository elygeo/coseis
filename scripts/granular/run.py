#!/usr/bin/env python
"""
Granular 
"""
import sord

dx = 0.00025, 0.00025, 0.00025 ; np3 = 1, 32, 1
dx = 0.001,   0.001,   0.001   ; np3 = 1, 1,  1
dt = dx[0] / 12500.0

_T = 0.00001
_T = 0.0001
_L = 0.15, 0.06, 0.11
bc1 = 0, 0, 0
bc2 = 0, 0, 0
nt = int( _T / dt + 1.00001 )
nn = [
    int( _L[0] / dx[0] + 1.00001 ),
    int( _L[1] / dx[1] + 1.00001 ),
    int( _L[2] / dx[2] + 1.00001 ),
]

# source
ihypo = (nn[0]+1)/2.0, (nn[1]+1)/2.0, 0.035 / dx[2] + 1.0
src_type = 'potency'
src_function = 'brune'
src_w1 = 3 * [ 0.0  ]; src_w2 = 0.0, 1e-9, 0.0; rundir = '~/run/granular-shear'
src_w1 = 3 * [ 1e-9 ]; src_w2 = 3 * [ 0.0 ];    rundir = '~/run/granular-vol'
src_period = 20.0 * dt

# material model
_3 = int( 0.03 / dx[2] + 1.0000001 )
_4 = int( 0.04 / dx[2] + 1.0000001 )
_l1 =  _3,  _4
_l2 = -_4, -_3
fieldio = [
    ( '=',  'gam', [],                0.1 ),
    ( '=',  'rho', [],             7700.0 ), # steel
    ( '=',  'vp',  [],             5900.0 ), # steel
    ( '=',  'vs',  [],             3200.0 ), # steel
    ( '=',  'rho', [(),(),_l1,()], 1800.0 ), # sand
    ( '=',  'vp',  [(),(),_l1,()], 1750.0 ), # sand
    ( '=',  'vs',  [(),(),_l1,()],  400.0 ), # sand
    ( '=',  'rho', [(),(),_l2,()], 1800.0 ), # sand
    ( '=',  'vp',  [(),(),_l2,()], 1750.0 ), # sand
    ( '=',  'vs',  [(),(),_l2,()],  400.0 ), # sand
]

# output
_k = int( ihypo[1] + 0.0000001 )
fieldio += [
    ( '=w', 'vs',  [(),(_k,_k+1),(),()], 'vs' ),
    ( '=w', 'v1',  [(),_k,(),(1,-1,10)], 'v1' ),
    ( '=w', 'v2',  [(),_k,(),(1,-1,10)], 'v2' ),
    ( '=w', 'v3',  [(),_k,(),(1,-1,10)], 'v3' ),
]

sord.run( locals() )

