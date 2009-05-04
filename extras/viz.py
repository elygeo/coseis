#!/usr/bin/env python
"""
Visualization utilities
"""

def colormap( name='w0', colorexp=1., output='mayavi', n=2001, nmod=0, modlim=0.5 ):
    """
    Colormap library
    """
    import sys, numpy
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
            r = numpy.array( [00,00,00,10,10,15,15,25,25,25] ) / 80.
            g = numpy.array( [10,10,10,20,20,25,30,25,25,25] ) / 80.
            b = numpy.array( [38,38,38,40,40,25,20,17,17,17] ) / 80.
        elif name == 'wk0':
            r = 31 - numpy.arange( 32 )
            g = 31 - numpy.arange( 32 )
            b = 31 - numpy.arange( 32 )
        else:
            sys.exit( 'colormap %s not found' % name )
    else:
        r, g, b = name
        name = 'custom'
    n2 = r.size
    m = 1. / max( 1., max(r), max(g), max(b) )
    r = m * numpy.array( r )
    g = m * numpy.array( g )
    b = m * numpy.array( b )
    if centered:
        x1 = 2. / ( n2 - 1 ) * numpy.arange( n2 ) - 1
        x1 = numpy.sign( x1 ) * abs( x1 ) ** colorexp * 0.5 + 0.5
    else:
        x1 = 1. / ( n2 - 1 ) * numpy.arange( n2 )
        x1 = numpy.sign( x1 ) * abs( x1 ) ** colorexp
    if nmod > 0:
        x2 = numpy.arange( n ) / ( n - 1. )
        r  = numpy.interp( x2, x1, r )
        g  = numpy.interp( x2, x1, g )
        b  = numpy.interp( x2, x1, b )
        w1 = modlim * numpy.cos( numpy.pi * 2. * nmod * x2 )
        w1 = 1. - numpy.maximum( w1, 0. )
        w2 = 1. + numpy.minimum( w1, 0. ) 
        r = ( 1. - w2 * ( 1. - w1 * r ) )
        g = ( 1. - w2 * ( 1. - w1 * g ) )
        b = ( 1. - w2 * ( 1. - w1 * b ) )
        x1 = x2
    if output in ( 'matplotlib', 'pylab' ):
        import matplotlib
        cmap = { 'red':numpy.c_[x1,r,r],
               'green':numpy.c_[x1,g,g],
                'blue':numpy.c_[x1,b,b] }
        cmap = matplotlib.colors.LinearSegmentedColormap( name, cmap, n )
    elif output in ( 'mayavi', 'tvtk', 'mlab' ):
        if nmod <= 0:
            x2 = numpy.arange( n ) / ( n - 1. )
            r  = numpy.interp( x2, x1, r )
            g  = numpy.interp( x2, x1, g )
            b  = numpy.interp( x2, x1, b )
            a  = numpy.ones_like( r )
            x1 = x2
        cmap = 255 * numpy.array([ r, g, b, a ]).T
    else:
        cmap = numpy.array([ x1, r, g, b ])
    return cmap

