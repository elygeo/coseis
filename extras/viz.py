#!/usr/bin/env python
"""
Visualization utilities
"""
import sys, numpy

def colormap( name='w0', colorexp=1.0, mode='mayavi', n=2001, nmod=0, modlim=0.5 ):
    """
    Colormap library
    """
    centered = False
    a = None
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
        elif name == 'redblue':
            r = 0, 2, 4, 8, 8, 8, 8
            g = 0, 2, 4, 8, 4, 2, 0
            b = 8, 8, 8, 8, 4, 2, 0
            centered = True
        elif name == 'coulomb':
            r = 0, 0, 0, 0, 8, 8, 8, 8, 4
            g = 0, 0, 4, 8, 8, 8, 4, 0, 0
            b = 4, 8, 8, 8, 8, 0, 0, 0, 0
            centered = True
        elif name == 'hot':
            r = 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8
            g = 0, 1, 2, 3, 4, 5, 6, 7, 8, 8, 8, 8, 8
            b = 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 4, 6, 8
        elif name == 'warm':
            g = numpy.arange( 32 ) / 31.0
            r = numpy.ones_like( g )
            b = numpy.zeros_like( g )
        elif name == 'red':
            r = 31.0 - numpy.arange( 32 )
            g = numpy.zeros_like( r )
            b = numpy.zeros_like( r )
        elif name == 'socal':
            r = numpy.array( [ 0,  0,  0, 10, 10, 15, 15, 25, 25, 25] ) / 80.0
            g = numpy.array( [10, 10, 10, 20, 20, 25, 30, 25, 25, 25] ) / 80.0
            b = numpy.array( [38, 38, 38, 40, 40, 25, 20, 17, 17, 17] ) / 80.0
            centered = True
        elif name == 'earth':
            r = numpy.array( [10, 12, 15, 17, 20, 15, 15, 25, 25, 25] ) / 80.0
            g = numpy.array( [15, 18, 21, 24, 27, 25, 30, 25, 25, 25] ) / 80.0
            b = numpy.array( [30, 32, 35, 37, 40, 25, 20, 17, 17, 17] ) / 80.0
            centered = True
        elif name == 'atmosphere':
            r = 0, 8, 0
            g = 0, 8, 0
            b = 8, 8, 8
            a = 0, 4, 0
        elif name == 'wk0':
            r = 31.0 - numpy.arange( 32 )
            g = 31.0 - numpy.arange( 32 )
            b = 31.0 - numpy.arange( 32 )
        else:
            sys.exit( 'colormap %s not found' % name )
    else:
        name = 'custom'
        if len( a ) == 1:
            r = g = b = name
        elif len( a ) == 3:
            r, g, b = name
        elif len( a ) == 4:
            r, g, b, a = name
        else:
            sys.exit( 'bad colormap' )
    n2 = len( r )
    m = 1.0 / max( 1., max(r), max(g), max(b) )
    r = m * numpy.array( r )
    g = m * numpy.array( g )
    b = m * numpy.array( b )
    if a == None:
        a = numpy.ones_like( r )
    else:
        a = m * numpy.array( a )
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
        a  = numpy.interp( x2, x1, a )
        w1 = modlim * numpy.cos( numpy.pi * 2. * nmod * x2 )
        w1 = 1.0 - numpy.maximum( w1, 0.0 )
        w2 = 1.0 + numpy.minimum( w1, 0.0 )
        r = ( 1.0 - w2 * (1.0 - w1 * r) )
        g = ( 1.0 - w2 * (1.0 - w1 * g) )
        b = ( 1.0 - w2 * (1.0 - w1 * b) )
        a = ( 1.0 - w2 * (1.0 - w1 * a) )
        x1 = x2
    if mode in ('matplotlib', 'pyplot', 'pylab'):
        import matplotlib
        cmap = { 'red':numpy.c_[x1, r, r],
               'green':numpy.c_[x1, g, g],
                'blue':numpy.c_[x1, b, b] }
        cmap = matplotlib.colors.LinearSegmentedColormap( name, cmap, n )
    elif mode in ('mayavi', 'tvtk', 'mlab'):
        if nmod <= 0:
            x2 = numpy.arange( n ) / (n - 1.0)
            r  = numpy.interp( x2, x1, r )
            g  = numpy.interp( x2, x1, g )
            b  = numpy.interp( x2, x1, b )
            a  = numpy.interp( x2, x1, a )
            x1 = x2
        cmap = 255 * numpy.array( [r, g, b, a] ).T
    elif mode in ('gmt', 'cpt'):
        cmap = ''
        fmt = '%-10r %3.0f %3.0f %3.0f     %-10r %3.0f %3.0f %3.0f\n'
        for i in range( x1.size - 1 ):
            cmap += fmt % (
                x1[i],   255 * r[i],   255 * g[i],   255 * b[i],
                x1[i+1], 255 * r[i+1], 255 * g[i+1], 255 * b[i+1],
            )
    else:
        cmap = numpy.array( [x1, r, g, b, a] )
    return cmap

def distill_eps( fd, mode=None ):
    """
    Distill EPS to PDF using Ghostscript.
    """
    import subprocess, cStringIO
    if type( fd ) == str:
        fd = cStringIO.StringIO( fd )
    cmd = 'ps2pdf', '-dEPSCrop', '-dPDFSETTINGS=/prepress', '-', '-'
    pid = subprocess.Popen( cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE )
    fd = pid.communicate( fd.getvalue() )[0]
    if mode != 'str':
        fd = cStringIO.StringIO( fd )
        fd.reset()
    return( fd )

def pdf2png( path, dpi=72, mode=None ):
    """
    Rasterize a PDF file using Ghostscript.
    """
    import subprocess, cStringIO
    cmd = 'gs', '-q', '-r%s' % dpi, '-dNOPAUSE', '-dBATCH', '-sDEVICE=pngalpha', '-sOutputFile=-', path
    pid = subprocess.Popen( cmd, stdout=subprocess.PIPE )
    out = pid.communicate()[0]
    if mode != 'str':
        out = cStringIO.StringIO( out )
        out.reset()
    return( out )

def img2pdf( img, dpi=150, mode=None ):
    """
    Convert image array to PDF using PIL and ImageMagick.
    """
    import subprocess, cStringIO, Image
    fd = cStringIO.StringIO()
    img = Image.fromarray( img )
    img.save( fd, format='png' )
    cmd = 'convert', '-density', str( dpi ), 'png:-', 'pdf:-'
    pid = subprocess.Popen( cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE )
    fd = pid.communicate( fd.getvalue() )[0]
    if mode != 'str':
        fd = cStringIO.StringIO( fd )
        fd.reset()
    return( fd )

def pdf_merge( layers ):
    """
    Overlay multiple single page PDF file descriptors.
    """
    import cStringIO, pyPdf
    out = cStringIO.StringIO()
    pdf = pyPdf.PdfFileWriter()
    page = pyPdf.PdfFileReader( layers[0] )
    page = page.getPage( 0 )
    for i in layers[1:]:
        i = pyPdf.PdfFileReader( i )
        i = i.getPage( 0 )
        page.mergePage( i )
    pdf.addPage( page )
    pdf.write( out )
    out.reset()
    return( out )

