"""
Matplotlib utilities
"""
import os
import numpy as np
import viz

def text( ax, x, y, s, edgecolor=None, edgealpha=0.1, edgewidth=0.75, npmb=16, **kwargs ):
    """
    Matplotlib text command augmented with poor man's bold.
    """
    h = [ ax.text( x, y, s, **kwargs ) ]
    h[0].zorder += 1
    if edgecolor is not None:
        if 'bbox' in kwargs:
            del( kwargs['bbox'] )
        kwargs['color'] = edgecolor
        kwargs['alpha'] = edgealpha
        aspect = ax.get_aspect()
        dx, dy = ax.get_position().size * ax.figure.get_size_inches() * 72.0
        x1, x2 = ax.get_xbound()
        y1, y2 = ax.get_ybound()
        dx = edgewidth * (x2 - x1) / dx
        dy = edgewidth * (y2 - y1) / dy
        if aspect == 'equal':
            dx = dy
        m = np.sqrt( 0.5 )
        dx = dx / m
        dy = dy / m
        for i in range( npmb ):
            phi = 2.0 * np.pi * (i + 0.5) / npmb
            x_ = x + dx * np.cos( phi )
            y_ = y + dy * np.sin( phi )
            #x_ = x + dx * np.maximum( -m, np.minimum( m, np.cos( phi ) ) )
            #y_ = y + dy * np.maximum( -m, np.minimum( m, np.sin( phi ) ) )
            h += [ ax.text( x_, y_, s, **kwargs ) ]
    return h

def colormap( *args, **kwargs ):
    """
    Matplotlib colormap. See viz.colormap for details.
    """
    from matplotlib.colors import LinearSegmentedColormap
    v, r, g, b, a = viz.colormap( *args, **kwargs )
    n = 2001
    cmap = { 'red':np.c_[v, r, r],
           'green':np.c_[v, g, g],
            'blue':np.c_[v, b, b] }
    cmap = LinearSegmentedColormap( 'cmap', cmap, n )
    return cmap

def colorbar( fig, cmap, clim, title=None, rect=None, ticks=None, ticklabels=None, boxcolor='k', boxalpha=1.0, boxwidth=0.2, **kwargs ):
    """
    Matplotlib enhanced colorbar.
    """
    if rect is None:
        rect = 0.25, 0.08, 0.5, 0.02
    axis = clim[0], clim[1], 0, 1
    ax = fig.add_axes( rect )
    x = axis[0], axis[0], axis[1], axis[1], axis[0]
    y = axis[2], axis[3], axis[3], axis[2], axis[2]
    ax.plot( x, y, '-', c=boxcolor, lw=boxwidth*2, alpha=boxalpha, clip_on=False )
    ax.imshow( [np.arange(1001)], cmap=cmap, extent=axis )
    ax.axis( 'off' )
    ax.axis( 'tight' )
    ax.axis( axis )
    if title:
        x = 0.5 * (clim[0] + clim[1])
        text( ax, x, 2, title, ha='center', va='baseline', **kwargs )
    if ticks is None:
        ticks = clim[0], 0.5 * (clim[0] + clim[1]), clim[1]
    if ticklabels is None:
        ticklabels = ticks
    for i, x in enumerate( ticks ):
        s = '%s' % ticklabels[i]
        text( ax, x, -0.6, s, ha='center', va='top', **kwargs )
    return ax

def lengthscale( ax, x, y, w=None, label='%s', style='k-', lw=0.5, **kwargs ):
    """
    Draw a length scale bar between the points (x[0], y[0]) and (x[1], y[1]).
    """
    x0 = 0.5 * (x[0] + x[1])
    y0 = 0.5 * (y[0] + y[1])
    dx = x[1] - x[0]
    dy = y[1] - y[0]
    l = np.sqrt( dx*dx + dy*dy )
    if not w:
        x = ax.get_xlim()
        y = ax.get_ylim()
        x = abs( x[1] - x[0] )
        y = abs( y[1] - y[0] )
        if ax.get_aspect() == 'equal':
            w = 0.005 * (y + x)
        else:
            w = 0.01 / l * (y * abs( dx ) + x * abs( dy ))
    try:
        label = label % l
    except TypeError:
        pass
    rot = (dx, -dy), (dy, dx)
    x = -l, l, np.nan, -l, -l, np.nan,  l, l
    y =  0, 0, np.nan, -w,  w, np.nan, -w, w
    x, y = 0.5 / l * np.dot( rot, [x, y] )
    theta = np.arctan2( dy, dx ) * 180.0 / np.pi
    h1 = ax.plot( x0 + x, y0 + y, style, lw=lw, clip_on=False )
    h2 = text( ax, x0, y0, label, ha='center', va='center', rotation=theta, **kwargs )
    return h1, h2

def compass_rose( ax, x, y, r, style='k-', lw=1.0, **kwargs ):
    theta = 0.0
    if 'rotation' in kwargs:
        theta = kwargs['rotation']
    kwargs.update( rotation_mode='anchor' )
    c  = np.cos( theta / 180.0 * np.pi )
    s  = np.sin( theta / 180.0 * np.pi )
    x_ = x + r * np.array( [(c,  s), (-c, -s)] )
    y_ = y + r * np.array( [(s, -c), (-s,  c)] )
    h  = [ ax.plot( x_, y_, style, lw=lw, clip_on=False ) ]
    x_ = x + r * np.array( [(c, -c), ( s, -s)] ) * 1.3
    y_ = y + r * np.array( [(s, -s), (-c,  c)] ) * 1.3
    h += [
        text( ax, x_[0,0], y_[0,0], 'E', ha='left', va='center', **kwargs ),
        text( ax, x_[0,1], y_[0,1], 'W', ha='right', va='center', **kwargs ),
        text( ax, x_[1,0], y_[1,0], 'S', ha='center', va='top', **kwargs ),
        text( ax, x_[1,1], y_[1,1], 'N', ha='center', va='bottom', **kwargs ),
    ]
    return h

def savefig( fig, fd=None, format=None, distill=False, **kwargs ):
    """
    Enhanced version of Matplotlib savefig command.

    Takes the same argnuments as savefig.  Saves to disk if a filename is
    given. Otherwise return a StringIO file descriptor, or a numpy array.  PDF is
    distilled using Ghostscript to produce smaller files.
    """
    import cStringIO
    if type( fd ) is str:
        if format is None:
            format = fd.split( '.' )[-1]
        fd = open( os.path.expanduser( fd ), 'wb' )
    else:
        if format is None:
            format = 'array'
    out = cStringIO.StringIO()
    if format == 'array':
        if 'dpi' not in kwargs:
            kwargs['dpi'] = fig.dpi
        dpi = kwargs['dpi']
        n = fig.get_size_inches()
        n = int( n[1] * dpi ), int( n[0] * dpi ), 4
        fig.savefig( out, format='raw', **kwargs )
        out = np.fromstring( out.getvalue(), 'u1' ).reshape( n )
    elif distill and format == 'pdf':
        fig.savefig( out, format='eps', **kwargs )
        out = viz.distill_eps( out )
    else:
        fig.savefig( out, format=format, **kwargs )
        out.reset()
    if fd is None:
        return( out )
    else:
        fd.write( out.getvalue() )
        fd.close()
        return

def digitize( img, xlim=(-1, 1), ylim=(-1, 1), color='r' ):
    """
    Digitize points on an image and rectify to a rectangular coordinate system.
    """
    import matplotlib.pyplot as plt
    import coord
    fig = plt.gcf()
    fig.clf()
    ax = fig.add_axes( [0, 0, 1, 1] )
    ax.imshow( img )
    ax.axis( 'tight' )
    ax.axis( 'off' )
    plt.draw()
    plt.show()
    ax.hold( True )
    xx, yy = [], []
    for j in 0, 1:
        for k in 0, 1:
            print( 'Left-click %r' % [xlim[j], ylim[k]] )
            x, y = fig.ginput( 1, -1 )[0]
            xx += [x]
            yy += [y]
            ax.plot( [x], [y], '+' + color )
            plt.draw()

    xx = xx[:2], xx[2:]
    yy = yy[:2], yy[2:]
    print( """
    Left-click, space: add point
    Right-click, delete: cancel last point
    Enter: new line segment
    Enter twice: finish
    """ )
    x0 = 0.5 * (xlim[1] + xlim[0])
    y0 = 0.5 * (ylim[1] + ylim[0])
    dx = 0.5 * (xlim[1] - xlim[0])
    dy = 0.5 * (ylim[1] - ylim[0])
    xr, yr = [], []
    while 1:
        xy = fig.ginput( -1, -1 )
        if len( xy ) == 0:
            break
        x, y = zip( *xy )
        ax.plot( x, y, '+-'+color )
        plt.draw()
        x, y = coord.ibilinear( xx, yy, x, y )
        x = x0 + dx * x
        y = y0 + dy * y
        print x
        print y
        xr += [x]
        yr += [y]
    return xr, yr

def contours( *args, **kwargs ):
    """
    Extract contour polygons using matplotlib.
    """
    import matplotlib.pyplot as plt
    concat = True
    pp = []
    fig = plt.figure()
    ax = fig.add_subplot( 111 )
    if concat:
        for cc in ax.contour( *args, **kwargs ).collections:
            p = []
            for c in cc.get_paths():
                p += c.to_polygons() + [[[np.nan, np.nan]]]
            if p:
                del p[-1]
                pp += [np.concatenate( p ).T]
            else:
                pp += [None]
    else:
        for cc in ax.contour( *args, **kwargs ).collections:
            p = []
            for c in cc.get_paths():
                p += c.to_polygons()
            pp += [p]
    plt.close( fig )
    return pp


