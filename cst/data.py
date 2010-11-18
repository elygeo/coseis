"""
Mapping data utilities
"""
# TODO
# Quaternary Fault Database
# ftp://hazards.cr.usgs.gov/maps/qfault/
import os, urllib, gzip, zipfile
import numpy as np
from . import coord, util

def etopo1( indices=None, downsample=1 ):
    """
    Download ETOPO1 Global Relief Model.
    http://www.ngdc.noaa.gov/mgg/global/global.html
    """
    import cst
    repo = cst.site.repo
    shape = 21601, 10801
    filename = os.path.join( repo, 'etopo%02d-ice.bin' % downsample )
    if not os.path.exists( filename ):
        f1 = os.path.join( repo, 'etopo1_ice_g_i2.bin' )
        if not os.path.exists( f1 ):
            url = 'http://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/ice_surface/grid_registered/binary/etopo1_ice_g_i2.zip'
            print( 'Retrieving %s' % url )
            f = os.path.join( repo, os.path.basename( url ) )
            urllib.urlretrieve( url, f )
            zipfile.ZipFile( f ).extractall( repo )
        print( 'Creating %s' % filename )
        z = np.fromfile( f1, '<i2' ).astype( 'f' ).reshape( shape )
        if downsample > 1:
            z = coord.downsample_sphere( z, downsample )
        open( filename, 'wb' ).write( z )
    if indices is not None:
        x, y = shape
        shape = (x - 1) / downsample + 1, (y - 1) / downsample + 1
        return util.ndread( filename, shape, indices, 'f' )
    else:
        return

def globe( indices=None ):
    """
    Global Land One-km Base Elevation Digital Elevation Model.
    http://www.ngdc.noaa.gov/mgg/topo/globe.html
    """
    import cst
    repo = cst.site.repo
    filename = os.path.join( repo, 'globe30.bin' )
    if not os.path.exists( filename ):
        print( 'Building %s' % filename )
        n = 90 * 60 * 2
        url = 'http://www.ngdc.noaa.gov/mgg/topo/DATATILES/elev/%s10g.gz'
        tiles = 'abcd', 'efgh', 'ijkl', 'mnop'
        fd = open( filename, 'wb' )
        for j in range( len( tiles ) ):
            row = []
            for k in range( len( tiles[j] ) ):
                u = url % tiles[j][k]
                f = os.path.join( repo, os.path.basename( u ) )
                if not os.path.exists( f ):
                    print( 'Retrieving %s' % u )
                    urllib.urlretrieve( u, f )
                z = gzip.open( f, mode='rb' ).read()
                z = np.fromstring( z, '<i2' ).reshape( [-1, n] )
                row += [z]
            row = np.hstack( row )
            row.tofile( fd )
        fd.close()
        del( z, row )
    if indices is not None:
        shape = 43200, 21600
        return util.ndread( filename, shape, indices, '<i2' )
    else:
        return

def topo( extent, scale=1.0 ):
    """
    Extract merged GLOBE/ETOPO1 digital elevation model for given region.

    Parameters
    ----------
        extent: (lon_min, lon_max), (lat_min, lat_max)
        scale: Scaling factor for elevation data

    Returns
    -------
        z: Elevation array
        extent: Extent of z array possible larger than requested extent.
    """
    o = 0.25
    lon, lat = extent
    j = int( lon[0] * 60 + 10801 - o ), int( np.ceil( lon[1] * 60 + 10801 + o ) )
    k = int( -lat[1] * 60 + 5401 - o ), int( np.ceil( -lat[0] * 60 + 5401 + o ) )
    z = etopo1( [j, k], 1 )
    j = 2 * j[0] - 1, 2 * j[1] - 2
    k = 2 * k[0] - 1, 2 * k[1] - 2
    n = j[1] - j[0] + 1, k[1] - k[0] + 1
    z *= 0.0625
    z1 = np.empty( n, z.dtype )
    z1[0::2,0::2] = 9 * z[:-1,:-1] + 3 * z[:-1,1:] + 3 * z[1:,:-1] +     z[1:,1:]
    z1[0::2,1::2] = 3 * z[:-1,:-1] + 9 * z[:-1,1:] +     z[1:,:-1] + 3 * z[1:,1:]
    z1[1::2,0::2] = 3 * z[:-1,:-1] +     z[:-1,1:] + 9 * z[1:,:-1] + 3 * z[1:,1:]
    z1[1::2,1::2] =     z[:-1,:-1] + 3 * z[:-1,1:] + 3 * z[1:,:-1] + 9 * z[1:,1:]
    z = globe( [j, k] )
    i = z != -500
    z1[i] = z[i]
    z = z1
    z *= scale
    lon = (j[0] - 21600.5) / 120, (j[1] - 21600.5) / 120
    lat = (10800.5 - k[1]) / 120, (10800.5 - k[0]) / 120
    return z[:,::-1], (lon, lat)

def us_place_names( kind=None, extent=None ):
    """
    USGS place name database.
    """
    import cst
    repo = cst.site.repo
    filename = os.path.join( repo, 'US_CONCISE.txt' )
    if not os.path.exists( filename ):
        url = 'http://geonames.usgs.gov/docs/stategaz/US_CONCISE.zip'
        print( 'Downloading %s' % url )
        f = os.path.join( repo, os.path.basename( url ) )
        urllib.urlretrieve( url, f )
        zipfile.ZipFile( f ).extractall( repo )
    data = open( filename ).read()
    name = np.genfromtxt( data, delimiter='|', skip_header=1, usecols=(1,), dtype='S64' )
    data.reset()
    kind_ = np.genfromtxt( data, delimiter='|', skip_header=1, usecols=(2,), dtype='S64' )
    data.reset()
    lat, lon, elev = np.genfromtxt( data, delimiter='|', skip_header=1, usecols=(9,10,15) ).T
    if kind is not None:
        i = kind == kind_
        lon = lon[i]
        lat = lat[i]
        elev = elev[i]
        name = name[i]
    if extent is not None:
        x, y = extent
        i = (lon >= x[0]) & (lon <= x[1]) & (lat >= y[0]) & (lat <= y[1])
        lon = lon[i]
        lat = lat[i]
        elev = elev[i]
        name = name[i]
    return (lon, lat, elev, name)


def mapdata( kind='coastlines', resolution='high', extent=None, min_area=0.0, min_level=0, max_level=4, delta=None, clip=1 ):
    """
    Reader for the Global Self-consistent, Hierarchical, High-resolution Shoreline
    database (GSHHS) by Wessel and Smith.  WGS-84 ellipsoid.

    Parameters
    ----------
        kind: 'coastlines', 'rivers', or 'borders'
        resolution: 'crude', 'low', 'intermediate', 'high', or 'full'
        extent: (min_lon, max_lon), (min_lat, max_lat)

    Returns
    -------
        x, y: Coordinates arrays.

    Reference:
    Wessel, P., and W. H. F. Smith, A Global Self-consistent, Hierarchical,
    High-resolution Shoreline Database, J. Geophys. Res., 101, 8741-8743, 1996.
    http://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html
    http://www.soest.hawaii.edu/wessel/gshhs/index.html
    """
    import cst
    repo = cst.site.repo
    nh = 11
    kind = {'c': 'gshhs', 'r': 'wdb_rivers', 'b': 'wdb_borders'}[kind[0]]
    if kind != 'gshhs':
        min_area = 0.0
    if extent is not None:
        lon, lat = extent
        lon = lon[0] % 360, lon[1] % 360
        extent = lon, lat
    filename = os.path.join( repo, 'gshhs/%s_%s.b' % (kind, resolution[0]) )
    if not os.path.exists( filename ):
        url = 'http://www.ngdc.noaa.gov/mgg/shorelines/data/gshhs/version2.0/gshhs_2.0.zip'
        print( 'Downloading %s' % url )
        f = os.path.join( repo, os.path.basename( url ) )
        urllib.urlretrieve( url, f )
        zipfile.ZipFile( f ).extractall( repo )
    data = np.fromfile( filename, '>i' )
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
        if extent is not None:
            west, east, south, north = hdr[3:7] * 1e-6
            west, east, south, north = hdr[3:7] * 1e-6
            if east < lon[0] or west > lon[1] or north < lat[0] or south > lat[1]:
                continue
        nkeep += 1
        x, y = 1e-6 * np.array( data[ii-2*n:ii].reshape(n, 2).T, 'f' )
        if extent is not None and clip != 0:
            if delta:
                x, y = clipdata( x, y, extent, 1 )[:2]
                x, y = densify( x, y, delta )
            x, y = clipdata( x, y, extent, clip )[:2]
        elif delta:
            x, y = densify( x, y, delta )
        xx += [ x, [np.nan] ]
        yy += [ y, [np.nan] ]
    print '%s: selected %s of %s' % (filename, nkeep, ntotal)
    if nkeep:
        xx = np.concatenate( xx )[:-1]
        yy = np.concatenate( yy )[:-1]
    return np.array( [xx, yy], 'f' )


def clipdata( x, y, extent, lines=1 ):
    """
    Clip data outside extent.

    Parameters
    ----------
        x, y : data coordinates
        extent : (xmin, xmax), (ymin, ymax)
        lines : 0 = points, assume no connectivity.
                1 = line segments, include one extra point past the boundary.
               -1 = line segments, do not include extra point past the boundary.
    """
    x, y = np.array( [x, y] )
    x1, x2 = extent[0]
    y1, y2 = extent[1]
    i = (x >= x1) & (x <= x2) & (y >= y1) & (y <= y2)
    if lines:
        if lines > 0:
            i[:-1] = i[:-1] | i[1:]
            i[1:] = i[:-1] | i[1:]
        x[~i] = np.nan
        y[~i] = np.nan
        i[1:] = i[:-1] | i[1:]
    return x[i], y[i], i


def densify( x, y, delta ):
    """
    Piecewise up-sample line segments with spacing delta.
    """
    x, y = np.array( [x, y] )
    dx = np.diff( x )
    dy = np.diff( y )
    r = np.sqrt( dx * dx + dy * dy )
    xx = [[x[0]]]
    yy = [[y[0]]]
    for i in range( r.size ):
        if r[i] > delta:
            ri = np.arange( delta, r[i], delta )
            xx += [np.interp( ri, [0.0, r[i]], x[i:i+2] )]
            yy += [np.interp( ri, [0.0, r[i]], y[i:i+2] )]
        xx += [[x[i+1]]]
        yy += [[y[i+1]]]
    xx = np.concatenate( xx )
    yy = np.concatenate( yy )
    return np.array( [xx, yy] )


def engdahlcat( path='engdahl-centennial-cat.npy' ):
    """
    Engdahl Centennial Earthquake Catalog.
    http://earthquake.usgs.gov/research/data/centennial.php
    """
    import cst
    repo = cst.site.repo
    f = os.path.join( repo, path )
    if not os.path.exists( f ):
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
        print( 'Retrieving %s' % url )
        url = urllib.urlopen( url )
        data = np.genfromtxt( url, dtype=fmt[1::2], delimiter=fmt[0::2] )
        np.save( f, data )
    else:
        data = np.load( f )
    return data


def upsample( f ):
    n = list( f.shape )
    n[:2] = [ n[0] * 2 - 1, n[1] * 2 - 1 ]
    g = np.empty( n, f.dtype )
    g[0::2,0::2] = f
    g[0::2,1::2] = 0.5 * (f[:,:-1] + f[:,1:])
    g[1::2,0::2] = 0.5 * (f[:-1,:] + f[1:,:])
    g[1::2,1::2] = 0.25 * (f[:-1,:-1] + f[1:,1:] + f[:-1,1:] + f[1:,:-1])
    return g

def downsample( f, d ):
    n = f.shape
    n = (n[0] + 1) / d, (n[1] + 1) / d
    g = np.zeros( n, f.dtype )
    for k in range( d ):
        for j in range( d ):
            g += f[j::d,k::d]
    g *= 1.0 / (d * d)
    return g


def downsample_sphere( f, d ):
    """
    Down-sample node-registered spherical surface with averaging.

    The indices of the 2D array f are, respectively, longitude and latitude.
    d is the decimation interval which should be odd to preserve nodal
    registration.
    """
    n = f.shape
    i = np.arange( d ) - (d - 1) / 2
    jj = np.arange( 0, n[0], d )
    kk = np.arange( 0, n[1], d )
    nn = jj.size, kk.size
    g = np.zeros( nn, f.dtype )
    jj, kk = np.ix_( jj, kk )
    for dk in i:
        k = n[1] - 1 - abs( n[1] - 1 - abs( dk + kk ) )
        for dj in i:
            j = (jj + dj) % n[0]
            g = g + f[j,k]
    g[:,0] = g[:,0].mean()
    g[:,-1] = g[:,-1].mean()
    g *= 1.0 / (d * d)
    return g


