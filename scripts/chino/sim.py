#!/usr/bin/env python
"""
SORD simulation
"""
import os, sys
import pyproj
import numpy as np
import cst

# parameters
dx_ = 100.0;  nproc3 = 1, 48, 320
dx_ = 200.0;  nproc3 = 1, 12, 160
dx_ = 500.0;  nproc3 = 1, 4, 64
dx_ = 8000.0; nproc3 = 1, 1, 1
dx_ = 1000.0; nproc3 = 1, 1, 2

# path
id_ = 'topo-cvm-%04.f' % dx_
id_ = 'flat-%04.f' % dx_
rundir = os.path.join( 'run', 'sim', id_ )

# mesh metadata
mesh_ = '%04.0f' % dx_
mesh_ = os.path.join( 'run', 'mesh', mesh_ ) + os.sep
meta = cst.util.load( mesh_ + 'meta.py' )
dtype = meta.dtype
delta = meta.delta
shape = meta.shape
hypo_ = meta.origin
npml = meta.npml

# translate projection to lower left origin
x, y = meta.bounds[:2]
proj = pyproj.Proj( **meta.projection )
proj = cst.coord.Transform( proj, translate=(-x[0], -y[0]) )

# dimensions
dt_ = dx_ / 16000.0
dt_ = dx_ / 20000.0
nt_ = int( 120.0 / dt_ + 1.00001 )
delta += (dt_,)
shape += (nt_,)

# hypocenter location at x/y center
x, y, z = hypo_
x, y = proj( x, y )
j = abs( x / delta[0] ) + 1.0
k = abs( y / delta[1] ) + 1.0
l = abs( z / delta[2] ) + 1.0
ihypo = j, k, l

# moment tensor source
source = 'moment'
timefunction = 'brune'
period = 0.1
source1 = -1417e14,  585e14, 832e14
source1 =  -739e14, -190e14, 490e14

# boundary conditions
bc1 = 10, 10, 0
bc2 = 10, 10, 10

# material
hourglass = 1.0, 1.0
if 'cvm' in id_:
    vp1 = 1500.0
    vs1 = 500.0
    vdamp = 400.0
    gam2 = 0.8
    fieldio = [
        ( '=r', 'rho', [], 'rho.bin' ),
        ( '=r', 'vp',  [], 'vp.bin'  ),
        ( '=r', 'vs',  [], 'vs.bin'  ),
    ]
else:
    fieldio = [
        ( '=',  'rho', [], 2670.0 ),
        ( '=',  'vp',  [], 6000.0 ),
        ( '=',  'vs',  [], 3464.0 ),
        ( '=',  'gam', [], 0.3    ),
    ]

# topography
if 'topo' in id_:
    fieldio += [
        ( '=r', 'x3',  [], 'z3.bin'  )
    ]

# sites
for x, y, s in [
    (-115.6517,  32.4681,  'Mexicali'),
    (-115.5125,  32.6694,  'Calexico'),
    (-117.04,    34.91,    'Barstow'),
    (-117.29,    34.53,    'Victorville'),
    (-118.13,    34.71,    'Lancaster'),
    (-119.8,     36.7333,  'Fresno'),
    (-119.3,     35.4167,  'Bakersfield'),
    (-120.4124,  35.8666,  'Parkfield'),
    (-120.69,    35.63,    'Paso Robles'),
    (-120.7167,  35.3333,  'San Luis Obispo'),
    (-120.45,    34.9,     'Santa Maria'),
    (-119.8333,  34.4333,  'Santa Barbara'),
    (-119.1833,  34.2,     'Oxnard'),
    (-118.55829, 34.22869, 'Northridge'),
    (-118.308,   34.185,   'Burbank'),
    (-118.315,   34.062,   'Los Angeles'),
    (-118.17113, 34.14844, 'Pasadena'),
    (-118.1668,  33.9235,  'Downey'),
    (-118.0844,  33.7568,  'Seal Beach'),
    (-117.91,    33.64,    'Newport Beach'),
    (-117.81,    33.68,    'Irvine'),
    (-117.16,    32.718,   'San Diego'),
    (-117.2284,  34.1065,  'San Bernardino'),
    (-117.6,     34.05,    'Ontario'),
]:
    s = s.replace( ' ', '-' )
    x, y = proj( x, y )
    j = x / delta[0] + 1.0
    k = y / delta[1] + 1.0
    fieldio += [
        ('=wi', 'v1', [j,k,1,()], s + '-v1.bin'),
        ('=wi', 'v2', [j,k,1,()], s + '-v2.bin'),
        ('=wi', 'v3', [j,k,1,()], s + '-v3.bin'),
    ]

# surface output
ns = max( 1, max( shape[:3] ) / 1024 )
nh = 4 * ns
mh = max( 1, int( 0.025 / dt_ + 0.5 ) )
ms = max( 1, int( 0.125 / (dt_ * mh) + 0.5 ) )
fieldio += [
    ( '=w', 'v1',  [(1,-1,ns), (1,-1,ns), 1, (1,-1,mh)], 'full-v1.bin' ),
    ( '=w', 'v2',  [(1,-1,ns), (1,-1,ns), 1, (1,-1,mh)], 'full-v2.bin' ),
    ( '=w', 'v3',  [(1,-1,ns), (1,-1,ns), 1, (1,-1,mh)], 'full-v3.bin' ),
    ( '#w', 'v1',  [(1,-1,ns), (1,-1,ns), 1, (1,-1,ms)], 'snap-v1.bin' ),
    ( '#w', 'v2',  [(1,-1,ns), (1,-1,ns), 1, (1,-1,ms)], 'snap-v2.bin' ),
    ( '#w', 'v3',  [(1,-1,ns), (1,-1,ns), 1, (1,-1,ms)], 'snap-v3.bin' ),
    ( '#w', 'v1',  [(1,-1,nh), (1,-1,nh), 1, (1,-1,mh)], 'hist-v1.bin' ),
    ( '#w', 'v2',  [(1,-1,nh), (1,-1,nh), 1, (1,-1,mh)], 'hist-v2.bin' ),
    ( '#w', 'v3',  [(1,-1,nh), (1,-1,nh), 1, (1,-1,mh)], 'hist-v3.bin' ),
]

# stage job
if cst.conf.configure()[0].machine == 'usc-hpc':
    mpout = 0
job = cst.sord.stage( locals(), post='rm -r in/' )
if not job.prepare:
    sys.exit()

# save metadata
path_ = job.rundir + os.sep
s = '\n'.join( (
    open( mesh_ + 'meta.py' ).read(),
    open( path_ + 'meta.py' ).read(),
) )
open( path_ + 'meta.py', 'w' ).write( s )
os.link( mesh_ + 'box.txt', path_ + 'box.txt' )

# save decimated mesh
n = shape[:2]
for f in 'lon.bin', 'lat.bin', 'topo.bin':
    s = np.fromfile( mesh_ + f, dtype ).reshape( n[::-1] )
    s[::ns,::ns].tofile( path_ + f )

# copy input files
path_ += 'in' + os.sep
for f in 'z3.bin', 'rho.bin', 'vp.bin', 'vs.bin':
    os.link( mesh_ + f, path_ + f )

# launch job
job = cst.sord.launch( job )

# post-process to compute pgv, pga
path_ = job.rundir + os.sep
meta = cst.util.load( path_ + 'meta.py' )
x, y, t = meta.shapes['full-v1.bin']
s = x * y * t / 1000000
cst.conf.launch(
    new = False,
    rundir = rundir,
    name = 'cook',
    stagein = ['cook.py'],
    command = 'python cook.py',
    run = job.run,
    seconds = s,
    depend = job.jobid,
)

