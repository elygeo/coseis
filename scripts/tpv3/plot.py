#!/usr/bin/env python
import os
import numpy as np
import matplotlib.pyplot as plt
import sord

bi_dir = 'bi/'
so_dir = os.path.expanduser( '~/run/tpv3-150/' )
meta = sord.util.loadmeta( so_dir )
dt = meta.dt
nt = meta.nt

# Time histories
t1 = dt * np.arange( nt )
t2 = np.fromfile( bi_dir + 'time', 'f' )
for i, sta in enumerate( ('P1', 'P2') ):
    fig = plt.figure(i+1)
    fig.clf()

    ax = fig.add_subplot( 2, 1, 1 )
    f1 = 1e-6 * np.fromfile( so_dir + 'out/' + sta + '-ts1', 'f' )
    f2 = np.fromfile( bi_dir + sta + '-ts', 'f' )
    ax.plot( t1, f1, 'k-', t2, f2, 'k--' )
    ax.axis([ 1., 11., 60., 85. ])
    ax.set_title( sta, position=(0.05,0.83), ha='left', va='center' )
    ax.set_xticklabels( [] )
    ax.set_ylabel( 'Shear stress (MPa)' )
    #leg = fig.legend( ('SOM', 'BI'), loc=(.78, .6) )

    ax = fig.add_subplot( 2, 1, 2 )
    f1 = np.fromfile( so_dir + 'out/' + sta + '-sv1', 'f' )
    f2 = np.fromfile( bi_dir + sta + '-sv', 'f' )
    ax.plot( t1, f1, 'k-', t2, f2, 'k--' )
    ax.set_yticks( [0, 1, 2, 3] )
    ax.set_ylabel( 'Slip rate (m/s)' )

    ax.twinx()
    f1 = np.fromfile( so_dir + 'out/' + sta + '-su1', 'f' )
    f2 = np.fromfile( bi_dir + sta + '-su', 'f' )
    ax.plot( t1, f1, 'k-', t2, f2, 'k--' )
    ax.axis([ 1., 11., -0.5, 3.5 ])
    ax.set_yticks( [0, 1, 2, 3] )
    ax.set_ylabel( 'Slip (m)' )
    ax.set_xlabel( 'Time (s)' )
    ax.set_title( sta, position=(0.05,0.83), ha='left', va='center' )
    fig.canvas.draw()

# Rupture time contour
v = 0.5 * np.arange( -20, 20 )
n = meta.shape['trup']
x1 = 0.001 * np.fromfile( so_dir + 'out/x1', 'f' ).reshape( n[::-1] ).T
x2 = 0.001 * np.fromfile( so_dir + 'out/x2', 'f' ).reshape( n[::-1] ).T
f = np.fromfile( so_dir + 'out/trup', 'f' ).reshape( n[::-1] ).T
fig = plt.figure( 3 )
fig.clf()
ax = fig.add_subplot(111)
ax.contour( x1, x2, f, v, colors='k' )
ax.hold( True )
n = 300, 150
dx = 0.1
x1 = dx * np.arange( n[0] )
x2 = dx * np.arange( n[1] )
x1 = x1 - 0.5 * x1[-1]
x2 = x2 - 0.5 * x2[-1]
x2, x1 = np.meshgrid( x2, x1 )
trup = np.fromfile( bi_dir + 'trup', 'f' ).reshape( n[::-1] ).T
ax.contour( x1, x2, -trup, v, colors='k' )
ax.axis( 'image' )
ax.axis( (-15, 15, -7.5, 7.5) )
#ax.axis( (-15, 0, -7.5, 0) )
fig.canvas.draw()
fig.show()

