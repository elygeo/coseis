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
dx_ = 200.0;  nproc3 = 1, 12, 160 # cutoff 0.5 Hz 4 pole butter
dx_ = 500.0;  nproc3 = 1, 4, 64
dx_ = 1000.0; nproc3 = 1, 1, 2
dx_ = 8000.0; nproc3 = 1, 1, 1

# path
id_ = 'topo-cvm-%04.f' % dx_
id_ = 'flat-%04.f' % dx_
id_ = 'flat-cvm-%04.f' % dx_
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
mts_ = 'scsn-mts-14383980.py'
source = 'moment'
timefunction = 'brune'
period = 0.1
m = cst.util.load( mts_ ).double_couple_clvd
source1 =  m['myy'],  m['mxx'],  m['mzz']
source2 = -m['mxz'], -m['myz'],  m['mxy']

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
stagein = 'out/',
for s in open( 'station-list.txt' ).readlines():
    s, y, x = s.split()[:3]
    x, y = proj( float(x), float(y) )
    j = x / delta[0] + 1.0
    k = y / delta[1] + 1.0
    fieldio += [
        ('=wi', 'v1', [j,k,1,()], 'out/' + s + '-v1.bin'),
        ('=wi', 'v2', [j,k,1,()], 'out/' + s + '-v2.bin'),
        ('=wi', 'v3', [j,k,1,()], 'out/' + s + '-v3.bin'),
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
job = cst.sord.stage( locals(), post='rm z3.bin rho.bin vp.bin vs.bin' )
if not job.prepare:
    sys.exit()

# save metadata
path_ = job.rundir + os.sep
s = '\n'.join( (
    open( mts_ ).read(),
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

