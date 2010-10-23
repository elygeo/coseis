#!/usr/bin/env python
"""
Visualization using Mayavi and Matplotlib
"""
import os
import pyproj, Image
import numpy as np
import matplotlib.pyplot as plt
from enthought.mayavi import mlab
import cst

# parameters
format = 'png'; dpi = 150.0
format = 'pdf'; dpi = 300.0
draft = False
draft = True
field = 'z25'
path = 'data' + os.sep
proj = pyproj.Proj( proj='tmerc', lon_0=-117.25, lat_0=33.75, k=0.001 )
title = 'SCEC Community\nVelocity Model'
legend = 'Depth to Vs = 2.5 km/s'
ticklabels = '0', '4', '8 km'
ticks = 0, 4, 8
colormap = [
    (0, 0.001, 2, 3), # value
    (1, 1, 1, 1), # red
    (0, 0, 1, 1), # green
    (0, 0, 0, 1), # blue
    (0, 1, 1, 1), # alpha
]
colorexp = 1.0
colorlim = ticks[0], ticks[-1]
inches = 6.4, 3.6
extent = (-121.1, -113.8), (32.1, 35.5)
ylim = 150.0
xlim = ylim * inches[0] / inches[1]
axis = -xlim, xlim, -ylim, ylim
pixels = int( dpi * inches[0] ), int( dpi * inches[1] )
point = dpi / 72.0
ppi = 100
meta = cst.util.load( path + 'meta.py' )
shape = meta.shape



# Matplotlib section
plt.rc( 'lines',
    solid_joinstyle='round',
    solid_capstyle='round',
    dash_joinstyle='round',
    dash_capstyle='round',
)
plt.close( 0 )
fig0 = plt.figure( 0, inches, dpi=ppi )
ax = fig0.add_axes( [0, 0, 1, 1], axisbg='k', xticks=[], yticks=[] )
for spine in ax.spines.itervalues():
    spine.set_color( 'none' )
ax.axis( 'scaled' )
ax.axis( axis )

# basemap
for kind in 'coastlines', 'borders':
    x, y = cst.data.mapdata( kind, 'high', extent, 10.0 )
    x, y = proj( x, y )
    ax.plot( x, y, 'k-', lw=0.5 )

# cities
sites = [
    -119.69722, 34.42083, 'baseline', 'center', 'Santa Barbara',
    -119.17611, 34.19750, 'baseline', 'center', 'Oxnard',
    -119.01778, 35.37333, 'top',      'center', 'Bakersfield',
    -118.24278, 34.05222, 'baseline', 'center', 'Los Angeles',
    -118.13583, 34.69806, 'baseline', 'center', 'Lancaster',
    -117.91361, 33.83528, 'top',      'center', 'Anaheim',
    -117.37861, 33.19583, 'baseline', 'center', 'Oceanside',
    -117.29028, 34.53612, 'baseline', 'center', 'Victorville',
    -117.28889, 34.10833, 'baseline', 'center', 'San Bernardino',
    -117.15639, 32.71528, 'baseline', 'center', 'San Diego',
    -117.02194, 34.89861, 'baseline', 'center', 'Barstow',
    -116.54444, 33.83028, 'baseline', 'center', 'Palm Springs',
    -115.46730, 32.65498, 'baseline', 'center', 'Mexicali',
]
x, y = proj( sites[0::5], sites[1::5] )
ax.plot( x, y, 'o', ms=2.3, mfc='w', mec='k', mew=1.5, alpha=0.4 )
ax.plot( x, y, 'o', ms=2.3, mfc='w', mec='k', mew=0, alpha=1.0 )
va = sites[2::5]
ha = sites[3::5]
s  = sites[4::5]
dy = {'top': -5, 'baseline': 5}
for i in range( len( s ) ):
    cst.plt.text( ax, x[i], y[i]+dy[va[i]], s[i], ha=ha[i], va=va[i], size=7,
        weight='bold', color='w', edgecolor='k' )

# legend
w = 50.0 / (axis[1] - axis[0])
rect = 0.142 - w, 0.08, 2 * w, 0.02
cmap = cst.plt.colormap( colormap, colorexp )
cst.plt.colorbar( fig0, cmap, colorlim, legend, rect, ticks, ticklabels, size=7,
     weight='bold', color='w', edgecolor='k' )
leg = fig0.add_axes( [0, 0, 1, 1] )
leg.set_axis_off()
cst.plt.text( leg, 0.87, 0.95, title, ha='center', va='top', size=10,
     weight='bold', color='w', edgecolor='k' )

# create overlay
if format == 'pdf':
    over = cst.plt.savefig( fig0, format='pdf', transparent=True, distill=False )
else:
    aa = 3
    mask = cst.plt.savefig( fig0, dpi=aa*dpi, transparent=True )
    over = cst.plt.savefig( fig0, dpi=aa*dpi, background='k' )
    over[:,:,3] = mask[:,:,3]
    over = Image.fromarray( over, 'RGBA' )
    over = over.resize( pixels, Image.ANTIALIAS )
plt.close( 0 )



# Mayavi section
x, y = inches
size = int( ppi * x + 2 ), int( ppi * y + 48 )
#mlab.options.offscreen = True
fig = mlab.figure( 'Viz', size=size )
#fig.scene.off_screen_rendering = True
fig.scene.disable_render = True
fig.scene.set_size( pixels )
fig.scene.render_window.aa_frames = 8
mlab.clf()

# topography
cmap = [
    (-5, -3, -2, -1,  1,  2,  3,  5), # value
    ( 0,  0, 10, 10, 15, 15, 25, 25), # red
    (10, 10, 20, 20, 25, 30, 25, 25), # green
    (38, 38, 40, 40, 25, 20, 17, 17), # blue
    (80, 80, 80, 80, 80, 80, 80, 80), # alpha
]
ddeg = 0.5 / 60.0
z, extent = cst.data.topo( extent, scale=0.001 )
x, y = extent
n = z.shape
if draft:
    x = x[0] + ddeg * np.arange( n[0] )
    y = y[0] + ddeg * np.arange( n[1] )
else:
    x = x[0] + 0.5 * ddeg * np.arange( n[0] * 2 - 1 )
    y = y[0] + 0.5 * ddeg * np.arange( n[1] * 2 - 1 )
    z = cst.data.upsample( z )
y, x = np.meshgrid( y, x )
s = np.maximum( 0.01, z )
i = (x + y) < -84.0
s[i] = z[i]
x, y = proj( x, y )
cmap = cst.mlab.colormap( cmap, 2.5 )
surf = mlab.mesh( x, y, z, scalars=s, vmin=-4, vmax=4, figure=fig )
surf.module_manager.scalar_lut_manager.lut.table = cmap
surf.actor.property.ambient = 0.0
surf.actor.property.diffuse = 1.0
surf.actor.property.specular = 0.6
surf.actor.property.specular_power = 10
surf.parent.parent.filter.splitting = False

# lighting
fig.scene.light_manager.lights[0].azimuth = 30
fig.scene.light_manager.lights[0].elevation = 30
fig.scene.light_manager.lights[0].intensity = 1.0
fig.scene.light_manager.lights[0].activate = True
fig.scene.light_manager.lights[1].activate = False
fig.scene.light_manager.lights[2].activate = False

# surface plot
n = shape[:2]
x = np.fromfile( path + 'lon.bin', 'f' ).reshape( n[::-1] ).T
y = np.fromfile( path + 'lat.bin', 'f' ).reshape( n[::-1] ).T
z = np.fromfile( path + field + '.bin', 'f' ).reshape( n[::-1] ).T * 0.001
x, y = proj( x, y )
if draft:
    x = x[::2]
    y = y[::2]
    z = z[::2]
cmap = cst.mlab.colormap( colormap, colorexp )
surf = mlab.mesh( x, y, 10 - z, scalars=z, figure=fig )
surf.module_manager.scalar_lut_manager.lut.table = cmap
surf.module_manager.scalar_lut_manager.use_default_range = False
surf.module_manager.scalar_lut_manager.data_range = colorlim
surf.actor.property.ambient = 0.0
surf.actor.property.diffuse = 0.5
surf.actor.property.specular = 0.3
surf.actor.property.specular_power = 15
surf.parent.parent.filter.splitting = False
surf = surf.mlab_source

# camera
mlab.view( 0, 0, 600, (0,0,0), figure=fig )
fig.scene.parallel_projection = True
fig.scene.camera.parallel_scale = axis[3]

# combine overlay and save image
f = field + '.' + format
print f
out = cst.mlab.screenshot( fig )
if format == 'pdf':
    out = cst.viz.img2pdf( out, dpi=dpi )
    out = cst.viz.pdf_merge( (out, over) )
    open( f, 'wb' ).write( out.getvalue() )
else:
    out = Image.fromarray( out, 'RGB' )
    out.paste( over, mask=over )
    out.save( f )

fig.scene.disable_render = False

