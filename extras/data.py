#!/usr/bin/env python
"""
Mapping data utilities
"""
import os, numpy

def tsurf( path ):
    """
    Read GOCAD (http://www.gocad.org) trigulated surface "Tsurf" files.
    """
    fh = open( path )
    tsurf = []
    for line in fh.readlines():
        f = line.split()
        if line.startswith( 'GOCAD TSurf' ):
            tface, vrtx, trgl, border, bstone, name, color = [], [], [], [], [], None, None
        elif f[0] in ('VRTX', 'PVRTX'):
            vrtx += [[float(f[2]), float(f[3]), float(f[4])]]
        elif f[0] in ('ATOM', 'PATOM'):
            i = int( f[2] ) - 1
            vrtx += [ vrtx[i] ]
        elif f[0] == 'TRGL':
            trgl += [[int(f[1]) - 1, int(f[2]) - 1, int(f[3]) - 1]]
        elif f[0] == 'BORDER':
            border += [[int(f[2]) - 1, int(f[3]) - 1]]
        elif f[0] == 'BSTONE':
            bstone += [int(f[1]) - 1]
        elif f[0] == 'TFACE':
            if trgl != []:
                tface += [ numpy.array( trgl, 'i' ).T ]
            trgl = []
        elif f[0] == 'END':
            vrtx   = numpy.array( vrtx, 'f' ).T
            border = numpy.array( border, 'i' ).T
            bstone = numpy.array( bstone, 'i' ).T
            tface += [ numpy.array( trgl, 'i' ).T ]
            tsurf += [[vrtx, tface, border, bstone, name, color]]
        elif line.startswith( 'name:' ):
            name = line.split( ':', 1 )[1].strip()
        elif line.startswith( '*solid*color:' ):
            f = line.split( ':' )[1].split()
            color = float(f[0]), float(f[1]), float(f[2])
    return tsurf

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
    database (GSHHS) by Wessel and Smith.  WGS-84 ellipsoid.

    kind: 'coastlines', 'rivers', 'borders'
    resolution: 'crude', 'low', 'intermediate', 'high', 'full'
    range: (min_lon, max_lon, min_lat, max_lat)

    Reference:
    Wessel, P., and W. H. F. Smith, A Global Self-consistent, Hierarchical,
    High-resolution Shoreline Database, J. Geophys. Res., 101, 8741-8743, 1996.
    http://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html
    http://www.soest.hawaii.edu/wessel/gshhs/index.html
    """

    nh = 11
    url = 'http://www.ngdc.noaa.gov/mgg/shorelines/data/gshhs/version2.0/gshhs_2.0.zip'
    filename = os.path.join( path, os.path.basename( url ) )
    kind = dict(c='gshhs', r='wdb_rivers', b='wdb_borders')[kind[0]]
    member = 'gshhs/%s_%s.b' % (kind, resolution[0])

    if kind != 'gshhs':
        min_area = 0.0

    if range != None:
        range = range[0] % 360, range[1] % 360, range[2], range[3]

    if download and not os.path.exists( filename ):
        print( 'Downloading %s' % url )
        import urllib
        if path != '' and not os.path.exists( path ):
            os.makedirs( path )
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
        hdr = data[ii:ii+nh]
        n = hdr[1]
        ii += nh + 2 * n
        level = hdr[2:3].view( 'i1' )[3]

        if level > max_level:
            break
        if level < min_level:
            continue
        area = hdr[7] * 0.1
        if area < min_area:
            continue
        if range != None:
            west, east, south, north = hdr[3:7] * 1e-6
            if east < range[0] or west > range[1] or north < range[2] or south > range[3]:
                continue
        nkeep += 1
        x, y = 1e-6 * numpy.array( data[ii-2*n:ii].reshape(n, 2).T, 'f' )
        if range != None and clip != 0:
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
        xx = numpy.concatenate( xx )[:-1]
        yy = numpy.concatenate( yy )[:-1]
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

