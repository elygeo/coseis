#!/usr/bin/env python
"""
SORD simulation
"""
import os, imp, shutil
import numpy as np
import pyproj
import cst
prm = cst.sord.parameters()
s_ = cst.sord.s_

# resolution and parallelization
dx = 50.0;   prm.nproc3 = 1, 32, 480; nstripe = 32
dx = 100.0;  prm.nproc3 = 1, 4, 240;  nstripe = 16
dx = 200.0;  prm.nproc3 = 1, 1, 120;  nstripe = 8
dx = 500.0;  prm.nproc3 = 1, 1, 2;    nstripe = 2
dx = 1000.0; prm.nproc3 = 1, 1, 2;    nstripe = 1
dx = 4000.0; prm.nproc3 = 1, 1, 1;    nstripe = 1

# I/O
surf_out = True
surf_out = False
prm.itstats = 10
prm.itio = nstripe * 100

# surface topography
surf = 'topo'
surf = 'flat'

# align receivers to mesh nodes
register = True
register = False

# cvm version
for cvm in 'cvms', 'cvmh', 'cvmg':

    # simulation name
    mesh = 'ch%04.0f%s' % (dx, cvm[-1])
    name = mesh + surf[0]

    # mesh metadata
    mesh = os.path.join('run', 'mesh', mesh) + os.sep
    meta = imp.load_source(mesh + 'meta.py')
    dtype = meta.dtype
    delta = meta.delta
    shape = meta.shape
    hypo = meta.origin
    prm.npml = meta.npml

    # translate projection to lower left origin
    x, y = meta.bounds[:2]
    proj = pyproj.Proj(**meta.projection)
    proj = cst.coord.Transform(proj, translate=(-x[0], -y[0]))

    # dimensions
    dt = dx / 16000.0
    dt = dx / 20000.0
    nt = int(90.0 / dt + 1.00001)
    prm.delta = delta + (dt,)
    prm.shape = shape + (nt,)

    # material
    prm.hourglass = 1.0, 1.0
    prm.vp1 = 1500.0
    prm.vs1 = 500.0
    prm.vdamp = 400.0
    prm.gam2 = 0.8
    prm.fieldio = [
        ('=r', 'rho', [], 'hold/rho.bin'),
        ('=r', 'vp',  [], 'hold/vp.bin'),
        ('=r', 'vs',  [], 'hold/vs.bin'),
    ]

    # topography
    if surf == 'topo':
        prm.fieldio += [
            ('=r', 'x3',  [], 'hold/z3.bin')
        ]

    # boundary conditions
    prm.bc1 = 10, 10, 0
    prm.bc2 = 10, 10, 10

    # source
    prm.source = 'moment'
    prm.pulse = 'brune'
    mts = os.path.join('run', 'data', '14383980.mts.py')
    m = imp.load_source(mts)
    d = m.double_couple_clvd
    prm.source1 =  d['myy'],  d['mxx'],  d['mzz']
    prm.source2 = -d['mxz'], -d['myz'],  d['mxy']

    # scaling law: fcorner = (dsigma / moment) ^ 1/3 * 0.42 * Vs,
    # dsigma = 4 MPa, Vs = 3900 m/s, tau = 0.5 / (pi * fcorner)
    prm.tau = 6e-7 * m.moment ** (1.0 / 3.0) # ~0.32, fcorner = 0.5Hz

    # hypocenter location at x/y center
    x, y, z = hypo
    x, y = proj(x, y)
    j = abs(x / delta[0]) + 1.0
    k = abs(y / delta[1]) + 1.0
    l = abs(z / delta[2]) + 1.0
    if register:
        l = int(l) + 0.5
    prm.ihypo = j, k, l

    # receivers
    if register:
        m = '=w'
    else:
        m = '=wi'
    f = os.path.join('run', 'data', 'station-list.txt')
    for s in open(f).readlines():
        s, y, x = s.split()[:3]
        x, y = proj(float(x), float(y))
        j = x / delta[0] + 1.0
        k = y / delta[1] + 1.0
        prm.fieldio += [
            (m, 'vs', [j,k,1,()], 'out/' + s + '-vs.bin'),
            (m, 'v1', [j,k,1,()], 'out/' + s + '-v1.bin'),
            (m, 'v2', [j,k,1,()], 'out/' + s + '-v2.bin'),
            (m, 'v3', [j,k,1,()], 'out/' + s + '-v3.bin'),
        ]

    # surface output
    if surf_out:
        ns = max(1, max(shape[:3]) / 1024)
        nh = 4 * ns
        mh = max(1, int(0.025 / dt + 0.5))
        ms = max(1, int(0.125 / (dt * mh) + 0.5))
        prm.fieldio += [
            ('=w', 'v1', s_[::ns,::ns,1,::mh], 'hold/full-v1.bin'),
            ('=w', 'v2', s_[::ns,::ns,1,::mh], 'hold/full-v2.bin'),
            ('=w', 'v3', s_[::ns,::ns,1,::mh], 'hold/full-v3.bin'),
            ('#w', 'v1', s_[::ns,::ns,1,::ms], 'hold/snap-v1.bin'),
            ('#w', 'v2', s_[::ns,::ns,1,::ms], 'hold/snap-v2.bin'),
            ('#w', 'v3', s_[::ns,::ns,1,::ms], 'hold/snap-v3.bin'),
            ('#w', 'v1', s_[::nh,::nh,1,::mh], 'hold/hist-v1.bin'),
            ('#w', 'v2', s_[::nh,::nh,1,::mh], 'hold/hist-v2.bin'),
            ('#w', 'v3', s_[::nh,::nh,1,::mh], 'hold/hist-v3.bin'),
        ]

    # cross section output
    if 0:
        j, k, l = prm.ihypo
        for f in 'v1', 'v2', 'v3', 'rho', 'vp', 'vs', 'gam':
            prm.fieldio += [
                ('=w', f, s_[j,:,:,::10], 'hold/xsec-ns-%s.bin' % f),
                ('=w', f, s_[:,k,:,::10], 'hold/xsec-ew-%s.bin' % f),
            ]

    # run directory
    path = os.path.join('run', 'sim', name) + os.sep
    hold = os.path.join(path, 'hold') + os.sep
    os.makedirs(hold)

    # save metadata
    os.link(mesh + 'box.txt', path + 'box.txt')
    s = '\n'.join([
        f1 = open(mesh + 'meta.py').read(),
        f2 = open(mts).read(),
        f3 = open(path + 'meta.py').read(),
    ])
    open(path + 'meta.py', 'w').write(s)

    # save decimated mesh
    if surf_out:
        n = shape[:2]
        for f in 'lon.bin', 'lat.bin', 'topo.bin':
            s = np.fromfile(mesh + f, dtype).reshape(n[::-1])
            s[::ns,::ns].tofile(path + f)

    # link input files
    h = mesh + 'hold' + os.sep
    for f in 'z3', 'rho', 'vp', 'vs':
        os.link(h + f + '.bin', hold + f + '.bin')

    # run SORD
    job = cst.sord.run(prm, rundir=path)

    # post-process to compute pgv, pga
    if surf_out:
        meta = imp.load_source('meta', path + 'meta.py')
        x, y, t = meta.shapes['hold/full-v1.bin']
        m = x * y * t // 60000000
        shutil.copy2('cook.py', path)
        cst.util.launch(
            depend = job.jobid,
            rundir = path,
            run = job.run,
            name = 'cook',
            command = '{python} cook.py',
            minutes = m,
        )

