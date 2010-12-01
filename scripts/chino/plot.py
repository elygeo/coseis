#!/usr/bin/env ipython -wthread
import os
import numpy as np
import pyproj
import matplotlib.pyplot as plt
import obspy.core, obspy.signal, obspy.xseed
import cst

#dl = obspy.xseed.Parser( 'run/stations/dataless.CI.CHN' )

# parameters
chan = 'HN'
nsta = 8
duration = 50.0
lfilter = None
lfilter = (0.1, 1.0), 'bandpass'
voff = -4
scale = 100.0
gain = 1.0
tick = 15.0

# metadata
sim = os.path.join( 'run', 'sim', 'flat-cvm-8000' ) + os.sep
meta = cst.util.load( sim + 'meta.py' )
proj = pyproj.Proj( **meta.projection )
t0 = obspy.core.utcdatetime.UTCDateTime( meta.origin_time )

# stations
sta = [
    'CHN', 'MLS', 'PDU', 'FON', 'BFS', 'RVR', 'RSB',
    'FUL', 'SRN', 'PLS', 'OGC', 'BRE', 'LLS', 'SAN', 'STG', 'SDD',
    'OLI', 'RUS', 'DLA', 'LTP', 'STS', 'LAF', 'WTT', 'USC', 'SMS',
    'PSR', 'RIO', 'KIK', 'GSA', 'HLL', 'DEC', 'CHF', 'LFP',
]
sta = [
    'CHN', 'MLS', 'PDU', 'FON', 'BFS', 'RVR',
    'PSR', 'RIO', 'KIK', 'GSA', 'HLL', 'DEC', 'CHF', 'LFP',
    'FUL', 'SRN', 'PLS', 'OGC', 'BRE', 'LLS', 'SAN', 'STG', 'SDD',
    'OLI', 'RUS', 'DLA', 'LTP', 'STS', 'LAF', 'WTT', 'USC', 'SMS',
]
s = np.loadtxt( 'station-list.txt', 'S9,f,f,f' )
x, y = proj( s['f2'], s['f1'] )

# sort by azimuth into groups, then by radius within group
r = x * x + y * y
a = np.arctan2( y, x )
s = s[a.argsort()]
station_groups = []
for i in range( 0, len( s ), nsta ):
    j = r[i:i+nsta].argsort()
    station_groups.append( s[i:i+nsta][j] )

# setup figure
plt.rcdefaults()
plt.rc( 'font', size=8 )
plt.rc( 'legend', fontsize=8 )
plt.rc( 'axes', lw=0.5 )
plt.rc( 'lines', lw=0.5, solid_joinstyle='round' )

# plot directory
f = os.path.join( 'run', 'plot' )
if not os.path.exists( f ):
    os.makedirs( f )

# loop over station groups
for igroup, group in enumerate( station_groups ):

    # setup figure
    fig = plt.figure( None, (6.4, 6.4), 100, 'w' )
    ax = fig.add_axes( [0.01, 0.01, 0.98, 0.98] )
    ax.axis( 'tight' )
    ax.set_xlim( [-tick, 3 * (duration + tick)] )
    ax.set_ylim( [voff * (nsta + 0.2), -1.2 * voff] )
    x = np.arange( 0, duration, tick )
    ax.set_xticks( np.hstack( [x, x + duration + tick, x + 2 * (duration + tick)] ) )
    ax.set_yticks( [] )
    ax.set_xticklabels( [] )
    x = 1.5 * duration + tick
    y = -0.6 * voff
    ax.text( x - duration - tick, y, 'East-West',   ha='center', va='baseline' )
    ax.text( x,                   y, 'North-South', ha='center', va='baseline' )
    ax.text( x + duration + tick, y, 'Vertical',    ha='center', va='baseline' )
    y = voff * (nsta - 0.25)
    cst.plt.lengthscale( ax, [x - 30, x + 30], 2 * [y], label='%s s', backgroundcolor='w' )

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
            tr.data *= gain
            tr.data -= tr.data.mean()
            tr.data = dt * np.cumsum( tr.data )
            obspy.signal.detrend( tr.data )
            if lfilter:
                tr.data = cst.signal.filter( tr.data, dt, *lfilter )
            vmax = np.abs( tr.data ).max()
            tr.trim( t0, t0 + duration )
            t = dt * np.arange( tr.data.size )
            x = i * (duration + tick)
            y = voff * (ista % nsta)
            ax.plot( x + t, y + tr.data, 'k-' )
            if i == 0:
                a = '%s %.1f' % (sta.split('.')[1], vmax)
            else:
                a = '%.1f' % vmax
            ax.text( x + duration, y - 0.1 * voff, a, va='baseline', ha='right' )

            # synthetics
            n = int( duration / meta.delta[-1] )
            f = os.path.join( sim, 'out', sta + '-v%s.bin' % (i + 1) )
            v = np.fromfile( f, meta.dtype, n ) * scale
            dt = meta.delta[-1]
            t = dt * np.arange( n )
            if lfilter:
                v = cst.signal.filter( v, dt, *lfilter )
            vmax = np.abs( v ).max()
            x = i * (duration + tick)
            y = voff * ((ista % nsta) + 0.333)
            ax.plot( x + t, y + v, 'k-' )
            ax.text( x + duration, y - 0.1 * voff, '%.1f' % vmax, va='baseline', ha='right' )

    # finish figure
    fig.canvas.draw()
    f = os.path.join( 'run', 'plot', 'chino%s.pdf' % igroup )
    fig.savefig( f, transparent=True )
    fig.show()

