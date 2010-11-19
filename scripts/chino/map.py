#!/usr/bin/env python
"""
Map plot
"""
import os
import numpy as np
import matplotlib.pyplot as plt
import pyproj
from obspy.imaging import beachball
import cst

path = os.path.join( 'run', 'mesh', '1000' )
meta = os.path.join( path, 'meta.py' )
meta = cst.util.load( meta )
proj = pyproj.Proj( **meta.projection )
extent = meta.extent
bounds = meta.bounds

#extent = (-118.75, -117.25), (33.5, 34.4)

# setup plot
inches = 6.4, 3.7
lat = np.mean( extent[1] )
aspect = 1.0 / np.cos( lat / 180.0 * np.pi )
plt.rc( 'font', size=8 )
plt.rc( 'axes', linewidth=0.5 )
plt.rc( 'lines', lw=1.5, solid_joinstyle='round', solid_capstyle='round' )
fig = plt.figure( None, inches, 100, None )
fig.clf()
ax = fig.add_axes( [0.01, 0.02, 0.98, 0.96] )

# topography
ddeg = 0.5 / 60.0
z, extent = cst.data.topo( extent )
x, y = extent
n = z.shape
x = x[0] + ddeg * np.arange( n[0] )
y = y[0] + ddeg * np.arange( n[1] )
y, x = np.meshgrid( y, x )
x, y = proj( x, y )
v = 250, 1000
v = 1000,
ax.contour( x, y, z, v, colors='k', linewidths=0.25 )

# coastlines and boarders
x, y = cst.data.mapdata( 'coastlines', 'high', extent, 10.0 )
x, y = proj( x, y )
ax.plot( x-360.0, y, 'k-', lw=0.5 )

# source
mts = 'scsn-mts-14383980.py'
mts = cst.util.load( mts )
x = mts.longitude
y = mts.latitude
x, y = proj( x, y )
if 0:
    ax.plot( x, y, 'k*', ms=12, mew=1.0, mec='k', mfc='none' )
else:
    m = mts.double_couple_clvd
    m = m['mzz'], m['mxx'], m['myy'], m['mxz'], -m['myz'], -m['mxy']
    b = beachball.Beach( m, xy=(x,y), width=8000, linewidth=0.5, facecolor='k' )
    ax.add_collection( b )

# stations
sta = np.loadtxt( 'station-list.txt', 'S8, f, f, f' )
x, y = proj( sta['f2'], sta['f1'] )
ax.plot( x, y, 'k^', markersize=5 )
for s, y, x, z in sta:
    x, y = proj( x, y )
    ax.text( x, y-1800, s.split('.')[-1], ha='center', va='top' )

# finish up
axis = bounds[0] + bounds[1]
#ax.set_aspect( aspect )
ax.set_xticks( [] )
ax.set_yticks( [] )
ax.axis( 'image' )
ax.axis( axis )
fig.canvas.draw()
fig.savefig( 'map.pdf' )
fig.show()

