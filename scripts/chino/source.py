#!/usr/bin/env python
"""
Chino Hills source preperation
http://earthquake.usgs.gov/eqcenter/eqinthenews/2008/ci14383980/
"""
import numpy, sord, sim

lon, lat, dep = -117.761, 33.953, 14700.0
w1 = -1450e14,  602e14,  844e14
w2 =  -689e14, -198e14,  495e14
w1 = 1.0e20, 1.0e20, 1.0e20
w2 = 0.0, 0.0, 0.0

# Coordinates
x, y = sim.projection( lon, lat )
ihypo = (
     x   / sim.dx[0] + 1.0,
     y   / sim.dx[1] + 1.0,
    -dep / sim.dx[2] + 1.0,
)

# Time function
tc = 2.0
s = 0.5
t = sim.dt * numpy.arange( sim.nt )
history = ( numpy.exp( ( t - tc ) ** 2.0 / ( -2.0 * s ** 2.0 ) )
          / ( s * numpy.sqrt( 2.0 * numpy.pi ) ) )
history = numpy.cumsum( history )
history = history / history[-1]
nt = history.size
t0 = 0.0

# Moment tensor rotation
rot = (0, 1, 0), (-1, 0, 0), (0, 0, 1)
w1, w2 = sord.coord.rot_sym_tensor( w1, w2, rot )
rot = numpy.eye(3)
rot[:2,:2] = sord.coord.rotation( lon, lat, sim.projection )[0]
w1, w2 = sord.coord.rot_sym_tensor( w1, w2, rot )

# Write SORD source input
sord.source.src_write( history, nt, sim.dt, t0, ihypo, w1, w2, '~/run/tmp' )

