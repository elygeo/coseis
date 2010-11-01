"""
Websims plotting routines
"""
import os, sys, cStringIO
import matplotlib
matplotlib.use( 'Agg' )
import matplotlib.pyplot as plt
import numpy as np
from . import conf
from .. import util
from .. import plt as cst_plt


def plot2d( id_, img_file, time='', decimate='' ):
    """
    2d image plot
    """

    # if static search for cached image
    static = time == ''
    img_path = os.path.join( conf.repo[0], id_, img_file )
    if conf.cache and static and os.path.exists( img_path ):
        return

    # metadata
    path  = os.path.join( conf.repo[0], id_, conf.meta )
    meta  = util.load( path )
    delta = meta.x_delta
    shape = meta.x_shape
    axes  = meta.x_axes
    unit  = meta.x_unit
    indices = [0, 0] + [1] * (len( shape ) - 2)
    if static:
        panes = meta.x_static_panes
        shape = shape[:-1] + (1,)
    else:
        panes = meta.x_panes
        indices[-1] = int( float( time ) / delta[-1] + 1.5 )
    if decimate:
        decimate = int( decimate )
    else:
        decimate = meta.x_decimate
    aspect = abs( delta[1] / delta[0] ) * shape[1] / shape[0]
    rotate = aspect > 1.0
    if rotate:
        aspect = 1.0 / aspect
        shape =  (shape[1], shape[0]) + shape[2:]
        delta = (-delta[1], delta[0]) + delta[2:]
        axes  =   (axes[1],  axes[0]) +  axes[2:]
        unit  =   (unit[1],  unit[0]) +  unit[2:]
    height = 8.0 * aspect + 1.0
    axis = ( 
        max( 0, -delta[0] * (shape[0] - 1) ),
        max( 0,  delta[0] * (shape[0] - 1) ),
        max( 0, -delta[1] * (shape[1] - 1) ),
        max( 0,  delta[1] * (shape[1] - 1) ),
    )
    extent = ( 
        0, abs( delta[0] * (shape[0] - 1) ),
        0, abs( delta[1] * (shape[1] - 1) ),
    )

    # setup figure
    inches = 10, height
    fig = plt.figure( None, inches )
    fig.clf()
    ax = fig.add_axes( [0.1, 0.5 / height, 0.835, 1.0 - 1.0 / height] )

    # search for pane
    root, img_ext = os.path.splitext( img_file )
    p = dict( (p[0], p) for p in panes )
    ext = '.bin'
    if root in p:
        ext = ''
    pane = p[root + ext]

    # search for file
    found = False
    if pane != None:
        for d in conf.repo:
            path = os.path.join( d, id_, root + ext )
            if os.path.exists( path ):
                found = True
                break

    # pane properties
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

    # read data or return "file not found"
    if found:
        ff = util.ndread( path, meta.x_shape, indices, meta.dtype )
        ff = scale * ff.squeeze()[::decimate,::decimate]
    else:
        ff = np.array( [[0]] )
        x, y = 0.5 * extent[1], 0.5 * extent[3]
        ax.text( x, y, 'File not found: ' + root,
            color='w', backgroundcolor='r', ha='center', va='center' )
        print( 'File not found: ' + root )

    # image plot
    cmap = cst_plt.colormap( cmap, colorexp=colorexp, nmod=nmod )
    if rotate:
        ff = ff.T
    if root == 'trup':
        ff = np.ma.masked_where( ff>1e8, ff, copy=False )
    im = ax.imshow( ff.T, cmap=cmap, extent=extent, origin='lower',
        interpolation='nearest' )
    ax.hold( True )

    # line plots
    for plot in meta.x_plot:
        path = os.path.join( conf.repo[0], id_, plot[0] )
        x, y = np.loadtxt( path, usecols=(0, 1) ).T
        if rotate:
            x, y = y, x
        if len( plot ) > 1:
            ax.plot( x, y, plot[1], linewidth=0.5 )
        else:
            ax.plot( x, y, '-k', linewidth=0.5 )

    # axes
    if rotate:
        ax.invert_xaxis()
    if delta[0] < 0.0:
        ax.invert_xaxis()
    if delta[1] < 0.0:
        ax.invert_yaxis()
    ax.axis( 'image' )
    ax.axis( axis )
    if aspect < 0.2:
        a, b = ax.get_ylim()
        ax.set_yticks( (a, 0.5 * (a + b), b) )

    # annotations
    ax.set_title( meta.label + title )
    #ax.set_xlabel( axes[0] + ' (%s)' % unit[0] )
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

    # save image and cache if static
    img = cStringIO.StringIO()
    fig.savefig( img, format=img_ext[1:], dpi=100 )
    plt.close( fig )
    img = img.getvalue()
    if static:
        open( img_path, 'wb' ).write( img )
        return
    return img


def plot1d( ids, xx, lowpass, format='png' ):
    """
    Time series plot
    """
    ids = ids.split(',')
    xx = [ float(x) for x in xx.split( ',' ) ]

    # metadata
    dmeta = {}
    npane = 0
    for id_ in ids:
        path = os.path.join( conf.repo[0], ids[0], conf.meta )
        dmeta[id_] = meta = util.load( path )
        npane = max( npane, len( meta.t_panes ) )

    # setup figure
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

    # create axes
    axs = []
    for i in range( npane ):
        ax = fig.add_subplot( npane, 1, i+1 )
        ax.set_color_cycle( ['b', 'r', 'g', 'm', 'y', 'c', 'k'] )
        axs += [ax]

    # loop of sims
    for id_ in ids:
        meta = dmeta[id_]
        delta = meta.t_delta
        unit  = meta.t_unit
        indices = [0] + [ int( float(x) / abs(d) + 1.5 ) for x, d in zip( xx, delta[1:] ) ]

        # loop over panes
        for ipane, pane in enumerate( meta.t_panes ):
            ax = axs[ipane]
            process = None
            if len( pane ) > 2:
                process = pane[2]
            for filename in pane[0]:
                for d in conf.repo:
                    path = os.path.join( d, id_, filename )
                    if os.path.exists( path ):
                        f = util.ndread( path, meta.t_shape, indices, meta.dtype ).squeeze()
                        f, t = process_timeseries( f, delta[0], process, lowpass )
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
                leg[ipane] += [ meta.label + s for s in pane[3] ]
                ax.legend( leg[ipane], loc='upper right' )

    # time label for bottom pane
    ax.set_xlabel( 'Time (%s)' % unit[0] )

    # save image
    img = cStringIO.StringIO()
    fig.savefig( img, format=format, dpi=100 )
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

