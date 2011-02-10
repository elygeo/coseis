#!/usr/bin/env python
import os
import numpy as np
import pyproj
import matplotlib.pyplot as plt
import obspy.core
#import obspy.signal, obspy.xseed
import cst

# parameters
chan = 'HN'
nsta = 11
duration = 50.0
lfilter = None
xoff = 4.0
vscale = 100.0
ysep = 0.35
ysep = 0.25
yoff = -1; lfilter = (0.1, 0.25), 'bandpass', 2, -1
yoff = -2; lfilter = (0.1, 0.5), 'bandpass', 2, -1
yoff = -5; lfilter = (0.1, 1.0), 'bandpass', 2, -1
yoff = -20; lfilter = None,

# filter
def filt( x, dt ):
    x = cst.signal.filter( x, dt, *lfilter )
    return x

# metadata
sims = 'chino-cvm-0200-flat', 'chino-cvmh-0200-flat'
sims = 'chino-cvm-0050-flat', 'chino-cvmh-0050-flat'
meta = os.path.join( 'run', 'sim', sims[0], 'meta.py' )
meta = cst.util.load( meta )
proj = pyproj.Proj( **meta.projection )
t0 = obspy.core.utcdatetime.UTCDateTime( meta.origin_time )

# stations
f = os.path.join( 'run', 'data', 'station-list.txt' )
s = np.loadtxt( f, 'S9,f,f,f' )
x, y = proj( s['f2'], s['f1'] )

# sort by azimuth into groups, then by radius within group
i = 19
r = x * x + y * y
a = np.arctan2( y, x )
a = (a - a[i]) % (2.0 * np.pi)
i = a.argsort()
s = s[i]
r = r[i]
n = nsta
station_groups = []
for i in range( 0, len( s ), n ):
    s_ = s[i:i+n]
    r_ = r[i:i+n]
    j = r_.argsort()
    station_groups.append( s_[j] )

# figure defaults
plt.rcdefaults()
plt.rc( 'font', size=8 )
plt.rc( 'legend', fontsize=8 )
plt.rc( 'axes', lw=0.5, color_cycle=['k', 'r', 'b'] )
plt.rc( 'lines', lw=0.5, solid_joinstyle='round' )
#fig1 = False
fig1 = plt.figure( None, (11, 8.5), 100, 'w' )

# loop over station groups
for igroup, group in enumerate( station_groups ):

    # setup figure
    #fig = plt.figure( None, (6.4, 8), 100, 'w' )
    fig = plt.figure( None, (6.4, 9.75), 100, 'w' )
    ax = fig.add_axes( [0.0, 0.0, 1.0, 1.0] )
    ax.axis( 'tight' )
    ax.axis( 'off' )
    ax.set_xlim( [-xoff, 3 * duration + 3 * xoff] )
    ax.set_ylim( [(nsta + 0.2) * yoff, (ysep - 1.2) * yoff] )
    x = 1.5 * duration + xoff
    y = (ysep - 1.0) * yoff
    ax.text( x - duration - xoff, y, 'East-West',   ha='center', va='center' )
    ax.text( x,                   y, 'North-South', ha='center', va='center' )
    ax.text( x + duration + xoff, y, 'Vertical',    ha='center', va='center' )
    y = len( group ) * yoff
    cst.plt.lengthscale( ax, [x - 25, x + 25], 2 * [y], label='%s s', backgroundcolor='w' )

    # loop over stations
    for ista, sta in enumerate( group ):
        name, x, y, z = sta['f0'], sta['f2'], sta['f1'], sta['f3']
        x, y = proj( x, y )
        z -= meta.depth
        spread = 0.00002 * (x * x + y * y + z * z) ** 0.5
        spread = 0.004 * (x * x + y * y) ** 0.25
        print( name )

        # separates
        if fig1:
            fig1.clf()

        # loop over channels
        for ichan in range( 3 ):

            # data
            f = '.'.join( [str( meta.event_id ), name, chan + 'ENZ'[ichan], 'sac'] )
            f = os.path.join( 'run', 'data', f )
            st = obspy.core.read( f )
            tr = st[0]
            dt = tr.stats.delta
            tr.data -= tr.data.mean()
            tr.data = filt( tr.data, dt )
            tr.data = dt * np.cumsum( tr.data )
            tr.trim( t0, t0 + duration )
            vmax = np.abs( tr.data ).max()
            v = tr.data
            n = v.size
            t = dt * np.arange( n )

            # plot
            x = ichan * (duration + xoff)
            y = yoff * (ista % nsta)
            ax.plot( x + t, y + v * spread )
            if ichan == 0:
                a = '%s\n%.1f' % (name.split('.')[1], vmax)
            else:
                a = '%.1f' % vmax
            ax.text( x, y - 0.05 * yoff, a, va='baseline', ha='center' )

            # separates FIXME should fft before trim and window
            if fig1:
                ax1 = fig1.add_subplot( 321 + 2 * ichan )
                ax2 = fig1.add_subplot( 322 + 2 * ichan )
                ax1.set_title( name + '-' + 'ENZ'[ichan] )
                ax2.set_title( name + '-' + 'ENZ'[ichan] )
                ax1.plot( t, v )
                f = np.arange( n // 2 + 1 ) / (dt * n)
                v = abs( np.fft.rfft( v ) ) * 2 / v.size
                ax2.loglog( f, v )

            # synthetics
            for isim, id_ in enumerate( sims ):
                dt = meta.delta[-1]
                f = os.path.join( 'run', 'sim', id_, 'out', name + '-v%s.bin' % (ichan + 1) )
                v = np.fromfile( f, meta.dtype ) * vscale
                #v = replace( v, dt )
                v = filt( v, dt )
                n = int( duration / meta.delta[-1] )
                v = v[:n]
                t = dt * np.arange( n )
                vmax = np.abs( v ).max()

                # plot
                x = ichan * (duration + xoff)
                y = yoff * ((ista % nsta) + (isim + 1) * ysep)
                ax.plot( x + t, y + v * spread )
                ax.text( x, y - 0.05 * yoff, '%.1f' % vmax, va='baseline', ha='center' )

                # separates FIXME should fft before trim
                if fig1:
                    ax1.plot( t, v )
                    f = np.arange( n // 2 + 1 ) / (dt * n)
                    v = abs( np.fft.rfft( v ) ) * 2 / v.size
                    ax2.loglog( f, v )

        # finish separate
        if fig1:
            f = os.path.join( 'run', 'plot', name + '.pdf' )
            fig1.savefig( f, transparate=True )

    # finish figure
    fig.canvas.draw()
    if lfilter[0]:
        f = os.path.join( 'run', 'plot', 'waveform-%.0f-%s' % (1.0 / lfilter[0][1], igroup) )
    else:
        f = os.path.join( 'run', 'plot', 'waveform-raw-%s' % igroup )
    fig.savefig( f + '.pdf', transparent=True )
    fig.savefig( f + '.png', dpi=100 )
    fig.show()

