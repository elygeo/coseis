#!/usr/bin/env python
"""
SORD simulation
"""
import os, sys
import pyproj
import numpy as np
import cst

# parameters
dx_ = 50.0;   nproc3 = 1, 32, 480; nstripe = 32
dx_ = 100.0;  nproc3 = 1, 4, 240;  nstripe = 16
dx_ = 200.0;  nproc3 = 1, 1, 120;  nstripe = 8
dx_ = 500.0;  nproc3 = 1, 1, 2;    nstripe = 2
dx_ = 1000.0; nproc3 = 1, 1, 2;    nstripe = 1
dx_ = 4000.0; nproc3 = 1, 1, 1;    nstripe = 1

# mesh type
surf_out_ = True
surf_out_ = False
register_ = True
register_ = False
mesh_ = 'chino-cvms-%04.0f' % dx_
mesh_ = 'chino-cvmg-%04.0f' % dx_
mesh_ = 'chino-cvmh-%04.0f' % dx_
id_ = mesh_ + '-topo'
id_ = mesh_ + '-flat'

# run directory
rundir = os.path.join('run', 'sim', id_)

# mesh metadata
mesh_ = os.path.join('run', 'mesh', mesh_) + os.sep
meta = cst.util.load(mesh_ + 'meta.py')
dtype = meta.dtype
delta = meta.delta
shape = meta.shape
hypo_ = meta.origin
npml = meta.npml

# translate projection to lower left origin
x, y = meta.bounds[:2]
proj = pyproj.Proj(**meta.projection)
proj = cst.coord.Transform(proj, translate=(-x[0], -y[0]))

# dimensions
dt_ = dx_ / 16000.0
dt_ = dx_ / 20000.0
nt_ = int(90.0 / dt_ + 1.00001)
delta += (dt_,)
shape += (nt_,)

# hypocenter location at x/y center
x, y, z = hypo_
x, y = proj(x, y)
j = abs(x / delta[0]) + 1.0
k = abs(y / delta[1]) + 1.0
l = abs(z / delta[2]) + 1.0
if register_:
    l = int(l) + 0.5
ihypo = j, k, l

# material
hourglass = 1.0, 1.0
vp1 = 1500.0
vs1 = 500.0
vdamp = 400.0
gam2 = 0.8
if 1:
    fieldio = [
        ('=r', 'rho', [], 'hold/rho.bin'),
        ('=r', 'vp',  [], 'hold/vp.bin'),
        ('=r', 'vs',  [], 'hold/vs.bin'),
    ]
else:
    fieldio = [
        ('=',  'rho', [], 2670.0),
        ('=',  'vp',  [], 6000.0),
        ('=',  'vs',  [], 3464.0),
    ]

# topography
if 'topo' in id_:
    fieldio += [
        ('=r', 'x3',  [], 'hold/z3.bin')
    ]

# boundary conditions
bc1 = 10, 10, 0
bc2 = 10, 10, 10

# moment tensor source
mts_ = os.path.join('run', 'data', '14383980.mts.py')
source = 'moment'
pulse = 'brune'
m = cst.util.load(mts_)
d = m.double_couple_clvd
source1 =  d['myy'],  d['mxx'],  d['mzz']
source2 = -d['mxz'], -d['myz'],  d['mxy']

# scaling law: fcorner = (dsigma / moment) ^ 1/3 * 0.42 * Vs,
# dsigma = 4 MPa, Vs = 3900 m/s, tau = 0.5 / (pi * fcorner)
tau = 6e-7 * m.moment ** (1.0 / 3.0) # ~0.32, fcorner = 0.5Hz

# sites
stagein = 'out/', 'hold/'
f = os.path.join('run', 'data', 'station-list.txt')
for s in open(f).readlines():
    s, y, x = s.split()[:3]
    x, y = proj(float(x), float(y))
    j = x / delta[0] + 1.0
    k = y / delta[1] + 1.0
    if register_:
        fieldio += [
            ('=w', 'v1', [j,k,1,()], 'out/' + s + '-v1.bin'),
            ('=w', 'v2', [j,k,1,()], 'out/' + s + '-v2.bin'),
            ('=w', 'v3', [j,k,1,()], 'out/' + s + '-v3.bin'),
        ]
    else:
        fieldio += [
            ('=wi', 'v1', [j,k,1,()], 'out/' + s + '-v1.bin'),
            ('=wi', 'v2', [j,k,1,()], 'out/' + s + '-v2.bin'),
            ('=wi', 'v3', [j,k,1,()], 'out/' + s + '-v3.bin'),
        ]

# cross section output
if 0:
    j, k, l = ihypo
    for f in 'v1', 'v2', 'v3', 'rho', 'vp', 'vs', 'gam':
        fieldio += [
            ('=w', f,  [j, (), (), (1,-1,10)], 'hold/xsec-ns-%s.bin' % f),
            ('=w', f,  [(), k, (), (1,-1,10)], 'hold/xsec-ew-%s.bin' % f),
        ]

# surface output
if surf_out_:
    ns = max(1, max(shape[:3]) / 1024)
    nh = 4 * ns
    mh = max(1, int(0.025 / dt_ + 0.5))
    ms = max(1, int(0.125 / (dt_ * mh) + 0.5))
    fieldio += [
        ('=w', 'v1',  [(1,-1,ns), (1,-1,ns), 1, (1,-1,mh)], 'hold/full-v1.bin'),
        ('=w', 'v2',  [(1,-1,ns), (1,-1,ns), 1, (1,-1,mh)], 'hold/full-v2.bin'),
        ('=w', 'v3',  [(1,-1,ns), (1,-1,ns), 1, (1,-1,mh)], 'hold/full-v3.bin'),
        ('#w', 'v1',  [(1,-1,ns), (1,-1,ns), 1, (1,-1,ms)], 'hold/snap-v1.bin'),
        ('#w', 'v2',  [(1,-1,ns), (1,-1,ns), 1, (1,-1,ms)], 'hold/snap-v2.bin'),
        ('#w', 'v3',  [(1,-1,ns), (1,-1,ns), 1, (1,-1,ms)], 'hold/snap-v3.bin'),
        ('#w', 'v1',  [(1,-1,nh), (1,-1,nh), 1, (1,-1,mh)], 'hold/hist-v1.bin'),
        ('#w', 'v2',  [(1,-1,nh), (1,-1,nh), 1, (1,-1,mh)], 'hold/hist-v2.bin'),
        ('#w', 'v3',  [(1,-1,nh), (1,-1,nh), 1, (1,-1,mh)], 'hold/hist-v3.bin'),
    ]

# stage job
if cst.conf.configure()[0].machine == 'usc-hpc':
    mpout = 0
job = cst.sord.stage(locals(), post='rm hold/z3.bin hold/rho.bin hold/vp.bin hold/vs.bin')
if not job.prepare:
    sys.exit()

# save metadata
path_ = job.rundir + os.sep
s = '\n'.join((
    open(mts_).read(),
    open(mesh_ + 'meta.py').read(),
    open(path_ + 'meta.py').read(),
))
open(path_ + 'meta.py', 'w').write(s)
os.link(mesh_ + 'box.txt', path_ + 'box.txt')

# save decimated mesh
if surf_out_:
    n = shape[:2]
    for f in 'lon.bin', 'lat.bin', 'topo.bin':
        s = np.fromfile(mesh_ + f, dtype).reshape(n[::-1])
        s[::ns,::ns].tofile(path_ + f)

# copy input files
for f in 'z3.bin', 'rho.bin', 'vp.bin', 'vs.bin':
    os.link(mesh_ + 'hold/' + f, path_ + 'hold/' + f)

# launch job
job = cst.sord.launch(job)

# post-process to compute pgv, pga
if surf_out_:
    path_ = job.rundir + os.sep
    meta = cst.util.load(path_ + 'meta.py')
    x, y, t = meta.shapes['hold/full-v1.bin']
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

