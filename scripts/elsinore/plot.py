#!/usr/bin/env ipython -wthread
"""
Visualization
"""
import os, numpy, sord, sim
from enthought.mayavi import mlab

dir = '~/run/elsinore-uhs'
dir = '~/run/elsinore-1d'
dir = '~/run/elsinore-cvm'
dir = os.path.expanduser( dir )
extent = 0., 600000., 0., 300000., -80000., 4000.

mlab.figure( name='Elsinore', size=(960,540) )
mlab.clf()

# topo
n = 960, 780
dll = 0.5 / 60.0
lon0 = -121.5 + 0.5 * dll
lat0 =   30.5 + 0.5 * dll
topo = numpy.fromfile( 'data/socal-topo.f32', 'f' ).reshape( n[::-1] ).T

# fault plane
if 1:
    meta, data = sord.source.srfb_read( sim._srf )
    n = meta.nsource2[::-1]
    x = data.lon.reshape( n )
    y = data.lat.reshape( n )
    z = -data.dep.reshape( n ) + sord.coord.interp2( lon0, lat0, dll, dll, topo, x, y )
    x, y = projection( x, y )
    s = ( data.slip.reshape( n+(3,) )**2 ).sum(2)
    t = data.t0.reshape( n )
    hfault = mlab.mesh( x, y, z, scalars=s )

# map data
for f in 'gmt-socal-coast.ll', 'gmt-socal-borders.ll', 'ucla-fault-db-mod.ll':
    x, y = numpy.loadtxt( 'data/' + f, usecols=(0,1), unpack=True )
    z = sord.coord.interp2( lon0, lat0, dll, dll, topo, x, y )
    x, y = projection( x, y )
    mlab.plot3d( x, y, z, color=(0.,0.,0.), tube_radius=None, line_width=0.5 )

# surface
caxis = -0.2, 0.2
exag = 10000. / caxis[1]
meta = sord.util.loadmeta( dir )
n = meta.shape['x1']
x = numpy.fromfile( dir + '/out/x1', 'f' ).reshape( n[::-1] ).T
y = numpy.fromfile( dir + '/out/x2', 'f' ).reshape( n[::-1] ).T
z = numpy.fromfile( dir + '/out/x3', 'f' ).reshape( n[::-1] ).T
hsurf = mlab.mesh( x, y, z, scalars=z/2000*caxis[1], opacity=1.0 )

slm = hsurf.module_manager.scalar_lut_manager
slm.use_default_range = False
slm.data_range = caxis
slm.lut.table = sord.viz.colormap( 'w2' )
#slm.show_scalar_bar = True

scene = mlab.get_engine().scenes[0].scene
mlab.outline( extent=extent )
if 1:
    mlab.view( -45, 45, 600000, ( 350000, 150000, 0 ) )
elif 1:
    mlab.view( -45, 135, 600000, ( 350000, 150000, 0 ) )
else:
    mlab.view( 0, 0, 600000, ( 300000, 150000, 0 ) )
    scene.parallel_projection = True
    scene.camera.zoom(4.6)
mlab.show()

n = meta.shape['v1']
comp = 0
ii = range( 1, n[2]+1, 2 )
ii = range( 100, 600, 5 )
ii = []
for i in ii:
    print i
    v1 = sord.util.ndread( dir + '/out/v1', n, [(),(),i] ).squeeze()
    v2 = sord.util.ndread( dir + '/out/v2', n, [(),(),i] ).squeeze()
    v3 = sord.util.ndread( dir + '/out/v3', n, [(),(),i] ).squeeze()
    v  = numpy.array([ v1, v2, v3 ])
    if comp:
        v = v[comp]
    else:
        v = numpy.sqrt( (v*v).sum(0) )
    hsurf.mlab_source.set( z=z+exag*v, scalars=v )
    scene.render()

