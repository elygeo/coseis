#!/usr/bin/env python
"""
Post-processing:
compute PGV, PGD
decimate velocities records
setup WebSims repository
"""
import numpy, sord, time

# demimation factors
dix_x = 1
dit_x = 25
dix_t = 2
dit_t = 2

# write WebSims metadata
meta = sord.util.loadmeta()
dtype = meta.dtype
dt = meta.dt
dx = meta.dx
shape = meta.shape['v1']
x_shape = (shape[0]-1)/dix_x+1, (shape[1]-1)/dix_x+1, (shape[2]-1)/dit_x+1
t_shape = (shape[2]-1)/dit_t+1, (shape[0]-1)/dix_t+1, (shape[1]-1)/dix_t+1
websims = dict(
    title = 'Elsinore Mw7.75 scenario',
    author = 'Geoffrey Ely',
    downloadable = True,
    label = '',
    t_axes = ('Time', 'X', 'Y'),
    t_shape = t_shape,
    t_step = (dt*dit_t, 0.001*dx[0]*dix_t, 0.001*dx[1]*dix_t),
    t_unit = ('s', 'km', 'km'),
    x_axes = ('X', 'Y', 'Time'),
    x_decimate = 1,
    x_shape = x_shape,
    x_step = ( 0.001*dx[0]*dix_x, 0.001*dx[1]*dix_x, dt*dit_x),
    x_unit = ('km', 'km', 's'),
    t_title = 'Velocity time history'
    t_panes = [
        (('v1_t',), 'X Velocity (m/s)'),
        (('v2_t',), 'Y Velocity (m/s)'),
        (('v3_t',), 'Z Velocity (m/s)'),
    ],
    x_initial_title = 'Peak ground motion maps'
    x_initial_panes = [
        ('pgv', 'Peak velocity (m/s)',   'w00', (0, 4.0), 2.0),
        ('pgd', 'Peak displacement (m)', 'w00', (0, 8.0), 2.0),
    ],
    x_title = 'Ground velocity snapshot'
    x_panes = [
        ('v1_x', 'X velocity (m/s)', 'w2', (-1, 1), 2.0),
        ('v2_x', 'Y velocity (m/s)', 'w2', (-1, 1), 2.0),
        ('v3_x', 'Z velocity (m/s)', 'w2', (-1, 1), 2.0),
    ],
    x_plot  = [
        ('trace.xyz', 'k-'),
        ('gmt-socal-coast.xyz', 'k-'),
        ('gmt-socal-boders.xyz', 'k-'),
        ( 'dlg-ca-roads.xyz', 'k-' ),
    ],
)
fd = open( 'meta.py', 'a' )
sord.util.save( fd, websims, ['t_panes', 'x_initial_panes', 'x_panes', 'x_plot'] )
fd.close()

# decimate arrays and compute PGV, PGD
nn = shape[:-1]
nt = shape[-1]
n  = numpy.prod( nn )
u1 = numpy.zeros( nn )
u2 = numpy.zeros( nn )
u3 = numpy.zeros( nn)
pgv = numpy.zeros( nn )
pgd = numpy.zeros( nn )
f1   = open( 'out/v1', 'rb' )
f2   = open( 'out/v2', 'rb' )
f3   = open( 'out/v3', 'rb' )
f1_x = open( 'v1_x', 'wb' )
f2_x = open( 'v2_x', 'wb' )
f3_x = open( 'v3_x', 'wb' )
f1_t = open( 'v1_t', 'wb' )
f2_t = open( 'v2_t', 'wb' )
f3_t = open( 'v3_t', 'wb' )
t0 = time.time()
for i in xrange( nt ):
    v1 = numpy.fromfile( f1, dtype, n ).reshape( nn[::-1] ).T
    v2 = numpy.fromfile( f2, dtype, n ).reshape( nn[::-1] ).T
    v3 = numpy.fromfile( f3, dtype, n ).reshape( nn[::-1] ).T
    u1 = u1 + dt * v1
    u2 = u2 + dt * v2
    u3 = u3 + dt * v3
    pgv = numpy.maximum( pgv, v1*v1 + v2*v2 + v3*v3 )
    pgd = numpy.maximum( pgd, u1*u1 + u2*u2 + u3*u3 )
    if numpy.mod( i, dit_x ) == 0:
        v1[::dix_x,::dix_x].T.tofile( f1_x )
        v2[::dix_x,::dix_x].T.tofile( f2_x )
        v3[::dix_x,::dix_x].T.tofile( f3_x )
    if numpy.mod( i, dit_t ) == 0:
        v1[::dix_t,::dix_t].T.tofile( f1_t )
        v2[::dix_t,::dix_t].T.tofile( f2_t )
        v3[::dix_t,::dix_t].T.tofile( f3_t )
    sord.util.progress( i+1, nt, time.time()-t0 )
f1_x.close()
f2_x.close()
f3_x.close()
f1_t.close()
f2_t.close()
f3_t.close()
numpy.array( numpy.sqrt( pgv ), dtype ).T.tofile( 'pgv' )
numpy.array( numpy.sqrt( pgd ), dtype ).T.tofile( 'pgd' )
del( v1, v2, v3, u1, u2, u3, pgv, pgd )

# transpose time history arrays
nn = t_shape[0], t_shape[1] * t_shape[2] * t_shape[3]
n = nn[0] * nn[1]
numpy.fromfile( 'v1_t', dtype, n ).reshape( nn ).T.tofile( 'v1_t' )
numpy.fromfile( 'v2_t', dtype, n ).reshape( nn ).T.tofile( 'v2_t' )
numpy.fromfile( 'v3_t', dtype, n ).reshape( nn ).T.tofile( 'v3_t' )

