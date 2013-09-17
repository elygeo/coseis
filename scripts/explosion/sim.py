#!/usr/bin/env python
"""
Explosion test problem
"""
import os, math
import numpy as np
import cst
prm = {}

# parameters
prm['oplevel'] = 6
prm['nproc3'] = [1, 1, 2]
prm['delta'] = [50.0, 50.0, 50.0, 0.004]
prm['delta'] = [100.0, 100.0, 100.0, 0.015]
prm['delta'] = [200.0, 200.0, 200.0, 0.03]
prm['delta'] = [200.0, 200.0, 200.0, 0.016]
prm['bc1'] = [1, 1, 1]; prm['ihypo'] = [1.0, 1.0, 1.0]
prm['bc1'] = [2, 2, 2]; prm['ihypo'] = [1.5, 1.5, 1.5]
prm['bc2'] = [10, 10, 10]
rho, vp, vs = 2670.0, 6000.0, 3464.0
sources = [
    ('potency', 1.0),
    #('moment', 3*rho*vp*vp - 4*rho*vs*vs),
]

# dimensions
prm['shape'] = [
    int(6000.0 / prm['delta'][0] + 1.0001),
    int(6000.0 / prm['delta'][1] + 1.0001),
    int(6000.0 / prm['delta'][2] + 1.0001),
    int(   3.0 / prm['delta'][3] + 1.0001),
]

# material
prm['hourglass'] = [1.0, 1.0]
prm['fieldio'] = [
    'rho = {}'.format(rho),
    'vp  = {}'.format(vp),
    'vs  = {}'.format(vs),
    'gam = 0.0',
]

# output
w = 'write'
w = 'write~'
j = prm['ihypo'][0]
k = 3000.0 / prm['delta'][0] + j
l = 4000.0 / prm['delta'][0] + j
for f in 'v1', 'v2', 'v3', 'e11', 'e22', 'e33':
    prm['fieldio'] += [
        '{}[{},{},{},:] {} p1-{}.bin'.format(f, j, j, l, w, f),
        '{}[{},{},{},:] {} p2-{}.bin'.format(f, j, k, l, w, f),
        '{}[{},{},{},:] {} p3-{}.bin'.format(f, j, j, l, w, f),
        '{}[{},{},{},:] {} p4-{}.bin'.format(f, k, k, l, w, f),
        '{}[{},{},{},:] {} p5-{}.bin'.format(f, k, j, l, w, f),
        '{}[{},{},{},:] {} p6-{}.bin'.format(f, j, j, l, w, f),
    ]

prm['fieldio'] += [
    'v1[{},:,:,::10] write snap-v1.bin'.format(j),
    'v2[{},:,:,::10] write snap-v2.bin'.format(j),
    'v3[{},:,:,::10] write snap-v3.bin'.format(j),
]

# loop over sources
cwd = os.getcwd()
for source, s in sources:

    # source properties
    prm['source'] = source
    prm['tau'] = 0.1
    prm['source1'] = [s, s, s]
    prm['source2'] = [0.0, 0.0, 0.0]

    # point source
    if 1:
        prm['nsource'] = 0
        prm['pulse'] = 'integral_brune'
        prm['rundir'] = p = os.path.join('run', 'point-' + source)
        os.makedirs(p)
        cst.sord.run(prm)

    # finite source
    if 0:
        prm['nsource'] = 1
        prm['pulse'] = 'none'
        d = prm['delta'][-1]
        n = prm['shape'][-1]
        t = d * np.arange(n)
        f = 1.0 - math.exp(-t / prm['tau']) / prm['tau'] * (t + prm['tau'])
        p = os.path.join('run', 'finite-' + source)
        q = os.path.join(p, 'source')
        os.makedirs(q)
        os.chdir(p)
        cst.source.write(f, n, d, 0.0, prm['ihypo'], prm['source1'], prm['source2'], q)
        cst.sord.run(prm)
        os.chdir(cwd)

