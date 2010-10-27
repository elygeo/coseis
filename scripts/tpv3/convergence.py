#!/usr/bin/env python
"""
TPV3 convergence test
"""
import os, glob
import numpy as np
import matplotlib.pyplot as plt
import scipy.interpolate.RectBivariateSpline as interp2d
import cst

# paramters
degree = 1
dirs = glob.glob( 'run/tpv3/[0-9]*' )
dirs = glob.glob( 'run/tpv3/[0-9]*' )[3:]

# reference solution
path = dirs[0] + os.sep
meta = cst.util.load( path + 'meta.py' )
n = meta.shapes['trup']
x0  = np.fromfile( path + 'x1.bin',   'f' ).reshape( n[::-1] ).T
y0  = np.fromfile( path + 'x2.bin',   'f' ).reshape( n[::-1] ).T
tt0 = np.fromfile( path + 'trup.bin', 'f' ).reshape( n[::-1] ).T
sv0 = np.fromfile( path + 'psv.bin',  'f' ).reshape( n[::-1] ).T
sx0 = np.fromfile( path + 'su1.bin',  'f' ).reshape( n[::-1] ).T
sy0 = np.fromfile( path + 'su2.bin',  'f' ).reshape( n[::-1] ).T
tt_ = tt0.mean()
sv_ = sv0.mean()
su_ = np.average( np.sqrt( sx0 * sx0 + sy0 * sy0 ) )

# init
dx = []
ttres = []
sures = []
svres = []

# loop over solutions
for d in dirs[1:]:
    path = d + os.sep
    meta = cst.util.load( path + 'meta.py' )
    path += 'out' + os.sep
    dx += [ int( meta.delta[0] + 0.5 ) ]
    n = meta.shapes['trup']

    # mesh
    x = np.fromfile( path + 'x1.bin',   'f' ).reshape( n[::-1] ).T
    y = np.fromfile( path + 'x2.bin',   'f' ).reshape( n[::-1] ).T

    # rupture time
    f = np.fromfile( path + 'trup.bin', 'f' ).reshape( n[::-1] ).T
    f = tt0 - interp2d( x, y, f, kx=degree, ky=degree ).__call__( x0, y0 )
    ttres += [ np.sqrt( np.average( f * f ) ) / tt_ * 100  ]

    # peak slip rate
    f = np.fromfile( path + 'psv.bin', 'f' ).reshape( n[::-1] ).T
    f = sv0 - interp2d( x, y, f, kx=degree, ky=degree ).__call__( x0, y0 )
    svres += [ np.sqrt( np.average( f * f ) ) / sv_ * 100 ]

    # slip
    f = np.fromfile( path + 'su1.bin', 'f' ).reshape( n[::-1] ).T
    g = np.fromfile( path + 'su2.bin', 'f' ).reshape( n[::-1] ).T
    f = sx0 - interp2d( x, y, f, kx=degree, ky=degree ).__call__( x0, y0 )
    g = sy0 - interp2d( x, y, g, kx=degree, ky=degree ).__call__( x0, y0 )
    sures += [ np.sqrt( np.average( f * f + g * g ) ) / su_ * 100 ]

# output
for i in range( len( ttres ) ):
    print dirs[i+1], ttres[i], sures[i], svres[i]

# plotting
if 0:
    plt.rcdefaults()
    plt.rc( 'font', size=8 )
    plt.rc( 'axes', linewidth=0.5 )
    plt.rc( 'ytick.minor', size=1 )
    plt.rc( 'ytick.major', size=2 )
    plt.rc( 'xtick.minor', size=0 )
    plt.rc( 'xtick.major', size=2 )
    plt.rc( 'lines', linewidth=0.5, color='k', markersize=3 )
    fig = plt.figure( size=(3.2, 3.2) )
    ax = fig.add_axes( [0.15, 0.15, 0.8, 0.8] )
    ax.loglog( dx, ttres, 'ko-' )
    ax.loglog( dx, sures, 'ks-', markerfacecolor=(0.5, 0.5, 0.5) )
    ax.loglog( dx, svres, 'k^-', markerfacecolor='w', markersize=3.5 )
    ax.text( 0.8*dx[0], 0.8*ttres[0], 'Rupture time', ha='left', va='top' )
    ax.text( dx[-1], 0.8*sures[-1], 'Slip', ha='center', va='top' )
    ax.text( 0.8*dx[6], svres[6],  'Peak slip rate', ha='right' )
    dx = [ x for x in dx if x not in (30, 100, 300) ]
    ax.set_xlim( 10, 750 )
    ax.set_xticks( dx )
    ax.set_xticklabels( dx )
    y = [ '%g' % y for y in ax.get_yticks() ]
    ax.set_yticklabels( y )
    ax.yaxis.set_label_coords( -0.12, 0.5 )
    ax.set_xlabel( 'Grid interval (m)' )
    ax.set_ylabel( 'RMS difference (%)' )
    fig.canvas.draw()
    fig.savefig( 'tpv3-convergence.png' )
    fig.savefig( 'tpv3-convergence.pdf' )

