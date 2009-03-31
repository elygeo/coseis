#!/usr/bin/env python
"""
Wenchuan earthquake
"""
import sord, math

np3 = 1, 1, 2
dx = 1000.0, 1000.0, -1000.0
_T = 120.0
_L = 400e3, 300e3, 60e3
dt = dx[0] / 12500.0
nt = int( _T / dt + 1.5 )
nn = [ int( _X / dx[0] + 1.5 ) for _X in _L ]
bc1 = 10, 10, 10
bc2 = 10, 10, 0

# Source
xhypo = 0.0, 0.0, -12e3
ihypo = nn[0]/2-0.5, nn[1]/2-0.5, -xhypo[2]/dx[2]
src_type = 'moment'
src_w1 = -5.79e20, 0.10e20, 5.69e20    #  Mpp,  Mtt,  Mrr
src_w2 = -1.99e20, 5.61e20, 3.48e20    # -Mrt,  Mrp, -Mtp
src_function = 'brune'
src_period = 0.1
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
    _rho = _vp / 3.0 + 1280.0
    _i = -int( _depth / dx[2] + 1.5 )
    fieldio += [
        ( '=', 'rho', [(),(),(1,_i),()], _rho ),
        ( '=', 'vp',  [(),(),(1,_i),()], _vp  ),
        ( '=', 'vs',  [(),(),(1,_i),()], _vs  ),
    ]

# Output
for _f in ( 'v1', 'v2', 'v3' ):
    fieldio += [
        ( '=wx', _f, [], 'Epicenter-' + _f, (  0e3,   0e3, 0. ), ),
        ( '=wx', _f, [], 'Wenchuan-'  + _f, ( 30e3,  52e3, 0. ), ),
        ( '=wx', _f, [], 'Maoxian-'   + _f, ( 60e3,  70e3, 0. ), ),
        ( '=wx', _f, [], 'Chengdu-'   + _f, ( 84e3, -36e3, 0. ), ),
    ]

sord.run( locals() )

