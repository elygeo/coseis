#!/usr/bin/env python
"""
setup WebSims repository
"""
import numpy, sord

# write WebSims metadata
meta = sord.util.loadmeta()
shape = meta.shape['v1']
websims = dict(
    title = 'Gouge - Shear source',
    author = 'Ely & Goebel',
    downloadable = True,
    label = '',
    t_axes = ( 'Time', 'X', 'Z' ),
    t_shape = shape[-1:] + shape[:-1],
    t_step = ( 1000000 * meta.dt, 100 * meta.dx[0] , 100 * meta.dx[2] ),
    t_unit = ( 'us', 'cm', 'cm' ),
    t_panes = [],
    x_axes = ( 'X', 'Z', 'Time' ),
    x_decimate = 1,
    x_shape = meta.shape['v1'],
    x_step = ( 100 * meta.dx[0] , 100 * meta.dx[2], 1000000 * meta.dt ),
    x_unit = ( 'cm', 'cm', 'us' ),
    x_initial_panes = [
        ( 'pv', 'Peak velocity (m/s)',   'w0', (0, 10.0), 3.0, 0 ),
        ( 'pu', 'Peak displacement (m)', 'w0', (0, 0.00001), 3.0, 0 ),
    ],
    x_panes = [
        ( 'v1', 'X velocity (m/s)', 'w2', (-10, 10), 3.0, 0 ),
        ( 'v2', 'Y velocity (m/s)', 'w2', (-10, 10), 3.0, 0 ),
        ( 'v3', 'Z velocity (m/s)', 'w2', (-10, 10), 3.0, 0 ),
    ],
    x_plot = [],
)
fd = open( 'meta.py', 'a' )
sord.util.save( fd, websims, [ 't_panes', 'x_initial_panes', 'x_panes', 'x_plot' ] )
fd.close()

# compute peak velocity and displacement
dtype = meta.dtype
nn = shape[:-1]
nt = shape[-1]
n  = numpy.prod( nn )
u1 = numpy.zeros( nn )
u2 = numpy.zeros( nn )
u3 = numpy.zeros( nn)
pv = numpy.zeros( nn )
pu = numpy.zeros( nn )
f1 = open( 'out/v1', 'rb' )
f2 = open( 'out/v2', 'rb' )
f3 = open( 'out/v3', 'rb' )
for i in xrange( nt ):
    v1 = numpy.fromfile( f1, dtype, n ).reshape( nn[::-1] ).T
    v2 = numpy.fromfile( f2, dtype, n ).reshape( nn[::-1] ).T
    v3 = numpy.fromfile( f3, dtype, n ).reshape( nn[::-1] ).T
    u1 = u1 + meta.dt * v1
    u2 = u2 + meta.dt * v2
    u3 = u3 + meta.dt * v3
    pv = numpy.maximum( pv, v1*v1 + v2*v2 + v3*v3 )
    pu = numpy.maximum( pu, u1*u1 + u2*u2 + u3*u3 )
numpy.array( numpy.sqrt( pv ), dtype ).T.tofile( 'pv' )
numpy.array( numpy.sqrt( pu ), dtype ).T.tofile( 'pu' )

