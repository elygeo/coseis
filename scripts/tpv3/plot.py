#!/usr/bin/env python
import os, sord
import numpy as np
import matplotlib.pyplot as plt

# parameters
bipath = 'bi/'
path = 'run/150/'
path = 'run/tpv3-150/'
path = 'run/tpv3-300/'
stations = 'P1a', 'P2a'
stations = 'P1', 'P2'
meta = sord.util.load( path + 'meta.py' )
dx = meta.dx
dt = meta.dt
nt = meta.nt
ihypo = meta.ihypo
dtype = meta.dtype

# Time histories
t1 = np.arange( nt ) * dt
t2 = np.fromfile( bipath + 'time', '<f4' )
for i, sta in enumerate( stations ):
    fig = plt.figure(i+1)
    fig.clf()

    ax = fig.add_subplot( 2, 1, 1 )
    f1 = np.fromfile( path + 'out/' + sta + '-ts1', dtype ) * 1e-6
    f2 = np.fromfile( bipath + sta[:2] + '-ts', '<f4' )
    ax.plot( t1, f1, 'k-', t2, f2, 'k--' )
    ax.axis( [1, 11, 60, 85] )
    ax.set_title( sta, position=(0.05, 0.83), ha='left', va='center' )
    ax.set_xticklabels( [] )
    ax.set_ylabel( 'Shear stress (MPa)' )
    #leg = fig.legend( ('SOM', 'BI'), loc=(0.78, 0.6) )

    ax = fig.add_subplot( 2, 1, 2 )
    f1 = np.fromfile( path + 'out/' + sta + '-sv1', dtype )
    f2 = np.fromfile( bipath + sta[:2] + '-sv', '<f4' )
    ax.plot( t1, f1, 'k-', t2, f2, 'k--' )
    ax.set_yticks( [0, 1, 2, 3] )
    ax.set_ylabel( 'Slip rate (m/s)' )

    ax.twinx()
    f1 = np.fromfile( path + 'out/' + sta + '-su1', dtype )
    f2 = np.fromfile( bipath + sta[:2] + '-su', '<f4' )
    ax.plot( t1, f1, 'k-', t2, f2, 'k--' )
    ax.axis( [1, 11, -0.5, 3.5] )
    ax.set_yticks( [0, 1, 2, 3] )
    ax.set_ylabel( 'Slip (m)' )
    ax.set_xlabel( 'Time (s)' )
    ax.set_title( sta, position=(0.05, 0.83), ha='left', va='center' )
    fig.canvas.draw()
    f = path + sta + '.pdf'
    print f
    fig.savefig( f )

# Rupture time contour
fig = plt.figure( 3 )
fig.clf()
ax = fig.add_subplot( 111 )
v = np.arange( -20, 20 ) * 0.5
n = meta.shape['trup']
x = np.fromfile( path + 'out/x1', dtype ).reshape( n[::-1] ).T
y = np.fromfile( path + 'out/x2', dtype ).reshape( n[::-1] ).T
t = np.fromfile( path + 'out/trup', dtype ).reshape( n[::-1] ).T
if not hasattr( meta, 'fixhypo' ):
    x = x - dx[0] * (ihypo[0] - 1)
    y = y - dx[1] * (ihypo[1] - 1)
x *= 0.001
y *= 0.001
ax.contour( x, y, t, v, colors='k' )
#ax.hold( True )
n = 300, 150
dx = 0.1
x = dx * np.arange( n[0] )
y = dx * np.arange( n[1] )
x -= 0.5 * x[-1]
y -= 0.5 * y[-1]
y, x = np.meshgrid( y, x )
t = np.fromfile( bipath + 'trup', '<f4' ).reshape( n[::-1] ).T
ax.contour( x, y, -t, v, colors='k' )
ax.axis( 'image' )
#ax.axis( [-15, 0, -7.5, 0] )
fig.canvas.draw()
f = path + 'trup.pdf'
print f
fig.savefig( f )
fig.show()

