"""
Websims plotting routines
"""
import os, sys, cStringIO, matplotlib
matplotlib.use( 'Agg' )
import matplotlib.pyplot as plt
import numpy as np
from . import conf, viz
from .. import util


def plot2d( id_, filename, time='', decimate='' ):
    """
    2d image plot
    """
    static = time == ''
    fullfilename = os.path.join( conf.repo[0], id_, filename )
    if conf.cache and static and os.path.exists( fullfilename ):
        return
    path = os.path.join( conf.repo[0], id_, conf.meta )
    m = util.load( path )
    ndim = len( m.x_shape )
    it = list( m.x_axes ).index( 'Time' )
    ix = [ i for i in range(ndim) if i != it and m.x_shape[i] > 1 ][:2]
    dt = m.x_delta[it]
    dx = [ m.x_delta[i] for i in ix ]
    nn = [ m.x_shape[i] for i in ix ]
    axes = [ m.x_axes[i] for i in ix ]
    unit = [ m.x_unit[i] for i in ix ]
    shape = list( m.x_shape )
    indices = ndim * [1]
    for i in ix:
        indices[i] = 0
    if static:
        panes = m.x_static_panes
        shape[it] = 1
    else:
        panes = m.x_panes
        indices[it] = int( float( time ) / dt + 1.5 )
    if decimate:
        decimate = int( decimate )
    else:
        decimate = m.x_decimate
    aspect = abs( dx[1] / dx[0] ) * nn[1] / nn[0]
    rotate = aspect > 1.0
    if rotate:
        aspect = 1.0 / aspect
        nn = nn[::-1]
        dx = dx[::-1]
        dx[0] = -dx[0]
        axes = axes[::-1]
        unit = unit[::-1]
    height = 8.0 * aspect + 1.0
    axis = ( 
        max( 0, -dx[0] * (nn[0] - 1) ),
        max( 0,  dx[0] * (nn[0] - 1) ),
        max( 0, -dx[1] * (nn[1] - 1) ),
        max( 0,  dx[1] * (nn[1] - 1) ),
    )
    extent = ( 
        0, abs( dx[0] * (nn[0] - 1) ),
        0, abs( dx[1] * (nn[1] - 1) ),
    )
    inches = 10, height
    fig = plt.figure( None, inches )
    fig.clf()
    ax = fig.add_axes( [0.1, 0.5 / height, 0.835, 1.0 - 1.0 / height] )
    root, ext = os.path.splitext( filename )
    found = False
    for ipane, pane in enumerate( panes ):
        if pane[0] == root:
            for d in conf.repo:
                path = os.path.join( d, id_, root )
                if os.path.exists( path ):
                    found = True
                    break
            break
    title, cmap, scale, ticks, colorexp, nmod = '', 'w1', 1, None, 1, 0
    if len( pane ) > 1:
        title = pane[1]
        if len( pane ) > 2:
            cmap = pane[2]
            if len( pane ) > 3:
                ticks = pane[3]
                if len( pane ) > 4:
                    scale = pane[4]
                    if len( pane ) > 5:
                        colorexp = pane[5]
                        if len( pane ) > 6:
                            nmod = pane[6]
    if found:
        ff = util.ndread( path, shape, indices, m.dtype ).squeeze()[::decimate,::decimate]
        ff *= scale
    else:
        ff = np.array( [[0]] )
        x, y = 0.5 * extent[1], 0.5 * extent[3]
        ax.text( x, y, 'File not found: ' + root,
            color='w', backgroundcolor='r', ha='center', va='center' )
        print( 'File not found: ' + root )
    cmap = viz.colormap( cmap, colorexp=colorexp, nmod=nmod )
    if rotate:
        ff = ff.T
    if root == 'trup':
        ff = np.ma.masked_where( ff>1e8, ff, copy=False )
    im = ax.imshow( ff.T, cmap=cmap, extent=extent, origin='lower',
        interpolation='nearest' )
    ax.hold( True )
    for plot in m.x_plot:
        path = os.path.join( conf.repo[0], id_, plot[0] )
        x, y = np.loadtxt( path, usecols=(0,1) ).T
        if rotate:
            x, y = y, x
        if len( plot ) > 1:
            ax.plot( x, y, plot[1], linewidth=0.5 )
        else:
            ax.plot( x, y, '-k', linewidth=0.5 )
    if rotate:
        ax.invert_xaxis()
    if dx[0] < 0.0:
        ax.invert_xaxis()
    if dx[1] < 0.0:
        ax.invert_yaxis()
    ax.axis( 'image' )
    ax.axis( axis )
    if aspect < 0.2:
        a, b = ax.get_ylim()
        ax.set_yticks( (a, 0.5 * (a + b), b) )
    ax.set_title( m.label + title )
    if ipane == len( panes ) - 1:
        ax.set_xlabel( axes[0] + ' (%s)' % unit[0] )
    ax.set_ylabel( axes[1] + ' (%s)' % unit[1] )
    if ticks:
        c0, c1 = ticks[0], ticks[-1]
        im.set_clim( c0, c1 )
    else:
        c0, c1 = im.get_clim()
        ticks = c0, 0.5 * (c0 + c1), c1
    fig.colorbar( im,
        orientation = 'vertical',
        fraction = 0.015,
        pad = 0.027,
        aspect = 5.0 + aspect * 30,
        ticks = ticks,
    )
    fig.subplots_adjust(
        left = 0.1,
        right = 0.9,
        top = 1.0 - 0.5 / height,
        bottom = 0.5/ height,
    )
    img = cStringIO.StringIO()
    fig.savefig( img, format=ext[1:], dpi=100 )
    plt.close( fig )
    img = img.getvalue()
    if static:
        open( fullfilename, 'wb' ).write( img )
        return
    return img

def plot1d( ids, filename, x, lowpass ):
    """
    Time series plot
    """
    ext = os.path.splitext( filename )[1]
    x = [ float(x) for x in x.split( ',' ) ]
    path = os.path.join( conf.repo[0], ids[0], conf.meta )
    m = util.load( path )
    npane = len( m.t_panes )
    leg = npane * [[]]
    inches = 10, 3 * npane
    fig = plt.figure( None, inches )
    fig.subplots_adjust(
        left = 0.1,
        right = 0.9,
        top = 0.97,
        bottom = 0.06,
        hspace = 0.15,
    )
    axs = []
    for i in range( npane ):
        ax = fig.add_subplot( npane, 1, i+1 )
        ax.set_color_cycle( ['b', 'r', 'g', 'm', 'y', 'c', 'k'] )
        axs += [ax]
    for id_ in ids:
        f = os.path.join( conf.repo[0], id_, conf.meta )
        m = util.load( f )
        ndim = len( m.t_shape )
        it = list( m.t_axes ).index( 'Time' )
        ix = [ i for i in range(ndim) if i != it and m.t_shape[i] > 1 ]
        dt = m.t_delta[it]
        dx = [ m.t_delta[i] for i in ix ]
        unit = m.t_unit[it]
        indices = ndim * [1]
        indices[it] = 0
        for i in range( len( ix ) ):
            indices[ix[i]] = int( float( x[i] ) / abs( dx[i] ) + 1.5 )
        for ipane, pane in enumerate( m.t_panes ):
            ax = axs[ipane]
            process = None
            if len( pane ) > 2:
                process = pane[2]
            for filename in pane[0]:
                for d in conf.repo:
                    path = os.path.join( d, id_, filename )
                    if os.path.exists( path ):
                        f = util.ndread( path, m.t_shape, indices, m.dtype ).squeeze()
                        f, t = process_timeseries( f, dt, process, lowpass )
                        ax.plot( t, f )
                        break
                else:
                    print( 'File not found: ' + filename )
                    ax.plot( [0], [0] )
                    ax.text( 0, 0, 'File not found: ' + filename,
                        color = 'w',
                        backgroundcolor = 'r',
                        ha = 'center',
                        va = 'center',
                    )
                ax.hold( True )
            if pane[1]:
                ax.set_ylabel( pane[1] )
            if len( pane ) > 3:
                leg[ipane] += [ m.label + s for s in pane[3] ]
                ax.legend( leg[ipane], loc='upper right' )
    ax.set_xlabel( 'Time (%s)' % unit )
    img = cStringIO.StringIO()
    fig.savefig( img, format=ext[1:], dpi=100 )
    plt.close( fig )
    return img.getvalue()

def process_timeseries( f, dt, process='', lowpass='' ):
    """
    Differentiation, integration, and filter application.
    """
    nt = f.size
    if not process:
        t = dt * np.arange( nt )
    elif process == 'diff':
        t = dt * np.arange( nt - 1 ) + 0.5 * dt
        f = 1.0 / dt * np.diff( f )
    elif process == 'diff2':
        t = dt * np.arange( nt - 2 ) + dt
        f = 1.0 / (dt * dt) * np.diff( f, 2 )
    elif process == 'int':
        t = dt * np.arange( nt - 1 ) + 0.5 * dt
        f = dt * np.cumsum( f[:-1] )
    elif process == 'int2':
        t = dt * np.arange( nt )
        f = dt * dt * np.cumsum( f[:-1] )
        f = np.r_[ 0.0, np.cumsum( f ) ]
    else:
        sys.exit( 'unknown process: %s' % process )
    if lowpass:
        cutoff = float( lowpass )
        if cutoff > 0.0 and cutoff < (0.5 / dt):
            f = lowpass_filter( f, dt, cutoff )
    return f, t

def lowpass_filter( x, dt, cutoff, window=2, repeat=-1 ):
    """
    Lowpass filter

    x      : samples
    dt     : sampling interval
    cutoff : cutoff frequency
    window : can be either 'hann' for zero-phase Hann window filter
             or an integer n for an n-pole Butterworth filter.
    """
    if window == 'hann':
        n = 2 * int( 0.5 / (cutoff * dt) ) + 1
        if n > 0:
            w = 0.5 - 0.5 * np.cos(
                2.0 * np.pi * np.arange( n ) / (n - 1) )
            w /= w.sum()
            x = np.convolve( x, w, 'same' )
            if repeat:
                x = np.convolve( x, w, 'same' )
    else:
        import scipy.signal
        wn = cutoff * 2.0 * dt
        b, a = scipy.signal.butter( window, wn )
        x = scipy.signal.lfilter( b, a, x )
        if repeat < 0:
            x = scipy.signal.lfilter( b, a, x[...,::-1] )[...,::-1]
        elif repeat:
            x = scipy.signal.lfilter( b, a, x )
    return x

