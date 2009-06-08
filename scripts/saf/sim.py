#!/usr/bin/env python
"""
SAF parameters
"""
import sord

# parameters
dx =  200.0; npml = 10
dx = 20000.0; npml = 0
dx = 4000.0; npml = 10
topo_ = False
topo_ = True
indir_ = '~/run/cvm4/'
rundir = '~/run/saf'
itstats = 10
itio = 100
T = 180.0
L = 600000.0, 300000.0, -80000.0

# number of processors
np3 = 1, 1, 1
if dx == 4000:
    np3 = 1, 1, 2 
elif dx == 2000:
    np3 = 1, 2, 4
elif dx == 1000:
    np3 = 1, 8, 4
elif dx == 500:
    itio = 500
    if 1: # surface, np3[2] = 18, 21, 23, 27, 33, 41, 54, 81, 161
        np3 = 1, 1, 82
        np3 = 1, 1, 54
    else: # fault, np3[1] = 1:29, 32, 34, 36, 38, 76, 86, 101, 121, 151, 201, 301, 602
        np = 1,  8, 4 
        np = 1, 16, 4 
elif dx == 200:
    itio = 500
    itcheck = 2000
    if 1: # combo, np3[1] = 1:43, 56, 76, 80, np3[2] = 1:4, 10, 15, 20, 24, 29, 34, 37, 45
        np3 = 1, 40, 45 # DS, 225/265
        np3 = 1, 56, 37 # DS, 259/265
        np3 = 1, 24, 20 # TG, 240/256
        np3 = 1, 80, 24 # DS, 240/265
    elif 1: # surface, np3[2] = 34, 37, 41, 45, 51, 58, 67, 81, 101, 134, 201, 401
        np3 = 1, 1, 401 # TG, 201/256
        np3 = 1, 4, 401 # DS, 201/265
    else: # fault, np3[1] = 56, 76, 80, 94, 108, 116, 126, 188, 301, 376, 501, 751, 1502
        np3 = 1, 501, 4 # DS, 251/265
        np3 = 1, 376, 4 # DS, 188/265
        np3 = 1,  94, 4 # TG, 188/256
        np3 = 1, 126, 4 # TG, 252/256

# dimensions
dx = dx, dx, -dx
dt = dx[0] * 0.00006
nt = int( T / dt + 1.00001 )
nn = [
    int( L[0] / dx[0] + 1.00001 ),
    int( L[1] / dx[1] + 2.00001 ),
    int( L[2] / dx[2] + 1.00001 ),
]

# lat/lon to model coordinate projection
projection = sord.coord.ll2xy

# boundary conditions
bc1 = 10, 10,  0
bc2 = 10, 10, 10

# read mesh coordinates
fieldio = [
    ( '=R', 'x1', [(),(),1,()], indir_ + 'x' ),
    ( '=R', 'x2', [(),(),1,()], indir_ + 'y' ),
]

# read topography mesh
if topo_:
    fieldio += [ ( '=r', 'x3', [], indir_ + 'z3' ) ]

# material properties
vp1 = 1500.0
vs1 = 500.0
gam2 = 0.8
vdamp = 400.0
hourglass = 1.0, 1.0
fieldio += [
    ( '=r', 'rho', [], indir_ + 'rho' ),
    ( '=r', 'vp',  [], indir_ + 'vp'  ),
    ( '=r', 'vs',  [], indir_ + 'vs'  ),
]

# surface output
fieldio += [
    ( '=w', 'v1', [], 'v1' ),
    ( '=w', 'v2', [], 'v2' ),
    ( '=w', 'v3', [], 'v3' ),
    ( '=w', 'x1', [], 'x1' ),
    ( '=w', 'x2', [], 'x2' ),
    ( '=w', 'x3', [], 'x3' ),
]

# fault parameters
faultnormal = 2
slipvector = 1.0, 0.0, 0.0
F = 199000.0, 0.0, -16000.0
segments_ = [
    -117.4982, 34.2895,
    -117.2382, 34.1547,
    -116.7748, 33.9878,
    -116.4770, 33.9240,
    -116.2463, 33.7882,
    -115.7119, 33.3501,
]
xf_, yf_ = projection( segments_[0::2], segments_[1::2] )
jf_ = int( 0.5 * ( xf_.min() + xf_.max() - F[0] ) / dx[0] + 1.5 )
kf_ = int( 0.5 * ( yf_.min() + yf_.max()         ) / dx[1] + 1.5 )
lf_ = int(                                 F[2]   / dx[2] + 1.00001 )
jf_ = jf_, jf_ + int( F[0] / dx[0] + 0.01 )
lf_ = 1, lf_
n = (nt + 1) / 2
fieldio += [
    ( '=',  'tn',   [(),  kf_, (),  ()], -20e6         ),
    ( '=',  'ts',   [(),  kf_, (),  ()],  0.0          ),
    ( '=',  'dc',   [(),  kf_, (),  ()],  0.5          ),
    ( '=',  'mud',  [(),  kf_, (),  ()],  0.5          ),
    ( '=',  'mus',  [(),  kf_, (),  ()],  1e4          ),
    ( '=',  'mus',  [jf_, kf_, lf_, ()],  1.1          ),
    ( '=r', 'tn',   [jf_, kf_, lf_, ()], indir_ + 'tn' ),
    ( '=r', 'ts',   [jf_, kf_, lf_, ()], indir_ + 'ts' ),
    ( '=r', 'dc',   [jf_, kf_, lf_, ()], indir_ + 'dc' ),
    ( '=w', 'tsm',  [jf_, kf_, lf_, (1,n)],      'tsm' ),
    ( '=w', 'sv1',  [jf_, kf_, lf_, (1,n)],      'sv1' ),
    ( '=w', 'sv2',  [jf_, kf_, lf_, (1,n)],      'sv2' ),
    ( '=w', 'sv3',  [jf_, kf_, lf_, (1,n)],      'sv3' ),
]

# nucleation
ihypo = ( jf_[1] - int( 9000 / dx[0] + 0.5 ), kf_, int( -5000 / dx[2] + 1.5 )
fixhypo = 1
vrup = 2300.0
trelax = 0.12
rcrit = 3000.0

# stations
stations_ = [
    -119.01778, 35.37333, 'Bakersfield',
    -119.69722, 34.42083, 'Santa-Barbara',
    -119.17611, 34.19750, 'Oxnard',
    -118.13583, 34.69806, 'Lancaster',
    -118.41500, 34.06000, 'Westwood',
    -118.24278, 34.05222, 'Los-Angeles',
    -118.10444, 34.00944, 'Montebello',
    -118.18833, 33.76694, 'Long-Beach',
    -117.02194, 34.89861, 'Barstow',
    -117.29028, 34.53612, 'Victorville',
    -117.65000, 34.06333, 'Ontario',
    -117.86694, 33.74556, 'Santa-Ana',
    -117.28889, 34.10833, 'San-Bernardino',
    -117.39528, 33.95333, 'Riverside',
    -117.37861, 33.19583, 'Oceanside',
    -116.54444, 33.83028, 'Palm-Springs',
    -116.17305, 33.68028, 'Coachella',
    -117.15639, 32.71528, 'San-Diego',
    -116.60970, 31.87200, 'Ensenada',
    -115.46730, 32.65498, 'Mexicali',
    -114.62361, 32.72528, 'Yuma',
]
x, y = projection( stations_[0::3], stations_[1::3] )
f = stations_[2::3]
for i in range( len( f ) ):
    j = int( x[i] / dx[0] + 1.5 )
    k = int( y[i] / dx[1] + 1.5 )
    fieldio += [ ( '=w', 'v1', [j,k,1,()], f[i] + '-v1' ) ]
    fieldio += [ ( '=w', 'v2', [j,k,1,()], f[i] + '-v2' ) ]
    fieldio += [ ( '=w', 'v3', [j,k,1,()], f[i] + '-v3' ) ]

# run job
if __name__ == '__main__':
    sord.run( locals() )

