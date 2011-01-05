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
bounds = (-80000.0, 48000.0), (-58000.0, 54000.0)
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
inches = 6.4, 5.6
plt.rc( 'font', size=8 )
plt.rc( 'axes', linewidth=0.5 )
plt.rc( 'lines', lw=0.5, solid_joinstyle='round', solid_capstyle='round' )
fig = plt.figure( None, inches, 100, None )
fig.clf()
ax = fig.add_axes( [0.01, 0.01, 0.98, 0.98] )

# source
x = mts.longitude
y = mts.latitude
x, y = proj( x, y )
if 0:
    ax.plot( x, y, 'k*', ms=12, mew=1.0, mec='k', mfc='none' )
else:
    m = mts.double_couple_clvd
    m = m['mzz'], m['mxx'], m['myy'], m['mxz'], -m['myz'], -m['mxy']
    b = beachball.Beach( m, xy=(x,y), width=5000, linewidth=0.5, facecolor='k' )
    ax.add_collection( b )
    p = []
    for c in b.get_paths():
        p += c.to_polygons() + [[[np.nan, np.nan]]]
    del p[-1]
    b = np.concatenate( p )
    f = os.path.join( 'run', 'data', 'beachball.txt' )
    np.savetxt( f, b )

# topography
ddeg = 0.5 / 60.0
z, extent = cst.data.topo( extent )
x, y = extent
n = z.shape
x = x[0] + ddeg * np.arange( n[0] )
y = y[0] + ddeg * np.arange( n[1] )
y, x = np.meshgrid( y, x )
v = 1000,
x, y = cst.plt.contour( x, y, z, v )[0]
f = os.path.join( 'run', 'data', 'mountains.txt' )
np.savetxt( f, np.array( [x, y] ).T )
x, y = proj( x, y )
ax.plot( x, y, '-k', linewidth=0.25 )

# coastlines and boarders
x, y = cst.data.mapdata( 'coastlines', 'high', extent, 10.0 )
x -= 360.0
f = os.path.join( 'run', 'data', 'coastlines.txt' )
np.savetxt( f, np.array( [x, y] ).T )
x, y = proj( x, y )
ax.plot( x, y, 'k-' )

# stations
sta = os.path.join( 'run', 'data', 'station-list.txt' )
sta = np.loadtxt( sta, 'S8, f, f, f' )
x, y = proj( sta['f2'], sta['f1'] )
print x.min(), x.max()
print y.min(), y.max()
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

# mesh
x, y = extent
x = x[0] + ddeg * np.arange( n[0] )
y = y[0] + ddeg * np.arange( n[1] )
yy, xx = np.meshgrid( y, x )
zz = np.empty_like( xx )
zz.fill( 1000.0 )

# CVM basins
for cvm, vv in [
    ('cvmh', cst.cvmh.extract( xx, yy, zz, 'vs' )),
    ('cvm', cst.cvm.extract( xx, yy, zz, 'vs', rundir='run/cvm' )),
]:

    # contour
    v = 2500,
    x, y = cst.plt.contour( xx, yy, vv, v )[0]
    f = os.path.join( 'run', 'data', 'basins-%s.txt' % cvm )
    np.savetxt( f, np.array( [x, y] ).T )
    x, y = proj( x, y )
    h = ax.plot( x, y, '--k', linewidth=0.25 )
    h[0].set_dashes((2,1))

    # save figure
    fig.canvas.draw()
    f = os.path.join( 'run', 'plot' )
    if not os.path.exists( f ):
        os.makedirs( f )
    f = os.path.join( 'run', 'plot', 'map-%s.pdf' % cvm )
    fig.savefig( f, transparent=True )
    fig.show()
    h[0].remove()

