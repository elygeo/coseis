#!/usr/bin/env python
"""
Matplotlib utilities
"""
import os, numpy

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
                p += c.to_polygons() + [[[numpy.nan, numpy.nan]]]
            if p:
                del p[-1]
                pp += [numpy.concatenate( p ).T]
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

def text( ax, x, y, s, edgecolor=None, linewidth=0.5, npmb=16, **kwargs ):
    """
    Matplotlib text command augmented with poor man's bold.
    """
    h = [ ax.text( x, y, s, **kwargs ) ]
    h[0].zorder += 1
    if edgecolor != None:
        kwargs['color'] = edgecolor
        aspect = ax.get_aspect()
        dx, dy = ax.get_position().size * ax.figure.get_size_inches() * 72.0
        x1, x2 = ax.get_xbound()
        y1, y2 = ax.get_ybound()
        dx = linewidth * (x2 - x1) / dx
        dy = linewidth * (y2 - y1) / dy
        if aspect == 'equal':
            dx = dy
        for i in range( npmb ):
            phi = 2.0 * numpy.pi * i / npmb
            x_ = x + dx * numpy.cos( phi )
            y_ = y + dy * numpy.sin( phi )
            h += [ ax.text( x_, y_, s, **kwargs ) ]
    return h

def colorbar( fig, cmap, clim, title=None, rect=None, ticks=None, ticklabels=None, linewidth=0.5, **kwargs ):
    """
    Matplotlib enhanced colorbar.
    """
    inches = fig.get_size_inches()
    if rect == None:
        rect = 0.25, 0.08, 0.5, 0.02
    ax = fig.add_axes( rect, xticks=[], yticks=[] )
    im = ax.imshow( [numpy.arange(1001)], cmap=cmap )
    ax.axis( 'auto' )
    im.set_extent( clim + (0, 1) )
    if 'egdecolor' in kwargs:
        for spine in ax.spines.itervalues():
            spine.set_color( kwargs['edgecolor'] )
            spine.set_linewidth( linewidth )
    else:
        ax.set_axis_off()
    if title:
        x = 0.5 * (clim[0] + clim[1])
        text( ax, x, 2, title, ha='center', va='baseline', linewidth, **kwargs )
    if ticks == None:
        ticks = clim[0], 0.5 * (clim[0] + clim[1]), clim[1]
    if ticklabels == None:
        ticklabels = ticks
    for i, x in enumerate( ticks ):
        s = '%s' % ticklabels[i]
        text( ax, x, -0.6, s, ha='center', va='top', **kwargs )
    return ax

def lengthscale( ax, x, y, w=None, label='%s', style='k-', bg='w', **kwargs ):
    """
    Draw a length scale bar between the points (x[0], y[0]) and (x[1], y[1]).
    """
    x0 = 0.5 * (x[0] + x[1])
    y0 = 0.5 * (y[0] + y[1])
    dx = abs( x[1] - x[0] )
    dy = abs( y[1] - y[0] )
    l = numpy.sqrt( dx*dx + dy*dy )
    if not w:
        x = ax.get_xlim()
        y = ax.get_ylim()
        x = abs( x[1] - x[0] )
        y = abs( y[1] - y[0] )
        if ax.get_aspect() == 'equal':
            w = 0.005 * (y + x)
        else:
            w = 0.01 / l * (y * dx + x * dy)
    try:
        label = label % l
    except( TypeError ):
        pass
    rot = (dx, -dy), (dy, dx)
    x = -l, l, numpy.nan, -l, -l, numpy.nan,  l, l
    y =  0, 0, numpy.nan, -w,  w, numpy.nan, -w, w
    x, y = 0.5 / l * numpy.dot( rot, [x, y] )
    theta = numpy.arctan2( dy, dx ) * 180.0 / numpy.pi
    h1 = ax.plot( x0 + x, y0 + y, style, clip_on=False, **kwargs )
    h2 = ax.text( x0, y0, label, ha='center', va='center',
        backgroundcolor=bg, rotation=theta )
    return h1, h2

def savefig( fig, fd=None, format=None, distill=False, **kwargs ):
    """
    Enhanced version of Matplotlib savefig command.

    Takes the same argnuments as savefig.  Saves to disk if a filename is
    given. Otherwise return a StringIO file descriptor, or a numpy array.  PDF is
    distilled using Ghostscript to produce smaller files.
    """
    import cStringIO
    if type( fd ) == str:
        if format == None:
            format = fd.split( '.' )[-1]
        fd = open( os.path.expanduser( fd ), 'wb' )
    else:
        if format == None:
            format = 'array'
    out = cStringIO.StringIO()
    if format == 'array':
        if 'dpi' not in kwargs:
            kwargs['dpi'] = fig.dpi
        dpi = kwargs['dpi']
        n = fig.get_size_inches()
        n = int( n[1] * dpi ), int( n[0] * dpi ), 4
        fig.savefig( out, format='raw', **kwargs )
        out = numpy.fromstring( out.getvalue(), 'u1' ).reshape( n )
    elif distill and format == 'pdf':
        fig.savefig( out, format='eps', **kwargs )
        out = distill_eps( out )
    else:
        fig.savefig( out, format=format, **kwargs )
        out.reset()
    if fd == None:
        return( out )
    else:
        fd.write( out.getvalue() )
        fd.close()
        return

