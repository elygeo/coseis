#!/usr/bin/env ipython -wthread
import os
import numpy as np
import matplotlib.pyplot as plt
import obspy.core
import cst

# parameters
chan = 'HN'
nsta = 8
fcut = 0.25
fcut = 1.00
duration = 50.0
lowpass = None
lowpass = fcut, 2, 1
lowpass = fcut, 'hann'
voff = -5
scale = 100.0

# metadata
sim = os.path.join( 'run', 'sim', 'flat-1000' ) + os.sep
meta = cst.util.load( sim + 'meta.py' )
t0 = obspy.core.utcdatetime.UTCDateTime( meta.origin_time )
tick = 15.0

# setup figure
plt.rcdefaults()
plt.rc( 'font', size=8 )
plt.rc( 'legend', fontsize=8 )
plt.rc( 'axes', lw=0.5 )
plt.rc( 'lines', lw=0.5, solid_joinstyle='round' )

# loop over stations
for ista, sta in enumerate( open( 'station-list.txt' ).readlines() ):

    # station
    ista %= nsta
    sta = sta.split()[0]

    # setup figure
    if ista == 0:
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

    # channels
    for i in range( 3 ):

        # data
        f = '.'.join( [str( meta.event_id ), sta, chan + 'ENZ'[i], 'sac'] )
        f = os.path.join( 'run', 'data', f )
        tr = obspy.core.read( f )[0]
        dt = tr.stats.delta
        v_ = tr.data.mean()
        tr.trim( t0, t0 + duration )
        v = dt * np.cumsum( tr.data - v_ ) * scale * 0.01
        if lowpass:
            v = cst.signal.lowpass( v, dt, *lowpass )
        vmax = np.abs( v ).max()
        t = dt * np.arange( v.size )
        x = i * (duration + tick)
        y = voff * ista
        ax.plot( x + t, y + v, 'k-' )
        if i == 0:
            a = '%s %.1f' % (sta.split('.')[1], vmax)
        else:
            a = '%.1f' % vmax
        ax.text( x + duration, y - 0.1 * voff, a, va='baseline', ha='right' )

        # synthetics
        n = int( duration / meta.delta[-1] )
        f = os.path.join( sim, sta + '-v%s.bin' % (i + 1) )
        v = np.fromfile( f, meta.dtype, n ) * scale
        dt = meta.delta[-1]
        t = dt * np.arange( n )
        if lowpass:
            v = cst.signal.lowpass( v, dt, *lowpass )
        vmax = np.abs( v ).max()
        x = i * (duration + tick)
        y = voff * (ista + 0.333)
        ax.plot( x + t, y + v, 'k-' )
        ax.text( x + duration, y - 0.1 * voff, '%.1f' % vmax, va='baseline', ha='right' )

    # finish figure
    fig.canvas.draw()
    fig.show()
    if ista == nsta - 1:
        f = os.path.join( 'run', 'plot', 'chino%s.pdf' % (ista // nsta) )
        fig.savefig( f, transparent=True )

