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

# parameters
eventid = 14383980
bounds = (-72000.0, 40000.0), (-50000.0, 46000.0)
mts = os.path.join( 'run', 'data', '%s.mts.py' % eventid )
mts = cst.util.load( mts )
origin = mts.longitude, mts.latitude, mts.depth
proj = pyproj.Proj( proj='tmerc', lon_0=origin[0], lat_0=origin[1] )

# extent
x, y = bounds
x = x[0], x[1], x[1], x[0]
y = y[0], y[0], y[1], y[1]
x, y = np.array( proj( x, y, inverse=True ) )
extent = (x.min(), x.max()), (y.min(), y.max())

# setup plot
inches = 6.4, 6.4
plt.rc( 'font', size=8 )
plt.rc( 'axes', linewidth=0.5 )
plt.rc( 'lines', lw=1.5, solid_joinstyle='round', solid_capstyle='round' )
fig = plt.figure( None, inches, 100, None )
fig.clf()
ax = fig.add_axes( [0.01, 0.01, 0.98, 0.98] )

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
x = mts.longitude
y = mts.latitude
x, y = proj( x, y )
if 0:
    ax.plot( x, y, 'k*', ms=12, mew=1.0, mec='k', mfc='none' )
else:
    m = mts.double_couple_clvd
    m = m['mzz'], m['mxx'], m['myy'], m['mxz'], -m['myz'], -m['mxy']
    b = beachball.Beach( m, xy=(x,y), width=4000, linewidth=0.5, facecolor='k' )
    ax.add_collection( b )

# stations
sta = os.path.join( 'run', 'data', 'station-list.txt' )
sta = np.loadtxt( sta, 'S8, f, f, f' )
x, y = proj( sta['f2'], sta['f1'] )
ax.plot( x, y, 'k^', markersize=5 )
for s, y, x, z in sta:
    x, y = proj( x, y )
    ax.text( x, y-1800, s.split('.')[-1], ha='center', va='top' )

# finish up
axis = bounds[0] + bounds[1]
ax.set_xticks( [] )
ax.set_yticks( [] )
ax.axis( 'image' )
ax.axis( axis )
fig.canvas.draw()
fig.savefig( 'run/map.pdf' )
fig.show()

