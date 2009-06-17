#!/usr/bin/env ipython -wthread
"""
Visualization
"""
import os, numpy, sord, sim
from enthought.mayavi import mlab

rundir = '~/run/elsinore-uhs'
rundir = '~/run/elsinore-1d'
rundir = '~/run/elsinore-cvm'
rundir = os.path.expanduser( rundir )
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
    path = sim.srf_ + os.sep
    meta = {}
    exec open( path + 'meta.py' ) in meta
    nn = meta.nsource2
    dtype = meta.dtype
    x = numpy.fromfile( path + 'lon', dtype ).reshape( nn[::-1] ).T
    y = numpy.fromfile( path + 'lat', dtype ).reshape( nn[::-1] ).T
    z = numpy.fromfile( path + 'dep', dtype ).reshape( nn[::-1] ).T
    z = sord.coord.interp2( lon0, lat0, dll, dll, topo, x, y ) - z
    x, y = sim.projection( x, y )
    if 0:
        s = numpy.fromfile( path + 't0',    dtype ).reshape( nn[::-1] ).T
    else:
        x = numpy.fromfile( path + 'slip1', dtype ).reshape( nn[::-1] ).T
        y = numpy.fromfile( path + 'slip2', dtype ).reshape( nn[::-1] ).T
        z = numpy.fromfile( path + 'slip3', dtype ).reshape( nn[::-1] ).T
        s = numpy.sqrt( x**2 + y**2 + z**2 )
    mlab.mesh( x, y, z, scalars=s )

# map data
for f in 'gmt-socal-coast.ll', 'gmt-socal-borders.ll', 'ucla-fault-db-mod.ll':
    x, y = numpy.loadtxt( 'data/' + f, usecols=(0,1), unpack=True )
    z = sord.coord.interp2( lon0, lat0, dll, dll, topo, x, y )
    x, y = sim.projection( x, y )
    mlab.plot3d( x, y, z, color=(0, 0, 0), tube_radius=None, line_width=0.5 )

# surface
path = os.path.join( rundir, 'out' ) + os.sep
caxis = -0.2, 0.2
exag = 10000. / caxis[1]
meta = sord.util.loadmeta( rundir )
n = meta.shape['x1']
x = numpy.fromfile( path + 'x1', 'f' ).reshape( n[::-1] ).T
y = numpy.fromfile( path + 'x2', 'f' ).reshape( n[::-1] ).T
z = numpy.fromfile( path + 'x3', 'f' ).reshape( n[::-1] ).T
s = z * 0.0005 * caxis[1]
hsurf = mlab.mesh( x, y, z, scalars=s, opacity=1.0 )

slm = hsurf.module_manager.scalar_lut_manager
slm.use_default_range = False
slm.data_range = caxis
slm.lut.table = sord.viz.colormap( 'w2' )
#slm.show_scalar_bar = True

scene = mlab.get_engine().scenes[0].scene
mlab.outline( extent=extent )
if 1:
    mlab.view( -45, 45, 600000, (350000, 150000, 0) )
elif 1:
    mlab.view( -45, 135, 600000, (350000, 150000, 0) )
else:
    mlab.view( 0, 0, 600000, (300000, 150000, 0) )
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
    v1 = sord.util.ndread( path + 'v1', n, [(), (), i] ).squeeze()
    v2 = sord.util.ndread( path + 'v2', n, [(), (), i] ).squeeze()
    v3 = sord.util.ndread( path + 'v3', n, [(), (), i] ).squeeze()
    v  = numpy.array( [v1, v2, v3] )
    if comp:
        v = v[comp]
    else:
        v = numpy.sqrt( (v*v).sum(0) )
    hsurf.mlab_source.set( z=z+exag*v, scalars=v )
    scene.render()

