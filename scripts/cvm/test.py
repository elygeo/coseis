#!/usr/bin/env python
import os
import numpy as np
import matplotlib.pyplot as plt
import cst

# parameters
model = 'cvm4'
model = 'cvmh'
depth = 2000.0; vmin, vmax = 300, 3000
depth = 0.0; vmin, vmax = 200, 2000
delta = 0.5 / 60.0
lon, lat = (-120.0, -114.5), (32.5, 35.0)
path = 'run' + os.sep

# create mesh
x = np.arange( lon[0], lon[1] + delta/2, delta )
y = np.arange( lat[0], lat[1] + delta/2, delta )
x, y = np.meshgrid( x, y )
z = np.empty_like( x )
z.fill( depth )

# CVM extraction
if model == 'cvmh':
    vs = cst.cvmh.extract( 'vs', x, y, z, vs30='wald' )
else:
    vs = cst.cvm.extract( x, y, z, rundir=path )[2]

# plot
fig = plt.figure( figsize=(6.4, 4.8) )
ax = plt.gca()
im = ax.imshow( vs, extent=lon+lat, origin='lower', interpolation='nearest', vmin=vmin, vmax=vmax )
fig.colorbar( im, orientation='horizontal' ).set_label( 'S-wave velocity (m/s)' )
x, y = cst.data.mapdata( 'coastlines', 'high', (lon, lat), 100.0 )
ax.plot( x-360.0, y, 'k-' )
ax.set_aspect( 1.0 / np.cos( 33.75 / 180.0 * np.pi ) )
ax.axis( lon+lat )
f = path + '%s-vs%.0f.png' % (model, depth)
print f
fig.savefig( f )

