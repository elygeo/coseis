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
_T = 3.0
_L = 6000.0
nn = [ int( _L / dx[0] + 1.0001 ) ] * 3
nt =   int( _T / dt + 1.0001 )
fixhypo = -1 

# material
_rho, _vp, _vs = 2670.0, 6000.0, 3464.0
fieldio = [
    ( '=', 'rho', [], _rho ),
    ( '=', 'vp',  [], _vp  ),
    ( '=', 'vs',  [], _vs  ),
    ( '=', 'gam', [],  0.0 ),
]

# output
for _f in 'x1', 'x2', 'x3', 'v1', 'v2', 'v3':
    fieldio += [
        ( '=wx', _f, [], 'p1_'+_f, (  -1.,   -1., 3999.) ),
        ( '=wx', _f, [], 'p2_'+_f, (  -1., 2999., 3999.) ),
        ( '=wx', _f, [], 'p3_'+_f, (  -1., 3999., 3999.) ),
        ( '=wx', _f, [], 'p4_'+_f, (2999., 2999., 3999.) ),
        ( '=wx', _f, [], 'p5_'+_f, (2999., 3999., 3999.) ),
        ( '=wx', _f, [], 'p6_'+_f, (3999., 3999., 3999.) ),
    ]

# source properties
src_period = 0.1
bc2 = 10, 10, 10
src_w2 = 3 * [ 0.0 ]

# point source
if 0:
    src_n = 0
    src_function = 'brune'
    rundir = 'tmp/1'
    src_type = 'moment'
    bc1 = 2, 2, 2
    ihypo = 1.5, 1.5, 1.5
    src_w1 = 3 * [ 3*_rho*_vp*_vp - 4*_rho*_vs*_vs ]
    sord.run( locals() )
    rundir = 'tmp/2'
    src_type = 'potency'
    bc1 = 1, 1, 1
    ihypo = 1, 1, 1
    src_w1 = 3 * [ 1.0 ]
    sord.run( locals() )

# finite source
if 1:
    src_n = 1
    src_function = 'none'
    infiles = [ 'tmp/src_*' ]
    _dt = dt * 0.9
    _t = _dt * numpy.arange( nt )
    _f = 1.0 - numpy.exp( -_t / src_period ) / src_period * ( _t + src_period )

    rundir = 'tmp/3'
    src_type = 'moment'
    bc1 = 2, 2, 2
    ihypo = 1.5, 1.5, 1.5
    src_w1 = 3 * [ 3*_rho*_vp*_vp - 4*_rho*_vs*_vs ]
    source.write_src( _f, nt, _dt, 0.0, ihypo, src_w1, src_w2, 'tmp' )
    sord.run( locals() )
    asdf

    rundir = 'tmp/4'
    src_type = 'potency'
    bc1 = 1, 1, 1
    ihypo = 1, 1, 1
    src_w1 = 3 * [ 1.0 ]
    source.write_src( _f, nt, _dt, 0.0, ihypo, src_w1, src_w2, 'tmp' )
    sord.run( locals() )

