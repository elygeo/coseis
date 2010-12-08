#!/usr/bin/env python
import os
import numpy as np
import pyproj
import matplotlib.pyplot as plt
import obspy.core, obspy.signal, obspy.xseed
import cst

# parameters
chan = 'HN'
nsta = 8
duration = 50.0
lfilter = None
ysep = 0.35
xoff = 4.0
vscale = 100.0
yoff = -10; lfilter = (0.1, 1.0), 'bandpass', 2, 1
yoff = -2; lfilter = (0.1, 0.5), 'bandpass', 2, 1
yoff = -1.0; lfilter = (0.1, 0.2), 'bandpass', 2, 1

# metadata
id_ = 'chino-cvm-0200-flat'
id_ = 'chino-cvm-0050-flat'
path = os.path.join( 'run', 'sim', id_ ) + os.sep
meta = cst.util.load( path + 'meta.py' )
proj = pyproj.Proj( **meta.projection )
t0 = obspy.core.utcdatetime.UTCDateTime( meta.origin_time )

# stations
f = os.path.join( 'run', 'data', 'station-list.txt' )
s = np.loadtxt( f, 'S9,f,f,f' )
x, y = proj( s['f2'], s['f1'] )

# sort by azimuth into groups, then by radius within group
sta = [
    'CHN', 'MLS', 'PDU', 'FON', 'BFS', 'RVR',
    'PSR', 'RIO', 'KIK', 'GSA', 'HLL', 'DEC', 'CHF', 'LFP',
    'FUL', 'SRN', 'PLS', 'OGC', 'BRE', 'LLS', 'SAN', 'STG', 'SDD',
    'OLI', 'RUS', 'DLA', 'LTP', 'STS', 'LAF', 'WTT', 'USC', 'SMS',
]
i = 19
r = x * x + y * y
a = np.arctan2( y, x )
a = (a - a[i]) % (2.0 * np.pi)
i = a.argsort()
s = s[i]
r = r[i]
station_groups = []
for i in range( 0, len( s ), nsta ):
    s_ = s[i:i+nsta]
    r_ = r[i:i+nsta]
    j = r_.argsort()
    station_groups.append( s_[j] )

# setup figure
plt.rcdefaults()
plt.rc( 'font', size=8 )
plt.rc( 'legend', fontsize=8 )
plt.rc( 'axes', lw=0.5 )
plt.rc( 'lines', lw=0.5, solid_joinstyle='round' )

# loop over station groups
for igroup, group in enumerate( station_groups ):

    # setup figure
    fig = plt.figure( None, (6.4, 8.0), 100, 'w' )
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
    y = nsta * yoff
    cst.plt.lengthscale( ax, [x - 25, x + 25], 2 * [y], label='%s s', backgroundcolor='w' )

    # setup figure 1
    fig1 = plt.figure( None, (6.4, 8.0), 100, 'w' )
    ax1 = fig1.add_axes( [0.1, 0.1, 0.8, 0.8] )

    # loop over stations
    for ista, sta in enumerate( group ):
        sta = sta['f0']

        # loop over channels
        for i in range( 3 ):

            # data
            f = '.'.join( [str( meta.event_id ), sta, chan + 'ENZ'[i], 'sac'] )
            f = os.path.join( 'run', 'data', f )
            st = obspy.core.read( f )
            tr = st[0]
            dt = tr.stats.delta
            tr.data -= tr.data.mean()
            tr.data = dt * np.cumsum( tr.data )
            obspy.signal.detrend( tr.data )
            if lfilter:
                tr.data = cst.signal.filter( tr.data, dt, *lfilter )
            vmax = np.abs( tr.data ).max()
            tr.trim( t0, t0 + duration )
            v = tr.data
            n = v.size
            t = dt * np.arange( n )
            x = i * (duration + xoff)
            y = yoff * (ista % nsta)
            ax.plot( x + t, y + v, 'k-' )
            if i == 0:
                a = '%s %.1f' % (sta.split('.')[1], vmax)
            else:
                a = '%.1f' % vmax
            ax.text( x + duration, y - 0.1 * yoff, a, va='baseline', ha='right' )

            # Forier spectrum
            f = np.arange( n // 2 + 1 ) / (dt * n)
            v = np.fft.rfft( v )
            ax1.semilogx( f, v, 'r-' )

            # synthetics
            n = int( duration / meta.delta[-1] )
            f = os.path.join( path, 'out', sta + '-v%s.bin' % (i + 1) )
            v = np.fromfile( f, meta.dtype, n ) * vscale
            dt = meta.delta[-1]
            t = dt * np.arange( n )
            if lfilter:
                v = cst.signal.filter( v, dt, *lfilter )
            vmax = np.abs( v ).max()
            x = i * (duration + xoff)
            y = yoff * ((ista % nsta) + ysep)
            ax.plot( x + t, y + v, 'r-' )
            ax.text( x + duration, y - 0.1 * yoff, '%.1f' % vmax, va='baseline', ha='right' )

            # Forier spectrum
            f = np.arange( n // 2 + 1 ) / (dt * n)
            v = np.fft.rfft( v )
            ax1.semilogx( f, v, 'r-' )

    # finish figure
    fig.canvas.draw()
    f = os.path.join( path, 'waveform-%.0f-%s.pdf' % (1.0 / lfilter[0][1], igroup) )
    #f = os.path.join( path, 'waveform-%s.pdf' % igroup )
    fig.savefig( f, transparent=True )
    fig.show()

