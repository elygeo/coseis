#!/usr/bin/env python
"""
Visualization utilities
"""
import os, sys, numpy

def savefig( fd=None, fig=None, format=None, **kwargs ):
    """
    Enhanced version of Matplotlib pylab.savefig command.

    Returns output as a string and optionally saves to a file.
    PDF is distilled using Ghostscript to produce smaller files.
    Takes the same argnuments as pylab.savefig.
    """
    import pylab, cStringIO, subprocess
    if fig == None:
        fig = pylab.gcf()
    if fd:
        if type( fd ) is not file:
            if not format:
                format = fd.split( '.' )[-1]
            fd = open( os.path.expanduser( fd ), 'wb' )
    out = cStringIO.StringIO()
    if format == 'pdf':
        fig.savefig( out, format='eps', **kwargs )
        out = out.getvalue()
        cmd = 'ps2pdf', '-dEPSCrop', '-dPDFSETTINGS=/prepress', '-', '-'
        pid = subprocess.Popen( cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE )
        out = pid.communicate( out )[0]
    else:
        fig.savefig( out, format=format, **kwargs )
        out = out.getvalue()
    if fd:
        fd.write( out )
        fd.close()
        return
    else:
        return out

def pylab_screenshot( fig=None, dpi=None, **kwargs ):
    import pylab, cStringIO
    if fig == None:
        fig = pylab.gcf()
    if dpi == None:
        dpi = fig.dpi
    n = fig.get_size_inches()
    n = n[1] * dpi, n[0] * dpi, 4
    out = cStringIO.StringIO()
    fig.savefig( out, format='raw', dpi=dpi, **kwargs )
    out = out.getvalue()
    out = numpy.fromstring( out, 'u1' ).reshape( n )
    return( out )

def pylab_screenshot_agg( fig ):
    fig.canvas.draw()
    b = fig.canvas.buffer_rgba(0, 0)
    n = fig.canvas.get_width_height()[::-1] + (4,)
    img = numpy.frombuffer( b, 'u1' ).reshape( n )
    return( img )

def pylab_screenshot_pil( fig ):
    import PIL.Image
    fig.canvas.draw()
    b = fig.canvas.buffer_rgba(0, 0)
    n = fig.canvas.get_width_height()
    img = PIL.Image.frombuffer( 'RGBA', n, b, 'raw', 'RGBA', 0, 1 )
    return( img )

def lengthscale( x, y, w=None, label='%s', style='k-', bg='w', ax=None, **kwargs ):
    """
    Draw a length scale bar between the points (x[0], y[0]) and (x[1], y[1]).
    """
    import pylab
    if ax == None:
        ax = pylab.gca()
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
    if mode in ('matplotlib', 'pylab'):
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

def digitize( img, xlim=(-1, 1), ylim=(-1, 1), color='r' ):
    """
    Digitize points on an image and rectify to a rectangular coordinate system.
    """
    import pylab
    import coord
    fig = pylab.gcf()
    fig.clf()
    ax = fig.add_axes( [0, 0, 1, 1] )
    ax.imshow( img )
    ax.axis( 'tight' )
    ax.axis( 'off' )
    pylab.draw()
    pylab.show()
    ax.hold( True )
    xx, yy = [], []
    for j in 0, 1:
        for k in 0, 1:
            print( 'Left-click %r' % [xlim[j], ylim[k]] )
            x, y = fig.ginput( 1, -1 )[0]
            xx += [x]
            yy += [y]
            ax.plot( [x], [y], '+' + color )
            pylab.draw()

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
    fig = pylab.figure()
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
    pylab.close( fig )
    return pp

def mlab_screenshot( fig, mag=None ):
    from enthought.tvtk.api import tvtk
    #fig.scene._lift()
    x, y = size = tuple( fig.scene.get_size() )
    if mag:
        x, y = mag * x, mag * y
        mfig.scene.set_size( (x, y) )
    fig.scene.render()
    img = tvtk.UnsignedCharArray()
    fig.scene.render_window.get_pixel_data( 0, 0, x-1, y-1, 1, img )
    img = img.to_array().reshape( (y, x, 3) )[::-1,:]
    if mag:
        fig.scene.set_size( size )
        fig.scene.render()
    return( img )

def mlab_pmb( x, y, z, s, dx, fg=(1,1,1), bg=(0,0,0), n=16, **kwargs ):
    """
    Poor man's bold text.
    """
    from enthought.mayavi import mlab
    h = []
    for i in range( n ):
        phi = 2.0 * numpy.pi * i / n
        x_ = x + dx * numpy.cos( phi )
        y_ = y + dx * numpy.sin( phi )
        h += [ mlab.text3d( x_, y_, z, s, color=bg, **kwargs ) ]
        h[-1].actor.property.lighting = False
    h += [ mlab.text3d( x_, y_, z, s, color=fg, **kwargs ) ]
    h[-1].actor.property.lighting = False
    return h

def textpmb( x, y, s, dx=None, dy=None, fg='k', bg='w', n=16, ax=None, **kwargs ):
    """
    Poor man's bold text.
    """
    import pylab
    if ax == None:
        ax = pylab.gca()
    aspect = ax.get_aspect()
    if dx == None:
        dx = dy
        if aspect != 'equal' or dy == None:
            l1, l2 = ax.get_xlim()
            dx = 0.001 * (l2 - l1)
    if dy == None:
        dy = dx
        if aspect != 'equal' or dx == None:
            l1, l2 = ax.get_ylim()
            dy = 0.001 * (l2 - l1)
    h = []
    for i in range( n ):
        phi = 2.0 * numpy.pi * i / n
        x_ = x + dx * numpy.cos( phi )
        y_ = y + dy * numpy.sin( phi )
        h += [ ax.text( x_, y_, s, color=bg, **kwargs ) ]
    h += [ ax.text( x, y, s, color=fg, **kwargs ) ]
    return h

def etopo1( indices=None, path='', downsample=1, download=False ):
    """
    Download ETOPO1 Global Relief Model.
    http://www.ngdc.noaa.gov/mgg/global/global.html
    """
    import urllib, zipfile, sord
    filename = os.path.join( path, 'etopo%02d-ice.f32' % downsample )
    if download and not os.path.exists( filename ):
        url = 'ftp://ftp.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/ice_surface/grid_registered/binary_float/etopo1_ice_g.zip'
        f = os.path.join( path, os.path.basename( url ) )
        if not os.path.exists( f ):
            print( 'Retrieving %s' % url )
            urllib.urlretrieve( url, f )
        z = zipfile.ZipFile( f, 'r' ).read( 'etopo1_ice_g.flt' )
        if downsample > 1:
            z = sord.coord.downsample_sphere( z, downsample )
        open( filename, 'wb' ).write( z )
    if indices != None:
        shape = (21601 - 1) / downsample + 1, (10801 - 1) / downsample + 1
        return sord.util.ndread( filename, shape, indices, '<f4' )
    else:
        return

def globe( indices=None, path='', download=False ):
    """
    Global Land One-km Base Elevation Digital Elevation Model.
    http://www.ngdc.noaa.gov/mgg/topo/globe.html
    """
    import urllib, gzip, sord
    filename = os.path.join( path, 'globe30.i16' )
    if download and not os.path.exists( filename ):
        print( 'Building %s' % filename )
        n = 90 * 60 * 2
        url = 'http://www.ngdc.noaa.gov/mgg/topo/DATATILES/elev/%s10g.gz'
        tiles = 'abcd', 'efgh', 'ijkl', 'mnop'
        fd = open( path, 'wb' )
        for j in range( len( tiles ) ):
            row = []
            for k in range( len( tiles[j] ) ):
                u = url % tiles[j][k]
                f = os.path.join( path, os.path.basename( u ) )
                if not os.path.exists( f ):
                    print( 'Retrieving %s' % u )
                    urllib.urlretrieve( u, f )
                z = gzip.open( f, mode='rb' ).read()
                z = numpy.fromstring( z, '<i2' ).reshape( [-1, n] )
                row += [z]
            row = numpy.hstack( row )
            row.tofile( fd )
        fd.close()
        del( z, row )
    if indices != None:
        shape = 43200, 21600
        return sord.util.ndread( filename, shape, indices, '<i2' )
    else:
        return

def topo( lon, lat, path='', download=False ):
    """
    Extrat merged GLOBE/ETOPO1 digital elvation model for given region.
    """
    o = 0.25
    j = int( lon[0] * 60 + 10801 - o ), int( numpy.ceil( lon[1] * 60 + 10801 + o ) )
    k = int( -lat[1] * 60 + 5401 - o ), int( numpy.ceil( -lat[0] * 60 + 5401 + o ) )
    z = etopo1( [j, k], path, download )
    j = 2 * j[0] - 1, 2 * j[1] - 2
    k = 2 * k[0] - 1, 2 * k[1] - 2
    n = j[1] - j[0] + 1, k[1] - k[0] + 1
    z *= 0.0625
    z1 = numpy.empty( n, z.dtype )
    z1[0::2,0::2] = 9 * z[:-1,:-1] + 3 * z[:-1,1:] + 3 * z[1:,:-1] +     z[1:,1:]
    z1[0::2,1::2] = 3 * z[:-1,:-1] + 9 * z[:-1,1:] +     z[1:,:-1] + 3 * z[1:,1:]
    z1[1::2,0::2] = 3 * z[:-1,:-1] +     z[:-1,1:] + 9 * z[1:,:-1] + 3 * z[1:,1:]
    z1[1::2,1::2] =     z[:-1,:-1] + 3 * z[:-1,1:] + 3 * z[1:,:-1] + 9 * z[1:,1:]
    z = globe( [j, k], path, download )
    i = z != -500
    z1[i] = z[i]
    z = z1
    lon = (j[0] - 21600.5) / 120, (j[1] - 21600.5) / 120
    lat = (10800.5 - k[1]) / 120, (10800.5 - k[0]) / 120
    return z[:,::-1], lon, lat

def gshhs( path='', resolution='h', min_area=0.0, min_level=1, max_level=4, range=None, member='gshhs/gshhs_%s.b', download=False ):
    """
    Reader for the Global Self-consistent, Hierarchical, High-resolution Shoreline
    database (GSHHS) by Wessel and Smith.

    resolutions: 'c' crude, 'l' low, 'i' intermediate, 'h' high, 'f' full

    http://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html
    http://www.soest.hawaii.edu/wessel/gshhs/gshhs.html

    Reference:
    Wessel, P., and W. H. F. Smith, A Global Self-consistent, Hierarchical,
    High-resolution Shoreline Database, J. Geophys. Res., 101, 8741-8743, 1996.
    """

    url = 'http://www.ngdc.noaa.gov/mgg/shorelines/data/gshhs/version1.10/gshhs_1.10.zip'
    filename = os.path.join( path, os.path.basename( url ) )

    if download and not os.path.exists( filename ):
        print( 'Downloading %s' % url )
        import urllib
        urllib.urlretrieve( url, filename )

    import zipfile
    data = numpy.fromstring( zipfile.ZipFile( filename ).read( member % resolution ), '>i' )

    xx = []
    yy = []
    i = 0
    nkeep = 0
    ntotal = 0

    while i < data.size:
        ntotal += 1
        hdr = data[i:i+8]
        n = hdr[1]
        i += 8 + 2 * n
        area = hdr[7] * 0.1
        if area < min_area:
            break
        level = hdr[2:3].view( 'i1' )[3]
        if level > max_level or level < min_level:
            continue
        if range != None:
            west, east, south, north = hdr[3:7] * 1e-6
            if west < range[0] or east > range[1] or south < range[2] or north > range[3]:
                continue
        nkeep += 1
        x, y = 1e-6 * numpy.array( data[i-2*n:i].reshape(n, 2).T, 'f' )
        xx += [ x, [numpy.nan] ]
        yy += [ y, [numpy.nan] ]

    print 'GSHHS resolution: %s, selected %s of %s' % (resolution, nkeep, ntotal)
    xx = numpy.concatenate( xx )
    yy = numpy.concatenate( yy )
    return numpy.array( [xx, yy], 'f' )

def engdahlcat( path='engdahl-centennial-cat.f32', fields=['lon', 'lat', 'depth', 'mag'] ):
    """
    Engdahl Centennial Earthquake Catalog to binary file.
    http://earthquake.usgs.gov/research/data/centennial.php
    """
    import urllib
    if not os.path.exists( path ):
        fmt = [
            6, ('icat',   'S6'),
            1, ('asol',   'S1'),
            5, ('isol',   'S5'),
            4, ('year',   'i4'),
            3, ('month',  'i4'),
            3, ('day',    'i4'),
            4, ('hour',   'i4'),
            3, ('minute', 'i4'),
            6, ('second', 'f4'),
            9, ('lat',    'f4'),
            8, ('lon',    'f4'),
            6, ('depth',  'f4'),
            4, ('greg',   'i4'),
            4, ('ntel',   'i4'),
            4, ('mag',    'f4'),
            3, ('msc',    'S3'),
            6, ('mdo',    'S6'),
        ]
        url = 'http://earthquake.usgs.gov/research/data/centennial.cat'
        url = urllib.urlopen( url )
        data = numpy.genfromtxt( url, dtype=fmt[1::2], delimiter=fmt[0::2] )
        out = []
        for f in fields:
            out += [data[:][f]]
        numpy.array( out, 'f' ).T.tofile( path )
    else:
        out = numpy.fromfile( path, 'f' ).reshape( (-1,4) ).T
    return out

def upsample( f ):
    n = list( f.shape )
    n[:2] = [ n[0] * 2 - 1, n[1] * 2 - 1 ]
    g = numpy.empty( n, f.dtype )
    g[0::2,0::2] = f
    g[0::2,1::2] = 0.5 * (f[:,:-1] + f[:,1:])
    g[1::2,0::2] = 0.5 * (f[:-1,:] + f[1:,:])
    g[1::2,1::2] = 0.25 * (f[:-1,:-1] + f[1:,1:] + f[:-1,1:] + f[1:,:-1])
    return g

def downsample_sphere( f, d ):
    """
    Down-sample node-registered spherical surface with averaging.

    The indices of the 2D array f are, respectively, longitude and latitude.
    d is the decimation interval which should be odd to preserve nodal
    registration.
    """
    n = f.shape
    ii = numpy.arange( d ) - (d - 1) / 2
    jj = numpy.arange( 0, n[0], d )
    kk = numpy.arange( 0, n[1], d )
    nn = jj.size, kk.size
    ff = numpy.zeros( nn, f.dtype )
    jj, kk = numpy.ix_( jj, kk )
    for dk in ii:
        k = n[1] - 1 - abs( n[1] - 1 - abs( dk + kk ) )
        for dj in ii:
            j = (jj + dj) % n[0]
            ff = ff + f[j,k]
    ff[:,0] = ff[:,0].mean()
    ff[:,-1] = ff[:,-1].mean()
    ff *= 1.0 / (d * d)
    return ff

