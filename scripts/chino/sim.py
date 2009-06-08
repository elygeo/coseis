#!/usr/bin/env python
"""
Chino Hills test
"""
import sys

np3 = 1, 8, 1
np3 = 1, 2, 1
_vm = 'uhs'
_vm = '1d'
_vm = 'cvm'
_topo = False
T = 120.
L = 160000.0, 120000.0, -30000.0
dx =  150.0,  150.0,  -150.0 ; npml = 10
dx = 1500.0, 1500.0, -1500.0 ; npml = 5
dx =  500.0,  500.0,  -500.0 ; npml = 10

bc1 = 10, 10, 0
bc2 = 10, 10, 10
dt = dx[0] / 12500.0
nt = int( T / dt + 1.00001 )
nn = [
    int( L[0] / dx[0] + 1.00001 ),
    int( L[1] / dx[1] + 1.00001 ),
    int( L[2] / dx[2] + 1.00001 ),
]
src_n = 1
src_type = 'moment'
infiles = [ '~/run/tmp/src_*' ]
rundir = '~/run/chino-' + _vm

# mesh projection
def projection( lon, lat, inverse=False ):
    import sord
    lon0 = -118.8
    lat0 = 33.6
    rot = 0.0
    return sord.coord.ll2xy( lon, lat, inverse, rot=rot, lon0=lon0, lat0=lat0 )

# viscosity and output
fieldio = [
    ( '=',  'gam', [], 0.0 ),
    ( '=w', 'v1',  [(),(),1,(1,-1,10)], 'v1' ),
    ( '=w', 'v2',  [(),(),1,(1,-1,10)], 'v2' ),
    ( '=w', 'v3',  [(),(),1,(1,-1,10)], 'v3' ),
]

# topography mesh
if _topo:
    fieldio += [ ( '=r', 'x3',  [], '~/run/tmp/z3' ) ]

# velocity model
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
        i = int( -_dep / dx[2] + 1.5 )
        fieldio += [
            ( '=',  'rho', [(),(),(i,-1),()], 1000. * _rho ),
            ( '=',  'vp',  [(),(),(i,-1),()], 1000. * _vp  ),
            ( '=',  'vs',  [(),(),(i,-1),()], 1000. * _vs  ),
        ]
else:
    sys.exit( 'bad vm' )

# run SORD job
if __name__ == '__main__':
    import numpy, sord
    dtype = dict( names=( 'name', 'lat', 'lon' ), formats=( 'S8', 'f4', 'f4' ) )
    sta = numpy.loadtxt( 'data/station-list', dtype, usecols=(0,1,2) )
    x, y = projection( sta['lon'], sta['lat'] )
    _clip = 27020.0
    prev = ''
    n = 0
    for i in range( len( sta ) ):
        if n == 64:
            print 'Too many stations. Skipping the rest.'
            break
        if sta[i]['name'] != prev and x[i] > _clip and x[i] < L[0]-_clip and y[i] > _clip and y[i] < L[1]-_clip:
            n += 1
            j = int( x[i] / dx[0] + 1.5 )
            k = int( y[i] / dx[1] + 1.5 )
            for f in 'v1', 'v2', 'v3':
                fieldio += [
                    ( '=w', f, [j,k,1,()], sta[i]['name'] + f ),
                ]
        prev = sta[i]['name']
    del( dtype, sta, x, y, prev, n, i, j, k, f )

    sord.run( locals() )

