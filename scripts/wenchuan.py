#!/usr/bin/env python
"""
Wenchuan earthquake
"""
import sord

np3 = 1, 1, 2
dx = 1000.0, 1000.0, -1000.0
T = 120.0
L = 400e3, 300e3, 60e3
dt = dx[0] / 12500.0
nt = int( T / dt + 1.5 )
nn = [ int( x / dx[0] + 1.5 ) for x in L ]
bc1 = 10, 10, 10
bc2 = 10, 10, 0

# Source
xhypo = 0.0, 0.0, -12e3
ihypo = nn[0]/2-0.5, nn[1]/2-0.5, -xhypo[2]/dx[2]
source = 'moment'
source1 = -5.79e20, 0.10e20, 5.69e20    #  Mpp,  Mtt,  Mrr
source2 = -1.99e20, 5.61e20, 3.48e20    # -Mrt,  Mrp, -Mtp
timefunction = 'brune'
period = 0.1
fixhypo = -1

# Velocity model
fieldio = [ ('=', 'gam', [], 0.2) ]
material_ = [
    ( 0.0, 5800.0, 3370.0),
    (10e3, 6200.0, 3600.0),
    (16e3, 6600.0, 3840.0),
    (24e3, 7000.0, 3940.0),
    (33e3, 7800.0, 4380.0),
]
for depth_, vp_, vs_ in material_:
    rho_ = vp_ / 3.0 + 1280.0
    i = -int( depth_ / dx[2] + 1.5 )
    fieldio += [
        ( '=', 'rho', [(), (), (1,i), ()], rho_ ),
        ( '=', 'vp',  [(), (), (1,i), ()], vp_  ),
        ( '=', 'vs',  [(), (), (1,i), ()], vs_  ),
    ]

# Output
for f in 'v1', 'v2', 'v3':
    fieldio += [
        ( '=wx', f, [], 'Epicenter-' + f, ( 0.0,   0.0, 0.0), ),
        ( '=wx', f, [], 'Wenchuan-'  + f, (30e3,  52e3, 0.0), ),
        ( '=wx', f, [], 'Maoxian-'   + f, (60e3,  70e3, 0.0), ),
        ( '=wx', f, [], 'Chengdu-'   + f, (84e3, -36e3, 0.0), ),
    ]

sord.run( locals() )

