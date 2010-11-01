#!/usr/bin/env python
"""
Explosion test problem
"""
import os
import numpy as np
import cst

# parameters
nproc3 = 1, 1, 2
delta = 200.0, 200.0, 200.0, 0.03
delta = 100.0, 100.0, 100.0, 0.015
delta = 50.0, 50.0, 50.0, 0.0075
bc1 = 1, 1, 1; ihypo = 1.0, 1.0, 1.0
bc1 = 2, 2, 2; ihypo = 1.5, 1.5, 1.5
bc2 = 10, 10, 10
sources_ = [
    ('potency', 1.0),
    #('moment', 3*rho_*vp_*vp_ - 4*rho_*vs_*vs_),
]

# dimensions
shape = [
    int( 6000.0 / delta[0] + 1.0001 ),
    int( 6000.0 / delta[1] + 1.0001 ),
    int( 6000.0 / delta[2] + 1.0001 ),
    int(    3.0 / delta[3] + 1.0001 ),
]

# material
hourglass = 1.0, 1.0
rho_, vp_, vs_ = 2670.0, 6000.0, 3464.0
fieldio = [
    ('=', 'rho', [], rho_),
    ('=', 'vp',  [], vp_),
    ('=', 'vs',  [], vs_),
    ('=', 'gam', [], 0.0),
]

# output
i = ihypo[0]
_3 = 3000.0 / delta[0] + i
_4 = 4000.0 / delta[0] + i
op = '=w'
op = '=wi'
for f in 'v1', 'v2', 'v3', 'e11', 'e22', 'e33':
    fieldio += [
        (op, f, [ i,  i, _4, ()], 'p1_%s.bin' % f),
        (op, f, [ i, _3, _4, ()], 'p2_%s.bin' % f),
        (op, f, [ i, _4, _4, ()], 'p3_%s.bin' % f),
        (op, f, [_3, _3, _4, ()], 'p4_%s.bin' % f),
        (op, f, [_3, _4, _4, ()], 'p5_%s.bin' % f),
        (op, f, [_4, _4, _4, ()], 'p6_%s.bin' % f),
    ]
fieldio += [
    ('=w', 'v1', [i, (), (), (1, -1, 10)], 'snap_v1.bin'),
    ('=w', 'v2', [i, (), (), (1, -1, 10)], 'snap_v2.bin'),
    ('=w', 'v3', [i, (), (), (1, -1, 10)], 'snap_v3.bin'),
]

# loop over sources
for source, s in sources_:

    # source properties
    period = 0.1
    source1 = s, s, s
    source2 = 0.0, 0.0, 0.0

    # point source
    if 0:
        nsource = 0
        rundir = os.path.join( 'run', 'point-' + source )
        timefunction = 'brune'
        cst.sord.run( locals() )

    # finite source
    if 1:
        nsource = 1
        rundir = os.path.join( 'run', 'finite-' + source )
        timefunction = 'none'
        dt = delta[-1]
        n = shape[-1]
        t = dt * np.arange( n )
        f = 1.0 - np.exp(-t / period) / period * (t + period)
        job = cst.sord.stage( locals() )
        d = os.path.join( rundir, 'source' )
        cst.source.write( f, n, dt, 0.0, ihypo, source1, source2, d )
        cst.sord.run( job )

