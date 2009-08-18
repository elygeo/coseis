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

# topography
elev = 0
if 'topo' in sim.grid_:
    n = 960, 780
    topo_dll = 0.5 / 60.0
    topo_lon0 = -121.5 + 0.5 * topo_dll
    topo_lat0 =   30.5 + 0.5 * topo_dll
    topo = numpy.fromfile( 'data/socal-topo.f32', 'f' ).reshape( n[::-1] ).T
    elev = sord.coord.interp2( topo_lon0, topo_lat0, topo_dll, topo_dll, topo, [lon], [lat] )
    print elev

# Coordinates
x, y, z = sim.projection( lon, lat, elev - dep )
print x, y, z
ihypo = (
     x   / sim.dx[0] + 1.0,
     y   / sim.dx[1] + 1.0,
    -dep / sim.dx[2] + 1.0,
)

# Time function
tc = 2.0
s = 0.5
t = sim.dt * numpy.arange( sim.nt )
history = ( numpy.exp( (t - tc) ** 2.0 / (-2.0 * s ** 2.0) )
          / (s * numpy.sqrt( 2.0 * numpy.pi )) )
history = numpy.cumsum( history )
history = history / history[-1]
nt = history.size
t0 = 0.0

# Moment tensor rotation
rot = (0, 1, 0), (-1, 0, 0), (0, 0, 1)
w1, w2 = sord.coord.rot_sym_tensor( w1, w2, rot )
#rot = numpy.eye(3)
#rot[:2,:2] = sord.coord.rotation3( lon, lat, -dep, sim.projection )[0]
rot = sord.coord.rotation3( lon, lat, -dep, sim.projection )[0]
w1, w2 = sord.coord.rot_sym_tensor( w1, w2, rot )

# Write SORD source input
sord.source.src_write( history, nt, sim.dt, t0, ihypo, w1, w2, '~/run/tmp' )

