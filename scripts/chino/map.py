#!/usr/bin/env python
"""
Map plot
"""
import numpy as np
import matplotlib.pyplot as plt
from obspy.imaging import beachball
import cst

extent = (-118.75, -117.25), (33.5, 34.4)

# setup plot
inches = 6.4, 5.0
lat = np.mean( extent[1] )
aspect = 1.0 / np.cos( lat / 180.0 * np.pi )
plt.rc( 'font', size=8 )
plt.rc( 'axes', linewidth=0.5 )
plt.rc( 'lines', lw=1.5, solid_joinstyle='round', solid_capstyle='round' )
fig = plt.figure( None, inches, 100, None )
fig.clf()
ax = fig.add_axes( [0.075, 0.075, 0.85, 0.85] )

# coastlines and boarders
#x, y = cst.data.mapdata( 'coastlines', 'high', extent, 10.0 )
#ax.plot( x-360.0, y, 'k-', lw=0.5 )

# stations
sta = np.loadtxt( 'station-list.txt', 'S8, f, f, f' )
x, y = sta['f2'], sta['f1']
ax.plot( x, y, 'k^', markersize=5 )
for s, y, x, z in sta:
    ax.text( x, y-0.015, s.split('.')[-1], ha='center', va='top' )

# source
mts = 'scsn-mts-14383980.py'
mts = cst.util.load( mts )
x = mts.longitude
y = mts.latitude
ax.plot( x, y, 'k*', ms=12, mew=1.0, mec='k', mfc='none' )
m = mts.double_couple_clvd
m = m['mzz'], m['mxx'], m['myy'], m['mxz'], -m['myz'], -m['mxy']
b = beachball.Beach( m, xy=(x,y), width=0.05, linewidth=0.5, facecolor='k' )
ax.add_collection( b )

# finish up
axis = extent[0] + extent[1]
ax.set_aspect( aspect )
ax.axis( axis )
fig.canvas.draw()
fig.savefig( 'map.pdf' )
fig.show()

