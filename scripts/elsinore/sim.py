#!/usr/bin/env python
"""
Elsinore simulation
"""
import sord

projection = sord.coord.ll2xy
_srf = 'data/cybershake/010-003-001-000'
_vm = '1d'
_vm = 'cvm'; _topo = True
_vm = 'uhs'; _topo = False
_T = 240.
_L = 600000.0, 300000.0, -80000.0
dx =  200.0,  200.0,  -200.0 ; npml = 10 ; _d = 2 ; np3 = 1, 40, 101 ; queue = None
dx =  500.0,  500.0,  -500.0 ; npml = 10 ; _d = 1 ; np3 = 1, 1, 81   ; queue = None
dx = 2000.0, 2000.0, -2000.0 ; npml = 5  ; _d = 1 ; np3 = 1, 1, 2    ; queue = None

bc1 = 10, 10, 0
bc2 = 10, 10, 10
dt = dx[0] / 12500.0
nt = int( _T / dt + 1.00001 )
nn = [
    int( _L[0] / dx[0] + 1.00001 ),
    int( _L[1] / dx[1] + 1.00001 ),
    int( _L[2] / dx[2] + 1.00001 ),
]
src_type = 'potency'
infiles = [ '~/run/tmp/src_*' ]
rundir = '~/run/elsinore-' + _vm

# output
_i = (1, -1, _d)
fieldio = [
    ( '=w', 'x1',  [_i,_i,1,()], 'x1' ),
    ( '=w', 'x2',  [_i,_i,1,()], 'x2' ),
    ( '=w', 'x3',  [_i,_i,1,()], 'x3' ),
    ( '=w', 'v1',  [_i,_i,1,()], 'v1' ),
    ( '=w', 'v2',  [_i,_i,1,()], 'v2' ),
    ( '=w', 'v3',  [_i,_i,1,()], 'v3' ),
]

# topography mesh
if _topo:
    fieldio += [ ( '=r', 'x3',  [], '~/run/tmp/zz' ) ]

# velocity model
hourglass = 1.0, 1.0
vp1 = 1500.0
vs1 = 500.0
vdamp = 400.0
gam2 = 0.8 
if _vm == 'uhs':
    fieldio += [
        ( '=',  'rho', [], 2500.0 ),
        ( '=',  'vp',  [], 6000.0 ),
        ( '=',  'vs',  [], 3500.0 ),
    ]
elif _vm == 'cvm':
    fieldio += [
        ( '=r', 'rho', [], '~/run/cvm4/rho' ),
        ( '=r', 'vp',  [], '~/run/cvm4/vp'  ),
        ( '=r', 'vs',  [], '~/run/cvm4/vs'  ),
    ]
elif _vm == '1d':
    _layers = [
        (  0.0, 5.5, 3.18, 2.4  ),
        (  5.5, 6.3, 3.64, 2.67 ),
        (  8.4, 6.3, 3.64, 2.67 ),
        ( 16.0, 6.7, 3.87, 2.8  ),
        ( 35.0, 7.8, 4.5,  3.0  ),
    ]
    for _dep, _vp, _vs, _rho in _layers:
        _i = int( -_dep / dx[2] + 1.5 )
        fieldio += [
            ( '=',  'rho', [(),(),(_i,-1),()], 1000. * _rho ),
            ( '=',  'vp',  [(),(),(_i,-1),()], 1000. * _vp  ),
            ( '=',  'vs',  [(),(),(_i,-1),()], 1000. * _vs  ),
        ]
else:
    sys.exit( 'bad vm' )

# run SORD job
if __name__ == '__main__':
    data = sord.source.srfb_read( _srf )[1]
    src_n = sord.source.srf2potency( data, projection, (dx[0],dx[1],-dx[2]), '~/run/tmp' )
    sord.run( locals() )

