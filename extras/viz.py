#!/usr/bin/env python
"""
Visualization utilities
"""
import os, sys, numpy

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

def topo( lon, lat, path='', cache='', download=False ):
    """
    Extrat merged GLOBE/ETOPO1 digital elvation model for given region.
    """
    if cache and os.path.exists( cache + '.npz' ):
        c = numpy.load( cache + '.npz' )
        return c['z'], c['lon'], c['lat']
    o = 0.25
    j = int( lon[0] * 60 + 10801 - o ), int( numpy.ceil( lon[1] * 60 + 10801 + o ) )
    k = int( -lat[1] * 60 + 5401 - o ), int( numpy.ceil( -lat[0] * 60 + 5401 + o ) )
    z = etopo1( [j, k], path, 1, download )
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
    if cache:
        numpy.savez( cache + '.npz', z=z, lon=lon, lat=lat )
    return z[:,::-1], lon, lat

def mapdata( path='', kind='coastlines', resolution='high', range=None, min_area=0.0, min_level=0, max_level=4, clip=1, download=False ):
    """
    Reader for the Global Self-consistent, Hierarchical, High-resolution Shoreline
    database (GSHHS) by Wessel and Smith.

    kind: 'coastlines', 'rivers', 'boarders'
    resolution: 'crude', 'low', 'intermediate', 'high', 'full'
    range: (min_lon, max_lon, min_lat, max_lat)

    Reference:
    Wessel, P., and W. H. F. Smith, A Global Self-consistent, Hierarchical,
    High-resolution Shoreline Database, J. Geophys. Res., 101, 8741-8743, 1996.
    http://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html
    http://www.soest.hawaii.edu/wessel/gshhs/gshhs.html
    """

    url = 'http://www.ngdc.noaa.gov/mgg/shorelines/data/gshhs/version1.10/gshhs_1.10.zip'
    filename = os.path.join( path, os.path.basename( url ) )
    kind = dict(c='gshhs', r='wdb_rivers', b='wdb_borders')[kind[0]]
    member = 'gshhs/%s_%s.b' % (kind, resolution[0])
    if range != None:
        range = range[0] % 360, range[1] % 360, range[2], range[3]

    if download and not os.path.exists( filename ):
        print( 'Downloading %s' % url )
        import urllib
        urllib.urlretrieve( url, filename )

    import zipfile
    data = numpy.fromstring( zipfile.ZipFile( filename ).read( member ), '>i' )

    xx = []
    yy = []
    ii = 0
    nkeep = 0
    ntotal = 0

    while ii < data.size:
        ntotal += 1
        hdr = data[ii:ii+8]
        n = hdr[1]
        ii += 8 + 2 * n
        area = hdr[7] * 0.1
        if area < min_area:
            continue
        level = hdr[2:3].view( 'i1' )[3]
        if level > max_level or level < min_level:
            continue
        if range != None:
            west, east, south, north = hdr[3:7] * 1e-6
            if east < range[0] or west > range[1] or north < range[2] or south > range[3]:
                continue
        nkeep += 1
        x, y = 1e-6 * numpy.array( data[ii-2*n:ii].reshape(n, 2).T, 'f' )
        if clip:
            i = (x >= range[0]) & (x <= range[1]) & (y >= range[2]) & (y <= range[3])
            if clip > 0:
                i[:-1] = i[:-1] | i[1:]
                i[1:] = i[:-1] | i[1:]
            x[~i] = numpy.nan
            y[~i] = numpy.nan
            i[1:] = i[:-1] | i[1:]
            x = x[i]
            y = y[i]
        xx += [ x, [numpy.nan] ]
        yy += [ y, [numpy.nan] ]

    print '%s, resolution: %s, selected %s of %s' % (member, resolution, nkeep, ntotal)
    if nkeep:
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

def text( ax, x, y, s, bcolor=None, bwidth=0.5, bn=16, **kwargs ):
    """
    Matplotlib text command augmented with poor man's bold.
    """
    h = []
    if bcolor != None:
        aspect = ax.get_aspect()
        dx, dy = ax.get_position().size * ax.figure.get_size_inches() * 72.0
        x1, x2 = ax.get_xbound()
        y1, y2 = ax.get_ybound()
        dx = bwidth * (x2 - x1) / dx
        dy = bwidth * (y2 - y1) / dy
        if aspect == 'equal':
            dx = dy
        args = kwargs.copy()
        args['color'] = bcolor
        for i in range( bn ):
            phi = 2.0 * numpy.pi * i / bn
            x_ = x + dx * numpy.cos( phi )
            y_ = y + dy * numpy.sin( phi )
            h += [ ax.text( x_, y_, s, **args ) ]
    h += [ ax.text( x, y, s, zorder=4, **kwargs ) ]
    return h

def text3d( x, y, z, s, bcolor=None, bwidth=0.5, bn=16, **kwargs ):
    """
    Mayavi text3d command augmented with poor man's bold.
    """
    from enthought.mayavi import mlab
    h = []
    if bcolor != None:
        args = kwargs.copy()
        args['color'] = bcolor
        for i in range( bn ):
            phi = 2.0 * numpy.pi * i / bn
            x_ = x + bwidth * numpy.cos( phi )
            y_ = y + bwidth * numpy.sin( phi )
            h += [ mlab.text3d( x_, y_, z, s, **args ) ]
            h[-1].actor.property.lighting = False
    h += [ mlab.text3d( x_, y_, z, s, **kwargs ) ]
    h[-1].actor.property.lighting = False
    return h

class digital_clock():
    """
    Displays a digital clock with the format H:MM or M:SS in Mayavi.
    Calling the digital clock object with an argument of minutes or seconds sets the time.
    """
    def __init__( self, x0=0, y0=0, z0=0, scale=1.0, color=(0,1,0), line_width=3 ):
        from enthought.mayavi import mlab
        fig = mlab.gcf()
        render = fig.scene.disable_render
        fig.scene.disable_render = True
        xx = x0 + scale / 200.0 * numpy.array( [
            [  -49,  -40, numpy.nan ],
            [   51,   60, numpy.nan ],
            [  -60,  -51, numpy.nan ],
            [   40,   49, numpy.nan ],
            [  -30,   50, numpy.nan ],
            [  -40,   40, numpy.nan ],
            [  -50,   30, numpy.nan ],
        ] )
        yy = y0 + scale / 200.0 * numpy.array( [
            [   10,   90, numpy.nan ],
            [   10,   90, numpy.nan ],
            [  -90,  -10, numpy.nan ],
            [  -90,  -10, numpy.nan ],
            [  100,  100, numpy.nan ],
            [    0,    0, numpy.nan ],
            [ -100, -100, numpy.nan ],
        ] )
        zz = z0 * numpy.ones_like( xx )
        glyphs = [5], [0,2,4,5,6], [0,3], [0,2], [2,4,6], [1,2], [1], [0,2,5,6], [], [2]
        hh = []
        for g in glyphs:
            i = numpy.array( [ i for i in range(7) if i not in g ] )
            h = []
            for x in -0.875, 0.125, 0.875:
                h += [ mlab.plot3d(
                    scale * x + xx[i].flatten(), yy[i].flatten(), zz[i].flatten(),
                    color=color,
                    tube_radius=None,
                    line_width=line_width,
                ) ]
            hh += [h]
        self.glyphs = hh
        x = x0 + scale / 200.0 * numpy.array( [-81, -79, numpy.nan, -71, -69] )
        y = y0 + scale / 200.0 * numpy.array( [-60, -40, numpy.nan, 40, 60] )
        z = z0 * numpy.ones_like( x )
        h = mlab.plot3d( x, y, z, color=color, tube_radius=None, line_width=line_width )
        self.colon = h
        fig.scene.disable_render = render
        return
    def __call__( self, time=None ):
        from enthought.mayavi import mlab
        fig = mlab.gcf()
        render = fig.scene.disable_render
        fig.scene.disable_render = True
        self.colon.visible = False
        for hh in self.glyphs:
            for h in hh:
                h.visible = False
        if time != None:
            self.colon.visible = True
            m = int( time / 60 )
            d = int( (time % 60) / 10 )
            s = int( time % 10 )
            self.glyphs[m][0].visible = True
            self.glyphs[d][1].visible = True
            self.glyphs[s][2].visible = True
        fig.scene.disable_render = render
        return

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

def colorbar( fig, cmap, clim, title=None, rect=None, ticks=None, ticklabels=None, **kwargs ):
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
    if 'bcolor' in kwargs:
        for spine in ax.spines.itervalues():
            spine.set_color( kwargs['bcolor'] )
            spine.set_linewidth( 0.5 )
    else:
        ax.set_axis_off()
    if title:
        x = 0.5 * (clim[0] + clim[1])
        text( ax, x, 2, title, ha='center', va='baseline', **kwargs )
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

def screenshot( fig, format=None, mag=None, aa_frames=8 ):
    """
    Mayavi screenshot.
    """
    from enthought.tvtk.api import tvtk
    #fig.scene._lift()
    x, y = size = tuple( fig.scene.get_size() )
    aa_frames0 = fig.scene.render_window.aa_frames
    fig.scene.render_window.aa_frames = aa_frames
    if mag:
        x, y = mag * x, mag * y
        fig.scene.set_size( (x, y) )
    fig.scene.render()
    img = tvtk.UnsignedCharArray()
    fig.scene.render_window.get_pixel_data( 0, 0, x-1, y-1, 1, img )
    img = img.to_array().reshape( (y, x, 3) )[::-1,:]
    fig.scene.render_window.aa_frames = aa_frames0
    if mag:
        fig.scene.set_size( size )
        fig.scene.render()
    return( img )

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

