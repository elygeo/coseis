#!/usr/bin/env python
import os
import numpy as np
from enthought.mayavi import mlab
import cst
import mesh

path = os.path.join( 'run', mesh.version ) + os.sep
pixels = 640, 360

# setup figure
size = pixels[0], pixels[1] + 48
fig = mlab.figure( None, size=size, bgcolor=(1,1,1), fgcolor=(0,0,0) )
mlab.clf()
fig.scene.disable_render = True
fig.scene.set_size( pixels )

# read configuration
cfg = cst.util.load( path + 'conf.py' )
dtype = cfg.dtype
proj = mesh.proj

# create mesh and read velocity file
xx, yy = mesh.proj( mesh.xx, mesh.yy )
zz = -3.0 * mesh.zz
ss = np.fromfile( path + 'vp', dtype ).reshape( zz.shape )
if mesh.transpose:
    xx, yy, zz, ss = xx.T, yy.T, zz.T, ss.T

# plot segments
i = 0
for n in mesh.nn:
    x = xx[i:i+n]
    y = yy[i:i+n]
    z = zz[i:i+n]
    s = ss[i:i+n]
    h = mlab.mesh( x, y, z, scalars=s, vmin=1500, vmax=6500 )
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
f = path + mesh.version + '-fence.png'
print f
mlab.savefig( f, magnification=1 )
mlab.show()

