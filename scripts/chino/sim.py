#!/usr/bin/env python
"""
Chino Hills test
"""
import sys

np3 = 1, 8, 1
np3 = 1, 2, 1
vm_ = 'uhs'
vm_ = 'cvm'
vm_ = '1d'
grid_ = ''
grid_ = 'sphere'
grid_ = 'topo'
grid_ = 'topo-sphere'
T = 120.0
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
nsource = 1
source = 'moment'
infiles = ['~/run/tmp/src_*']
rundir = '~/run/chino-' + vm_

# mesh projection
def projection( x, y, z=None, inverse=False ):
    import pyproj
    rearth = 6370000.0
    lon0 = -118.1
    lat0 = 34.1
    projection = pyproj.Proj( proj='ortho', lon_0=lon0, lat_0=lat0 )
    x, y = projection( x, y, inverse=inverse )
    #h = rearth - numpy.sqrt( rearth*2 - x**2 - y**2 )
    if inverse:
        x, y = projection( x, y, inverse=True )
    else:
        x, y = projection( x, y, inverse=False )
        if z != None:
            x = x * (z - rearth) / rearth 
    return numpy.array( [x, y] )

# viscosity and output
fieldio = [
    ( '=',  'gam', [], 0.0 ),
]

# topography mesh
if grid_:
    fieldio += [ ( '=r', 'x3',  [], '~/run/tmp/z3' ) ]

# velocity model
if vm_ == 'cvm':
    fieldio += [
        ( '=r', 'rho', [], '~/run/cvm4/rho' ),
        ( '=r', 'vp',  [], '~/run/cvm4/vp'  ),
        ( '=r', 'vs',  [], '~/run/cvm4/vs'  ),
    ]
elif vm_ == 'uhs':
    fieldio += [
        ( '=',  'rho', [], 2500.0 ),
        ( '=',  'vp',  [], 6000.0 ),
        ( '=',  'vs',  [], 3500.0 ),
    ]
elif vm_ == '1d':
    layers_ = [
        (  0.0, 5.5, 3.18, 2.4  ),
        (  5.5, 6.3, 3.64, 2.67 ),
        (  8.4, 6.3, 3.64, 2.67 ),
        ( 16.0, 6.7, 3.87, 2.8  ),
        ( 35.0, 7.8, 4.5,  3.0  ),
    ]
    for dep_, vp_, vs_, rho_ in layers_:
        i = int( -1000.0 * dep_ / dx[2] + 1.5 )
        fieldio += [
            ( '=',  'rho', [(),(),(i,-1),()], 1000.0 * rho_ ),
            ( '=',  'vp',  [(),(),(i,-1),()], 1000.0 * vp_  ),
            ( '=',  'vs',  [(),(),(i,-1),()], 1000.0 * vs_  ),
        ]
else:
    sys.exit( 'bad vm' )

# run SORD job
if __name__ == '__main__':
    import numpy, sord
    dtype_ = dict( names=( 'name', 'lat', 'lon' ), formats=( 'S8', 'f4', 'f4' ) )
    sta_ = numpy.loadtxt( 'data/station-list', dtype_, usecols=(0,1,2) )
    x, y = projection( sta_['lon'], sta_['lat'] )
    clip_ = 27020.0
    prev_ = ''
    n = 0
    for i in range( len( sta_ ) ):
        if n == 64:
            print 'Too many stations. Skipping the rest.'
            break
        if ( sta_[i]['name'] != prev_ and
            clip_ < x[i] < L[0]-clip_ and
            clip_ < y[i] < L[1]-clip_ ):
            n += 1
            j = x[i] / dx[0] + 1
            k = y[i] / dx[1] + 1
            for f in 'v1', 'v2', 'v3':
                fieldio += [
                    ( '=wi', f, [j,k,1,()], sta_[i]['name'] + f ),
                ]
        prev_ = sta_[i]['name']

    sord.run( locals() )

