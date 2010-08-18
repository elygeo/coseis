#!/usr/bin/env python
"""
Reproduce Magistrale (2000) Fig. 10 fence diagram.
"""
import pyproj
import numpy as np
from enthought.mayavi import mlab
import cst

# parameters
model = 'cvmh'
model = 'cvm4'
prop, vmin, vmax = 'vs', 500, 4000
prop, vmin, vmax = 'vp', 1600, 6400
dx = 200.0; dz = 50.0; nz = 201
dx = 400.0; dz = 100.0; nz = 101
nproc = 2
transpose = False

# projection
projection = dict( proj='aeqd', lon_0=-118.25, lat_0=34.1 )
proj = pyproj.Proj( **projection )

# segment boundaries
ll = [
    ( -119.292, 34.431 ),
    ( -118.966, 34.098 ),
    ( -119.133, 34.274 ),
    ( -118.684, 34.406 ),
    ( -118.684, 34.406 ),
    ( -118.460, 34.338 ),
    ( -118.460, 34.338 ),
    ( -118.153, 33.867 ),
    ( -118.215, 33.973 ),
    ( -117.933, 34.210 ),
    ( -118.344, 33.758 ),
    ( -117.940, 33.980 ),
    ( -117.940, 33.980 ),
    ( -117.187, 34.137 ),
]

# sample segments
xx = []
yy = []
nn = []
for i in range( 0, len( ll ), 2 ):
    x = ll[i][0], ll[i+1][0]
    y = ll[i][1], ll[i+1][1]
    x, y = proj( x, y )
    dr = np.sqrt( np.diff( x ) ** 2 + np.diff( y ) ** 2 )
    r  = np.r_[ 0.0, np.cumsum( dr ) ]
    n  = int( r[-1] / dx + 1.5 )
    ri = np.linspace( 0.0, r[-1], n )
    x  = np.interp( ri, r, x )
    y  = np.interp( ri, r, y )
    nn += [n]
    xx += [x]
    yy += [y]

# project lon/lat to meters
xx = np.concatenate( xx )
yy = np.concatenate( yy )
xx, yy = proj( xx, yy, inverse=True )

# creat 2D mesh
z = dz * np.arange( nz )
zz, xx = np.meshgrid( z, xx )
zz, yy = np.meshgrid( z, yy )

# cvm extraction
if transpose:
    xx, yy, zz = xx.T, yy.T, zz.T
if model == 'cvmh':
    ss = cst.cvmh.extract( xx, yy, zz, prop )
else:
    ss = cst.cvm.extract( xx, yy, zz, prop )
if transpose:
    xx, yy, zz, ss = xx.T, yy.T, zz.T, ss.T
xx, yy = proj( xx, yy )
zz *= -3.0

# setup figure
pixels = 640, 360
size = pixels[0], pixels[1] + 48
fig = mlab.figure( None, size=size, bgcolor=(1,1,1), fgcolor=(0,0,0) )
mlab.clf()
fig.scene.disable_render = True
fig.scene.set_size( pixels )

# plot segments
i = 0
for n in nn:
    x = xx[i:i+n]
    y = yy[i:i+n]
    z = zz[i:i+n]
    s = ss[i:i+n]
    h = mlab.mesh( x, y, z, scalars=s, vmin=vmin, vmax=vmax )
    lut = cst.mlab.colormap( 'bgr' )[::-1]
    h.module_manager.scalar_lut_manager.lut.table = lut
    i += n
    if 1:
        x = np.concatenate( [x[:,0], x[::-1,-1], x[:1,0]] )
        y = np.concatenate( [y[:,0], y[::-1,-1], y[:1,0]] )
        z = np.concatenate( [z[:,0], z[::-1,-1], z[:1,0]] )
        mlab.plot3d( x, y, z, line_width=0.5, tube_radius=None )

# plot coastline
extent = (-120.0, -117.0), (33.0, 35.0)
x, y = cst.data.mapdata( 'coastlines', 'high', extent, 10.0 )
x, y = proj( x, y )
z = np.zeros_like( x )
mlab.plot3d( x, y, z, color=(0,0,0), line_width=0.5, tube_radius=None )

# orient camera and save figure
mlab.view( -90, 45, 2e6, (0, 0, -2e4) )
fig.scene.camera.view_angle = 3.3
fig.scene.light_manager.lights[3].activate = True
fig.scene.disable_render = False
f = '%s-%s-fence.png' % (model, prop)
print f
mlab.savefig( f, magnification=1 )

