#!/usr/bin/env python
import os
import numpy as np
import matplotlib.pyplot as plt
import cst

# parameters
depth = 500.0
vmin, vmax = 300, 3200
delta = 0.5 / 60.0
lon, lat = (-120.0, -114.5), (32.5, 35.0)
cmap = cst.plt.colormap( 'rgb' )
path = 'run' + os.sep

# create mesh
x = np.arange( lon[0], lon[1] + delta/2, delta )
y = np.arange( lat[0], lat[1] + delta/2, delta )
x, y = np.meshgrid( x, y )
z = np.empty_like( x )
z.fill( depth )

# CVM extractions
vsh = cst.cvmh.extract( 'vs', x, y, z )
vs4 = cst.cvm.extract( x, y, z, rundir=path )[2]

# map data
x, y = cst.data.mapdata( 'coastlines', 'high', (lon, lat), 100.0 )

# plot
for vs, tag in (vs4, '4'), (vsh, 'H'):
    fig = plt.figure( figsize=(6.4, 4.8) )
    ax = plt.gca()
    im = ax.imshow( vs, extent=lon+lat, cmap=cmap, vmin=vmin, vmax=vmax,
        origin='lower', interpolation='nearest' )
    fig.colorbar( im, orientation='horizontal' ).set_label( 'S-wave velocity (m/s)' )
    ax.plot( x-360.0, y, 'k-' )
    ax.set_aspect( 1.0 / np.cos( 33.75 / 180.0 * np.pi ) )
    ax.set_title( 'CVM-%s %.0f m depth' % (tag, depth) )
    ax.axis( lon+lat )
    f = path + 'cvm%s-vs%.0f.png' % (tag.lower(), depth)
    print f
    fig.savefig( f )

