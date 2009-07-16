#!/usr/bin/env python
"""
Explosion test problem
"""
import numpy, sord
from sord.extras import source

#debug = 4
dx = 3 * [50.0]
dx = 3 * [100.0]
dx = 3 * [200.0]
np3 = 1, 1, 2

# material
hourglass = 0, 0
rho_, vp_, vs_ = 2670.0, 6000.0, 3464.0
mat_ = [
    ( '=', 'rho', [], rho_ ),
    ( '=', 'vp',  [], vp_  ),
    ( '=', 'vs',  [], vs_  ),
    ( '=', 'gam', [], 0.0  ),
]

#dt = dx[0] / 12500.0 * numpy.sqrt(3) * 1.2
dt = dx[0] / vp_ * 0.99
T = 4000.0
L = 6000.0
nn = [ int( L / dx[0] + 1.0001 ) ] * 3
nt =   int( T / dt + 1.0001 )
fixhypo = -1 

# output
def io( ihypo, dx ):
    _3 = 3000.0 / dx + 1
    _4 = 4000.0 / dx + 1
    fieldio = []
    for f in 'v1', 'v2', 'v3', 'e11', 'e22', 'e33':
        fieldio += [
            ( '=wi', f, [ 1,  1, _4, ()], 'p1_' + f ),
            ( '=wi', f, [ 1, _3, _4, ()], 'p2_' + f ),
            ( '=wi', f, [ 1, _4, _4, ()], 'p3_' + f ),
            ( '=wi', f, [_3, _3, _4, ()], 'p4_' + f ),
            ( '=wi', f, [_3, _4, _4, ()], 'p5_' + f ),
            ( '=wi', f, [_4, _4, _4, ()], 'p6_' + f ),
        ]
    return fieldio

# source properties
period = 0.1
bc2 = 10, 10, 10
source2 = 3 * [0.0]

# point source
nsource = 0
timefunction = 'brune'

if 0:
    rundir = 'tmp/1'
    source = 'moment'
    bc1 = 2, 2, 2
    ihypo = 1.5, 1.5, 1.5
    fieldio = mat_ + io( ihypo, dx[0] )
    source1 = 3 * [3*rho_*vp_*vp_ - 4*rho_*vs_*vs_]
    sord.run( locals() )

if 1:
    rundir = 'tmp/2'
    source = 'potency'
    bc1 = 1, 1, 1
    ihypo = 1, 1, 1
    fieldio = mat_ + io( ihypo, dx[0] )
    source1 = 3 * [1.0]
    source2 = 3 * [1.0]
    bc2 = 0, 0, 0
    sord.run( locals() )

# finite source
if 0:
    nsource = 1
    timefunction = 'none'
    infiles = [ 'tmp/src_*' ]
    dt_ = dt * 0.9
    t = dt_ * numpy.arange( nt )
    f = 1.0 - numpy.exp( -t / src_period ) / src_period * (t + src_period)

    rundir = 'tmp/3'
    source = 'moment'
    bc1 = 2, 2, 2
    ihypo = 1.5, 1.5, 1.5
    fieldio = mat_ + io( ihypo, dx )
    source1 = 3 * [3*rho_*vp_*vp_ - 4*rho_*vs_*vs_]
    source.src_write( f, nt, dt_, 0.0, ihypo, source1, source2, 'tmp' )
    sord.run( locals() )

    rundir = 'tmp/4'
    source = 'potency'
    bc1 = 1, 1, 1
    ihypo = 1, 1, 1
    fieldio = mat_ + io( ihypo, dx )
    source1 = 3 * [1.0]
    source.src_write( f, nt, dt_, 0.0, ihypo, source1, source2, 'tmp' )
    sord.run( locals() )

