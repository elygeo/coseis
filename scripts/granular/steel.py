#!/usr/bin/env python
"""
Granular 
sampling: 2-40 MHz = 5e-7 to 2.5e-8 s
sources: 500kHz
"""
import sord

dx = 0.00025, 0.00025, 0.00025 ; np3 = 1, 32, 1 # spatial resolution and number of processors
dx = 0.001,   0.001,   0.001   ; np3 = 1, 32,  1 # spatial resolution and number of processors
dt = dx[0] / 12500.0		# time step length

T = 0.0001			# time duration 
T = 0.00001			# time duration
L = 0.15, 0.06, 0.11		# model dimensions
bc1 = 0, 1, 0			# reflecting boundary condition
bc2 = 0, 1, 0			# reflecting boundary condition
nt = int( T / dt + 1.00001 )	# number of time steps
nn = [				# number of sample points 
    int( L[0] / dx[0] + 0.00001 ),
    int( L[1] / dx[1] + 0.00001 ),
    int( L[2] / dx[2] + 0.00001 ),
]
nn = [				# number of sample points 
    int( L[0] / dx[0] + 0.00001 ),
    2,
    int( L[2] / dx[2] + 0.00001 ),
]

# source
ihypo = (nn[0]+1)/2.0, (nn[1]+1)/2.0, 0.035 / dx[2] + 1.0 # hypocenter location
source = 'potency'
timefunction = 'brune'
source1 = 3 * [ 0.0  ]; source2 = 0.0, 1e-9, 0.0; rundir = '~/run/shear'
#source1 = 3 * [ 1e-9 ]; source2 = 3 * [ 0.0 ];   rundir = '~/run/vol'
period = 2e-6

# material model
_3 = 0.0325 / dx[2] + 1.5
_4 = 0.0375 / dx[2] + 0.5
l1_ =  _3,  _4
l2_ = -_4, -_3
fieldio = [
    ( '=',  'gam', [],                   0.1 ),
    ( '=',  'rho', [],                7700.0 ), # steel
    ( '=',  'vp',  [],                5900.0 ), # steel
    ( '=',  'vs',  [],                3200.0 ), # steel
    ( '=',  'gam', [(), (), l1_, ()],    0.2 ), # gouge
    ( '=',  'rho', [(), (), l1_, ()], 1800.0 ), # gouge
    ( '=',  'vp',  [(), (), l1_, ()], 1750.0 ), # gouge
    ( '=',  'vs',  [(), (), l1_, ()],  400.0 ), # gouge
    ( '=',  'gam', [(), (), l2_, ()],    0.2 ), # gouge
    ( '=',  'rho', [(), (), l2_, ()], 1800.0 ), # gouge
    ( '=',  'vp',  [(), (), l2_, ()], 1750.0 ), # gouge
    ( '=',  'vs',  [(), (), l2_, ()],  400.0 ), # gouge
]

# output
k = int( ihypo[1] + 0.0000001 )
fieldio += [
    ( '=w', 'vs', [(), k, (), ()], 'vs' ),
    ( '=w', 'v1', [(), k, (), (1, -1, 10)], 'v1' ),
    ( '=w', 'v2', [(), k, (), (1, -1, 10)], 'v2' ),
    ( '=w', 'v3', [(), k, (), (1, -1, 10)], 'v3' ),
]

# sensors
for x, y, z, name_ in [
    ( 0.50*L[0], 0.0, 0.50*L[2], 'steel-1' ),
    ( 0.25*L[0], 0.0, 0.50*L[2], 'steel-2' ),
    ( 0.32*L[0], 0.0, 0.50*L[2], 'steel-3' ),
    ( 0.33*L[0], 0.0, 0.50*L[2], 'gouge-1' ),
    ( 0.50*L[0], 0.0, 0.75*L[2], 'steel-4' ),
    ( 0.25*L[0], 0.0, 0.75*L[2], 'steel-5' ),
    ( 0.32*L[0], 0.0, 0.75*L[2], 'gouge-6' ),
    ( 0.33*L[0], 0.0, 0.75*L[2], 'gouge-2' ),
]:
    j = int( x / dx[0] + 1.0000001 )
    k = int( y / dx[1] + 1.0000001 )
    l = int( z / dx[2] + 1.0000001 )
    fieldio += [
        ( '=w', 'v1',  [j,k,l,()], name_+'v1'  ),
        ( '=w', 'v2',  [j,k,l,()], name_+'v2'  ),
        ( '=w', 'v3',  [j,k,l,()], name_+'v3'  ),
        ( '=w', 'u1',  [j,k,l,()], name_+'u1'  ),
        ( '=w', 'u2',  [j,k,l,()], name_+'u2'  ),
        ( '=w', 'u3',  [j,k,l,()], name_+'u3'  ),
        ( '=w', 'w11', [j,k,l,()], name_+'w11' ),
        ( '=w', 'w22', [j,k,l,()], name_+'w22' ),
        ( '=w', 'w33', [j,k,l,()], name_+'w33' ),
    ]

sord.run( locals() )

