#!/usr/bin/env python
"""
Explosion test problem
"""
import numpy, sord
from sord.extras import source

dx = [ 50.0 ] * 3
dx = [ 100.0 ] * 3
np3 = 1, 1, 2

dt = dx[0] / 12500.0
T = 3.0
L = 6000.0
nn = [ int( L / dx[0] + 1.0001 ) ] * 3
nt =   int( T / dt + 1.0001 )
fixhypo = -1 

# material
rho_, vp_, vs_ = 2670.0, 6000.0, 3464.0
fieldio = [
    ( '=', 'rho', [], rho_ ),
    ( '=', 'vp',  [], vp_  ),
    ( '=', 'vs',  [], vs_  ),
    ( '=', 'gam', [], 0.0  ),
]

# output
for f in 'x1', 'x2', 'x3', 'v1', 'v2', 'v3':
    fieldio += [
        ( '=wx', f, [], 'p1_'+f, (  -1.0,   -1.0, 3999.0) ),
        ( '=wx', f, [], 'p2_'+f, (  -1.0, 2999.0, 3999.0) ),
        ( '=wx', f, [], 'p3_'+f, (  -1.0, 3999.0, 3999.0) ),
        ( '=wx', f, [], 'p4_'+f, (2999.0, 2999.0, 3999.0) ),
        ( '=wx', f, [], 'p5_'+f, (2999.0, 3999.0, 3999.0) ),
        ( '=wx', f, [], 'p6_'+f, (3999.0, 3999.0, 3999.0) ),
    ]

# source properties
period = 0.1
bc2 = 10, 10, 10
source2 = 3 * [ 0.0 ]

# point source
if 0:
    nsource = 0
    timefunction = 'brune'

    rundir = 'tmp/1'
    source = 'moment'
    bc1 = 2, 2, 2
    ihypo = 1.5, 1.5, 1.5
    source1 = 3 * [ 3*rho_*vp_*vp_ - 4*rho_*vs_*vs_ ]
    sord.run( locals() )

    rundir = 'tmp/2'
    source = 'potency'
    bc1 = 1, 1, 1
    ihypo = 1, 1, 1
    source1 = 3 * [ 1.0 ]
    sord.run( locals() )

# finite source
if 1:
    nsource = 1
    timefunction = 'none'
    infiles = [ 'tmp/src_*' ]
    dt_ = dt * 0.9
    t = dt_ * numpy.arange( nt )
    f = 1.0 - numpy.exp( -t / src_period ) / src_period * ( t + src_period )

    rundir = 'tmp/3'
    source = 'moment'
    bc1 = 2, 2, 2
    ihypo = 1.5, 1.5, 1.5
    source1 = 3 * [ 3*rho_*vp_*vp_ - 4*rho_*vs_*vs_ ]
    source.write_src( f, nt, dt_, 0.0, ihypo, source1, source2, 'tmp' )
    sord.run( locals() )

    rundir = 'tmp/4'
    source = 'potency'
    bc1 = 1, 1, 1
    ihypo = 1, 1, 1
    source1 = 3 * [ 1.0 ]
    source.write_src( f, nt, dt_, 0.0, ihypo, source1, source2, 'tmp' )
    sord.run( locals() )

