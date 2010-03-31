#!/usr/bin/env python
import numpy as np
import matplotlib
import matplotlib.pyplot as plt

def mesh( x, y, u, v, xx, yy ):
    yy, xx = np.meshgrid( yy, xx )
    fig = plt.figure( None, (8, 2), 100, 'w' )
    fig.clf()
    ax = fig.add_axes( [0.01, 0.04, 0.49, 0.92] )
    ax.plot( xx, yy, '-', c=(0.7, 0.7, 0.7) )
    ax.hold( True )
    ax.plot( xx.T, yy.T, '-o', c='0.7', mec='w' )
    ax.plot( [0, 0], [-6,6], 'k--', lw=1.5 )
    ax.plot( x, y, 'ko' )
    ax.quiver( x, y, u, v, units='x', scale=1, zorder=3 )
    ax.axis( 'image' )
    ax.axis( [-12, 12, -6, 6] )
    ax.set_xticks([])
    ax.set_yticks([])
    return ax

def beachball( fig, x, y ):
    ax = fig.add_axes( [0.55, 0.04, 0.23, 0.92] )
    c = matplotlib.patches.Circle( (0, 0), 4, lw=1.5, facecolor='none' )
    ax.add_patch( c )
    ax.fill( x, y, '0.7', lw=0, zorder=0 )[0].set_clip_path( c )
    ax.plot( [0, 0], [-6, 6], 'k--', lw=1.5 )
    ax.axis( 'image' )
    ax.axis( [-6, 6, -6, 6] )
    ax.axis( 'off' )
    return

xx = -12, -8, -4,  0,  4,  8, 12
yy = -8, -4,  0,  4, 8

x = -8, -4,  0
y =  0,  0,  0
u = -2, -2,  1
v = -4, -2, -3
ax = mesh( x, y, u, v, xx, yy )
ax.figure.savefig( 'bc0.png', dpi=60 )

x = -8, -4,  0
y =  0,  0,  0
u = -2, -2,  0
v = -4, -2,  0
ax = mesh( x, y, u, v, xx, yy )
ax.figure.savefig( 'bc3.png', dpi=60 )

x = -8, -4,  0,  4,  8
y =  0,  0,  0,  0,  0
u = -2, -2,  0,  2,  2
v = -4, -2, -2, -2, -4
ax = mesh( x, y, u, v, xx, yy )
x = -4,  4, 4, -4
y = -4, -4, 0,  0
beachball( ax.figure, x, y )
ax.figure.savefig( 'bc1.png', dpi=60 )

x = -8, -4,  0,  4,  8
y =  0,  0,  0,  0,  0
u = -2, -2, -2, -2, -2
v = -4, -2,  0,  2,  4
ax = mesh( x, y, u, v, xx, yy )
x = -4,  0, 0, 4, 4, -4
y = -4, -4, 4, 4, 0,  0
beachball( ax.figure, x, y )
ax.plot( [-6, 6], [0, 0], 'k--', lw=1.5 )
ax.figure.savefig( 'bc-1.png', dpi=60 )

xx = -14, -10, -6, -2, 2, 6, 10, 14

x = -6, -2,  2,  6
y =  0,  0,  0,  0
u = -2, -2,  2,  2
v = -4, -2, -2, -4
ax = mesh( x, y, u, v, xx, yy )
x = -4,  4, 4, -4
y = -4, -4, 0,  0
beachball( ax.figure, x, y )
ax.figure.savefig( 'bc2.png', dpi=60 )

x = -6, -2,  2,  6
y =  0,  0,  0,  0
u = -2, -2, -2, -2
v = -4, -2,  2,  4
ax = mesh( x, y, u, v, xx, yy )
x = -4,  0, 0, 4, 4, -4
y = -4, -4, 4, 4, 0,  0
beachball( ax.figure, x, y )
ax.plot( [-6, 6], [0, 0], 'k--', lw=1.5 )
ax = ax.figure.add_axes( [0.75, 0.04, 0.23, 0.92] )
x = -1, 1
y =  2, -2
u =  0, 0
v = -4, 4
ax.quiver( x, y, u, v, units='x', scale=1, zorder=3, lw=1.5 )
ax.hold( True )
ax.plot( [0, 0], [-6, 6], 'k--', lw=1.5 )
ax.axis( 'image' )
ax.axis( [-6, 6, -6, 6] )
ax.axis( 'off' )
ax.figure.savefig( 'bc-2.png', dpi=60 )

