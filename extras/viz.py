#!/usr/bin/env python
"""
Visualization utilities
"""
import os, sys, numpy

def savefig( fd=None, format=None, **kwargs ):
    """
    Enhanced version of Matplotlib pylab.savefig command.

    Returns output as a string and optionally saves to a file.
    PDF is distilled using Ghostscript to produce smaller files.
    Takes the same argnuments as pylab.savefig.
    """
    import pylab, cStringIO, subprocess
    if fd:
        if type( fd ) is not file:
            if not format:
                format = fd.split( '.' )[-1]
            fd = open( os.path.expanduser( fd ), 'wb' )
    out = cStringIO.StringIO()
    if format == 'pdf':
        pylab.savefig( out, format='eps', **kwargs )
        out.reset()
        out = out.read()
        cmd = 'ps2pdf', '-dEPSCrop', '-dPDFSETTINGS=/prepress', '-', '-'
        pid = subprocess.Popen( cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE )
        out = pid.communicate( out )[0]
    else:
        pylab.savefig( out, format=format, **kwargs )
        out.reset()
        out = out.read()
    if fd:
        fd.write( out )
        fd.close()
        return
    else:
        return out

def lengthscale( x, y, w=None, label='%s', style='k-', bg='w', **kwargs ):
    """
    Draw a length scale bar between the points (x[0], y[0]) and (x[1], y[1]).
    """
    import pylab
    x0 = 0.5 * (x[0] + x[1])
    y0 = 0.5 * (y[0] + y[1])
    dx = abs( x[1] - x[0] )
    dy = abs( y[1] - y[0] )
    l = numpy.sqrt( dx*dx + dy*dy )
    if not w:
        x = pylab.xlim()
        y = pylab.ylim()
        x = abs( x[1] - x[0] )
        y = abs( y[1] - y[0] )
        if pylab.gca().get_aspect() == 'equal':
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
    h1 = pylab.plot( x0 + x, y0 + y, style, clip_on=False, **kwargs )
    h2 = pylab.text( x0, y0, label, ha='center', va='center',
        backgroundcolor=bg, rotation=theta )
    return h1, h2

def colormap( name='w0', colorexp=1., output='mayavi', n=2001, nmod=0, modlim=0.5 ):
    """
    Colormap library
    """
    centered = False
    if type( name ) == str:
        if name == 'w000':
            r = 8, 8, 8, 0, 0, 0, 0, 8, 8, 8, 8
            g = 8, 8, 8, 4, 6, 8, 8, 8, 6, 4, 0
            b = 8, 8, 8, 8, 8, 8, 0, 0, 0, 0, 0
        elif name == 'w00':
            r = 8, 8, 0, 0, 0, 0, 8, 8, 8, 8
            g = 8, 8, 4, 6, 8, 8, 8, 6, 4, 0
            b = 8, 8, 8, 8, 8, 0, 0, 0, 0, 0
        elif name == 'w0':
            r = 8, 0, 0, 0, 0, 8, 8, 8, 8
            g = 8, 4, 6, 8, 8, 8, 6, 4, 0
            b = 8, 8, 8, 8, 0, 0, 0, 0, 0
        elif name == 'w1':
            r = 0, 0, 0, 0, 0, 8, 8, 8, 8
            g = 0, 4, 6, 8, 8, 8, 6, 4, 0
            b = 8, 8, 8, 8, 0, 0, 0, 0, 0
        elif name == 'w2':
            r = 0, 0, 0, 4, 8, 8, 8, 8, 8
            g = 8, 4, 0, 4, 8, 4, 0, 4, 8
            b = 8, 8, 8, 8, 8, 4, 0, 0, 0
            centered = True
        elif name == 'hot':
            r = 8, 8, 8, 8
            g = 0, 4, 8, 8
            b = 0, 0, 0, 8
        elif name == 'earth':
            r = numpy.array( [00, 00, 00, 10, 10, 15, 15, 25, 25, 25] ) / 80.0
            g = numpy.array( [10, 10, 10, 20, 20, 25, 30, 25, 25, 25] ) / 80.0
            b = numpy.array( [38, 38, 38, 40, 40, 25, 20, 17, 17, 17] ) / 80.0
        elif name == 'wk0':
            r = 31 - numpy.arange( 32 )
            g = 31 - numpy.arange( 32 )
            b = 31 - numpy.arange( 32 )
        else:
            sys.exit( 'colormap %s not found' % name )
    else:
        r, g, b = name
        name = 'custom'
    n2 = len( r )
    m = 1.0 / max( 1., max(r), max(g), max(b) )
    r = m * numpy.array( r )
    g = m * numpy.array( g )
    b = m * numpy.array( b )
    if centered:
        x1 = 2.0 / (n2 - 1) * numpy.arange( n2 ) - 1
        x1 = numpy.sign( x1 ) * abs( x1 ) ** colorexp * 0.5 + 0.5
    else:
        x1 = 1.0 / (n2 - 1) * numpy.arange( n2 )
        x1 = numpy.sign( x1 ) * abs( x1 ) ** colorexp
    if nmod > 0:
        x2 = numpy.arange( n ) / (n - 1.0)
        r  = numpy.interp( x2, x1, r )
        g  = numpy.interp( x2, x1, g )
        b  = numpy.interp( x2, x1, b )
        w1 = modlim * numpy.cos( numpy.pi * 2. * nmod * x2 )
        w1 = 1.0 - numpy.maximum( w1, 0.0 )
        w2 = 1.0 + numpy.minimum( w1, 0.0 ) 
        r = ( 1.0 - w2 * (1.0 - w1 * r) )
        g = ( 1.0 - w2 * (1.0 - w1 * g) )
        b = ( 1.0 - w2 * (1.0 - w1 * b) )
        x1 = x2
    if output in ( 'matplotlib', 'pylab' ):
        import matplotlib
        cmap = { 'red':numpy.c_[x1, r, r],
               'green':numpy.c_[x1, g, g],
                'blue':numpy.c_[x1, b, b] }
        cmap = matplotlib.colors.LinearSegmentedColormap( name, cmap, n )
    elif output in ( 'mayavi', 'tvtk', 'mlab' ):
        if nmod <= 0:
            x2 = numpy.arange( n ) / (n - 1.0)
            r  = numpy.interp( x2, x1, r )
            g  = numpy.interp( x2, x1, g )
            b  = numpy.interp( x2, x1, b )
            a  = numpy.ones_like( r )
            x1 = x2
        cmap = 255 * numpy.array( [r, g, b, a] ).T
    else:
        cmap = numpy.array( [x1, r, g, b] )
    return cmap

def digitize( img, xlim=(-1,1), ylim=(-1,1), color='r' ):
    """
    Digitize points on an image and rectify to a rectangular coordinate system.
    """
    import pylab
    import coord
    pylab.clf()
    pylab.axes( [0, 0, 1, 1] )
    pylab.imshow( img )
    pylab.axis( 'tight' )
    pylab.axis( 'off' )
    pylab.draw()
    pylab.show()
    pylab.hold( True )
    xx, yy = [], []
    for j in 0, 1:
        for k in 0, 1:
            print( 'Left-click %r' % [xlim[j], ylim[k]] )
            x, y = pylab.ginput( 1, -1 )[0]
            xx += [x]
            yy += [y]
            pylab.plot( [x], [y], '+' + color )
            pylab.draw()

    xx = xx[:2], xx[2:]
    yy = yy[:2], yy[2:]
    print( """
    Left-click, space: add point
    Right-click, delete: cancel last point
    Enter: new line segment
    Enter twice: finish
    """ )
    x0 = 0.5 * ( xlim[1] + xlim[0] )
    y0 = 0.5 * ( ylim[1] + ylim[0] )
    dx = 0.5 * ( xlim[1] - xlim[0] )
    dy = 0.5 * ( ylim[1] - ylim[0] )
    xr, yr = [], []
    while 1:
        xy = pylab.ginput( -1, -1 ) 
        if len( xy ) == 0:
            break
        x, y = zip( *xy )
        pylab.plot( x, y, '+-'+color )
        pylab.draw()
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
    import pylab
    concat = True
    pp = []
    pylab.figure()
    if concat:
        for cc in pylab.contour( *args, **kwargs ).collections:
            p = []
            for c in cc.get_paths():
                p += c.to_polygons() + [[[numpy.nan, numpy.nan]]]
            if p:
                del p[-1]
                pp += [ numpy.concatenate( p ).T ]
            else:
                pp += [ None ]
    else:
        for cc in pylab.contour( *args, **kwargs ).collections:
            p = []
            for c in cc.get_paths():
                p += c.to_polygons()
            pp += [p]
    pylab.close()
    return pp

