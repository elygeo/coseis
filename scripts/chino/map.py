#!/usr/bin/env python
"""
Map plot
"""
import os
import numpy as np
import matplotlib.pyplot as plt
import pyproj
import cst

# parameters
eventid = 14383980
bounds = (-80000.0, 48000.0), (-58000.0, 54000.0)
mts = os.path.join( 'run', 'data', '%s.mts.py' % eventid )
mts = cst.util.load( mts )
origin = mts.longitude, mts.latitude, mts.depth
proj = pyproj.Proj( proj='tmerc', lon_0=origin[0], lat_0=origin[1] )

# setup plot
inches = 6.4, 5.6
plt.rc( 'font', size=8 )
plt.rc( 'axes', linewidth=0.5 )
plt.rc( 'lines', lw=0.5, solid_joinstyle='round', solid_capstyle='round' )
plt.rc( 'patch', lw=0.5 )
fig = plt.figure( None, inches, 100, None )
fig.clf()
ax = fig.add_axes( [0.01, 0.01, 0.98, 0.98] )

# source
f = os.path.join( 'run', 'data', 'beachball.txt' )
x, y = np.loadtxt( f ).T
i = np.isnan( x ).nonzero()[0]
ax.fill( x[:i[0]-1], y[:i[0]-1], 'w' )
ax.fill( x[i[0]+1:i[1]-1], y[i[0]+1:i[1]-1], 'k' )
ax.fill( x[i[1]+1:], y[i[1]+1:], 'k' )

# topography
f = os.path.join( 'run', 'data', 'mountains.txt' )
x, y = proj( *np.loadtxt( f ).T )
ax.plot( x, y, '-k', linewidth=0.25 )

# coastlines and boarders
f = os.path.join( 'run', 'data', 'coastlines.txt' )
x, y = proj( *np.loadtxt( f ).T )
ax.plot( x, y, 'k-' )

# stations
sta = os.path.join( 'run', 'data', 'station-list.txt' )
sta = np.loadtxt( sta, 'S8, f, f, f' )
x, y = proj( sta['f2'], sta['f1'] )
ax.plot( x, y, 'k^', markersize=5 )
for s, y, x, z in sta:
    x, y = proj( x, y )
    ax.text( x, y-1300, s.split('.')[-1], ha='center', va='top' )

# axes
axis = bounds[0] + bounds[1]
ax.axis( 'image' )
ax.axis( axis )
ax.set_xticks( [] )
ax.set_yticks( [] )

# legend
x, y = bounds
x = x[1] - 50000.0, x[1] - 30000.0
y = y[1] - 3000.0, y[1] - 3000.0
cst.plt.lengthscale( ax, x, y, label='20 km', backgroundcolor='w' )
x, y = bounds
x = x[1] - 20000.0
y = y[1] - 6000.0
cst.plt.compass_rose( ax, x, y, 2000.0 )

# CVM basins
f = os.path.join( 'run', 'data', 'basins-cvm.txt' )
x, y = proj( *np.loadtxt( f ).T )
h = ax.plot( x, y, '-r', linewidth=0.25 )
h[0].set_dashes((2,1))

# CVM-H basins
f = os.path.join( 'run', 'data', 'basins-cvmh.txt' )
x, y = proj( *np.loadtxt( f ).T )
h = ax.plot( x, y, '-b', linewidth=0.25 )
h[0].set_dashes((2,1))

# save figure
fig.canvas.draw()
f = os.path.join( 'run', 'plot' )
if not os.path.exists( f ):
    os.makedirs( f )
f = os.path.join( 'run', 'plot', 'map.pdf' )
fig.savefig( f, transparent=True )
fig.show()

