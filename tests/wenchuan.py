#!/usr/bin/env python
"""
Wenchuan earthquake
"""

import sord, math

np3 = 1, 1, 2
dx = 1000.
_T = 120.
_L = 400e3, 300e3, 60e3
dt = dx / 12500.
nt = int( _T / dt + 1.5 )
nn = [ int( _X / dx + 1.5 ) for _X in _L ]
hourglass = 1., 1.
bc1 = 10, 10, 10
bc2 = 10, 10, 0
faultnormal = 0

# Source
xhypo = 0., 0., -12e3
ihypo = [
    nn[0] / 2,
    nn[1] / 2,
    -int( -xhypo[2] / dx + 1.5 )
]
moment1 = -5.79e20, 0.10e20, 5.69e20    #  Mpp,  Mtt,  Mrr
moment2 = -1.99e20, 5.61e20, 3.48e20    # -Mrt,  Mrp, -Mtp
tfunc = 'brune'
rfunc = 'point'
tsource = 0.1
rsource = dx
fixhypo = -1

# Velocity model
fieldio = [ ( '=', 'gam', [], 0.2 ) ]
_material = [
    (   0., 5800., 3370. ),
    ( 10e3, 6200., 3600. ),
    ( 16e3, 6600., 3840. ),
    ( 24e3, 7000., 3940. ),
    ( 33e3, 7800., 4380. ),
]
for _depth, _vp, _vs in _material:
    _rho = _vp / 3. + 1280.
    _i = -int( _depth / dx + 1.5 )
    fieldio += [
        ( '=', 'rho', [0,0,(1,_i),0], _rho ),
        ( '=', 'vp',  [0,0,(1,_i),0], _vp  ),
        ( '=', 'vs',  [0,0,(1,_i),0], _vs  ),
    ]

# Output
for _f in ( 'v1', 'v2', 'v3' ):
    fieldio += [
        ( '=wx', _f, [], 'Epicenter-' + _f, (  0.,   0., 0. ), ),
        ( '=wx', _f, [], 'Wenchuan-'  + _f, ( 30.,  52., 0. ), ),
        ( '=wx', _f, [], 'Maoxian-'   + _f, ( 60.,  70., 0. ), ),
        ( '=wx', _f, [], 'Chengdu-'   + _f, ( 84., -36., 0. ), ),
    ]

sord.run( locals() )

