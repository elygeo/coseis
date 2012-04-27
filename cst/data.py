"""
Data utilities and sources
"""
# TODO
# Quaternary Fault Database
# ftp://hazards.cr.usgs.gov/maps/qfault/
# http://earthquake.usgs.gov/hazards/qfaults/KML/Quaternaryall.zip

# data repository location
import os
repo = os.path.join(os.path.dirname(__file__), 'data')
del(os)

def upsample(f):
    """
    Up-sample a 2D array by a factor of 2 by interpolation.
    """
    import numpy as np
    n = list(f.shape)
    n[:2] = [n[0] * 2 - 1, n[1] * 2 - 1]
    g = np.empty(n, f.dtype)
    g[0::2,0::2] = f
    g[0::2,1::2] = 0.5 * (f[:,:-1] + f[:,1:])
    g[1::2,0::2] = 0.5 * (f[:-1,:] + f[1:,:])
    g[1::2,1::2] = 0.25 * (f[:-1,:-1] + f[1:,1:] + f[:-1,1:] + f[1:,:-1])
    return g


def downsample(f, d):
    """
    Down-sample a 2D array by a factor d, with averaging.
    """
    import numpy as np
    n = f.shape
    n = (n[0] + 1) // d, (n[1] + 1) // d
    g = np.zeros(n, f.dtype)
    for k in range(d):
        for j in range(d):
            g += f[j::d,k::d]
    g *= 1.0 / (d * d)
    return g


def clipdata(x, y, extent, lines=1):
    """
    Clip data outside extent.

    Parameters
    ----------
    x, y: data coordinates
    extent: (xmin, xmax), (ymin, ymax)
    lines: 0 = points, assume no connectivity.
           1 = line segments, include one extra point past the boundary.
           -1 = line segments, do not include extra point past the boundary.
    """
    import numpy as np
    x = np.asarray(x)
    y = np.asarray(y)
    x1, x2 = extent[0]
    y1, y2 = extent[1]
    i = (x >= x1) & (x <= x2) & (y >= y1) & (y <= y2)
    if lines:
        if lines > 0:
            i[:-1] = i[:-1] | i[1:]
            i[1:] = i[:-1] | i[1:]
        x[~i] = float('nan')
        y[~i] = float('nan')
        i[1:] = i[:-1] | i[1:]
    return x[i], y[i], i


def densify(x, y, delta):
    """
    Piecewise up-sample line segments with spacing delta.
    """
    import numpy as np
    x, y = np.array([x, y])
    if x.size <= 1:
        return np.array([x, y])
    dx = np.diff(x)
    dy = np.diff(y)
    r = np.sqrt(dx * dx + dy * dy)
    xx = [[x[0]]]
    yy = [[y[0]]]
    for i in range(r.size):
        if r[i] > delta:
            ri = np.arange(delta, r[i], delta)
            xx += [np.interp(ri, [0.0, r[i]], x[i:i+2])]
            yy += [np.interp(ri, [0.0, r[i]], y[i:i+2])]
        xx += [[x[i+1]]]
        yy += [[y[i+1]]]
    xx = np.concatenate(xx)
    yy = np.concatenate(yy)
    return np.array([xx, yy])


def downsample_sphere(f, d):
    """
    Down-sample node-registered spherical surface with averaging.

    The indices of the 2D array f are, respectively, longitude and latitude.
    d is the decimation interval which should be odd to preserve nodal
    registration.
    """
    import numpy as np
    n = f.shape
    i = np.arange(d) - (d - 1) / 2
    jj = np.arange(0, n[0], d)
    kk = np.arange(0, n[1], d)
    nn = jj.size, kk.size
    g = np.zeros(nn, f.dtype)
    jj, kk = np.ix_(jj, kk)
    for dk in i:
        k = n[1] - 1 - abs(n[1] - 1 - abs(dk + kk))
        for dj in i:
            j = (jj + dj) % n[0]
            g = g + f[j,k]
    g[:,0] = g[:,0].mean()
    g[:,-1] = g[:,-1].mean()
    g *= 1.0 / (d * d)
    return g


def etopo1(downsample=1):
    """
    ETOPO1 Global Relief Model.
    http://www.ngdc.noaa.gov/mgg/global/global.html
    """
    import os, urllib, zipfile
    import numpy as np
    from . import coord

    filename = os.path.join(repo, 'etopo%02d-ice.npy' % downsample)
    if os.path.exists(filename):
        z = np.load(filename, mmap_mode='c')
    else:
        f1 = os.path.join(repo, 'etopo1_ice_g_i2.bin')
        if not os.path.exists(f1):
            url = 'http://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/ice_surface/grid_registered/binary/etopo1_ice_g_i2.zip'
            print('Retrieving %s' % url)
            f = os.path.join(repo, os.path.basename(url))
            urllib.urlretrieve(url, f)
            zipfile.ZipFile(f).extractall(repo)
        print('Creating %s' % filename)
        n = 10801, 21601
        z = np.fromfile(f1, '<i2').reshape(n).T[:,::-1]
        if downsample > 1:
            z = coord.downsample_sphere(z, downsample)
        np.save(filename, z)
    return z


def globe30(tile=(0, 1), fill=True):
    """
    Global Land One-km Base Elevation DEM.
    Missing bathymetry is optionally filled with ETOPO1.
    http://www.ngdc.noaa.gov/mgg/topo/globe.html

    Parameters
    ----------
    tile: 90 x 90 deg tile indices:
        (0, 0): W Antarctica, S Pacific
        (1, 0): W Antarctica, S America, S Atlantic
        (2, 0): E Antarctica, S Africa, Indian Ocean
        (3, 0): E Antarctica, Australia
        (0, 1): W N America, N Pacific
        (1, 1): E N America, W Africa, W Europe, N Atlantic
        (2, 1): W Asia, Africa, E Europe
        (3, 1): E Asia, W Pacific
    fill: Fill missing data (ocean basins) with ETOPO1 bathymetry.
    """
    import os, urllib, gzip
    import numpy as np

    filename = os.path.join(repo, 'topo%s%s.npy' % tile)
    if os.path.exists(filename):
        z = np.load(filename, mmap_mode='c')
    else:
        print('Creating %s' % filename)
        tiles = ('im', 'jn', 'ko', 'lp'), ('ae', 'bf', 'cg', 'dh')
        shape = 10800, 10800
        z = ''
        j, k = tile
        for i in 0, 1:
            t = tiles[k][j][i]
            u = 'http://www.ngdc.noaa.gov/mgg/topo/DATATILES/elev/%s10g.gz' % t
            f = os.path.join(repo, 'globe30%s.bin.gz' % t)
            if not os.path.exists(f):
                print('Retrieving %s' % u)
                urllib.urlretrieve(u, f)
            z += gzip.open(f, mode='rb').read()
        z = np.fromstring(z, '<i2').reshape(shape).T[:,::-1]
        if fill:
            n = shape[1] // 2
            m = shape[0] // 2
            j = slice(tile[0] * n, tile[0] * n + n + 1)
            k = slice(tile[1] * m, tile[1] * m + m + 1)
            x = 0.0625 * etopo1()[j,k]
            y = np.empty_like(z)
            i0 = slice(None, -1)
            i1 = slice(1, None)
            y[0::2,0::2] = 9 * x[i0,i0] + x[i1,i1] + 3 * (x[i0,i1] + x[i1,i0]) + 0.5
            y[0::2,1::2] = 9 * x[i0,i1] + x[i1,i0] + 3 * (x[i0,i0] + x[i1,i1]) + 0.5
            y[1::2,0::2] = 9 * x[i1,i0] + x[i0,i1] + 3 * (x[i1,i1] + x[i0,i0]) + 0.5
            y[1::2,1::2] = 9 * x[i1,i1] + x[i0,i0] + 3 * (x[i1,i0] + x[i0,i1]) + 0.5
            del(x)
            i = z == -500
            z[i] = y[i]
            del(y, i)
        np.save(filename, z)
    return z


def dem(extent, scale=1.0, downsample=0, mesh=False):
    """
    Extract digital elevation model for given region.

    Parameters
    ----------
    extent: (lon_min, lon_max), (lat_min, lat_max)
    scale: Scaling factor for elevation data
    downsample:
        0: GLOBE 30 sec, with missing data filled by ETOPO1
        1: ETOPO1 60 sec
        >1: Down-sample factor for ETOPO1
    mesh: if True return lon and lat mesh with z

    Returns
    -------
    topo: Elevation array z or if mesh == True (lon, lat, z) arrays.
    extent: Extent of z array possibly larger than requested extent.
    """
    import sys, math
    import numpy as np
    x, y = extent
    if downsample > 0:
        d = 60 // downsample
        x0, y0 = -180.0, -90.0
    else:
        d = 120
        x0 = -180.0 + 0.5 / d
        y0 =  -90.0 + 0.5 / d
    j0 = int(math.floor((x[0] - x0) % 360 * d))
    j1 = int(math.ceil((x[1] - x0) % 360 * d))
    k0 = int(math.floor((y[0] - y0) * d))
    k1 = int(math.ceil((y[1] - y0) * d))
    r = 1.0 / d
    x = j0 * r + x0, j1 * r + x0
    y = k0 * r + y0, k1 * r + y0
    extent = x, y
    if downsample > 0:
        z = etopo1(downsample)[j0:j1,k0:k1]
    else:
        n = 10800
        tile0 = j0 // n, k0 // n
        tile1 = j1 // n, k1 // n
        if tile0 != tile1:
            print('Multiple tiles not implemented.')
            print('Try ETOPO1 (downsample=1) or manually assemble tiles.')
            sys.exit()
        j0, j1 = j0 % n, j1 % n
        k0, k1 = k0 % n, k1 % n
        z = globe30(tile0)[j0:j1+1,k0:k1+1]
        if downsample < 0:
            z = upsample(z)
            d *= 2
    z = z * scale # always do this to convert to float
    if mesh:
        ddeg = 1.0 / d
        n = z.shape
        x = x[0] + ddeg * np.arange(n[0])
        y = y[0] + ddeg * np.arange(n[1])
        y, x = np.meshgrid(y, x)
        return (x, y, z), extent
    else:
        return z, extent
topo = dem


def mapdata(kind=None, resolution='high', extent=None, min_area=0.0, min_level=0, max_level=4, delta=None, clip=1):
    """
    Reader for the Global Self-consistent, Hierarchical, High-resolution Shoreline
    database (GSHHS) by Wessel and Smith.  WGS-84 ellipsoid.

    Parameters
    ----------
    kind: 'coastlines', 'rivers', 'borders', or None
    resolution: 'crude', 'low', 'intermediate', 'high', or 'full'
    extent: (min_lon, max_lon), (min_lat, max_lat)
    delta: densify line segments to given delta.
    min_level, max_level: where levels 1-4 are (1) coastline, (2) lakeshore,
        (3) island-in-lake shore, and (4) lake-in-island-in-lake shore.

    Returns
    -------
    x, y: Coordinates arrays.

    Reference
    ---------
    Wessel, P., and W. H. F. Smith, A Global Self-consistent, Hierarchical,
    High-resolution Shoreline Database, J. Geophys. Res., 101, 8741-8743, 1996.
    http://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html
    http://www.soest.hawaii.edu/wessel/gshhs/index.html
    """
    import os, urllib, zipfile
    import numpy as np

    d = os.path.join(repo, 'gshhs')
    if not os.path.exists(d):
        url = 'http://www.ngdc.noaa.gov/mgg/shorelines/data/gshhs/version2.0/gshhs_2.0.zip'
        print('Downloading %s' % url)
        f = os.path.join(repo, os.path.basename(url))
        urllib.urlretrieve(url, f)
        zipfile.ZipFile(f).extractall(repo)
    if not kind:
        return
    name = {'c': 'GSHHS coastlines', 'r': 'WDB rivers', 'b': 'WDB borders'}[kind[0]]
    kind = {'c': 'gshhs', 'r': 'wdb_rivers', 'b': 'wdb_borders'}[kind[0]]
    filename = os.path.join(repo, 'gshhs/%s_%s.b' % (kind, resolution[0]))
    data = np.fromfile(filename, '>i')
    if kind != 'gshhs':
        min_area = 0.0
    if extent is not None:
        lon, lat = extent
        lon = lon[0] % 360, lon[1] % 360
        extent = lon, lat
    print 'Reading %s resolution %s.' % (resolution, name)
    xx = []
    yy = []
    ii = 0
    nh = 11 # number of header values
    nkeep = 0
    ntotal = 0
    while ii < data.size:
        ntotal += 1
        hdr = data[ii:ii+nh]
        n = hdr[1]
        ii += nh + 2 * n
        level = hdr[2:3].view('i1')[3]
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
        x, y = 1e-6 * np.array(data[ii-2*n:ii].reshape(n, 2).T, 'f')
        if extent is not None and clip != 0:
            if delta:
                x, y = clipdata(x, y, extent, 1)[:2]
                x, y = densify(x, y, delta)
            x, y = clipdata(x, y, extent, clip)[:2]
        elif delta:
            x, y = densify(x, y, delta)
        xx += [x, [float('nan')]]
        yy += [y, [float('nan')]]
    if nkeep:
        xx = np.concatenate(xx)[:-1]
        yy = np.concatenate(yy)[:-1]
    return np.array([xx, yy], 'f')


def us_place_names(kind=None, extent=None):
    """
    USGS place name database.
    """
    import os, urllib, zipfile
    import numpy as np

    filename = os.path.join(repo, 'US_CONCISE.txt')
    if not os.path.exists(filename):
        url = 'http://geonames.usgs.gov/docs/stategaz/US_CONCISE.zip'
        print('Downloading %s' % url)
        f = os.path.join(repo, os.path.basename(url))
        urllib.urlretrieve(url, f)
        zipfile.ZipFile(f).extractall(repo)
    data = open(filename).read()
    name = np.genfromtxt(data, delimiter='|', skip_header=1, usecols=(1,), dtype='S64')
    data.reset()
    kind_ = np.genfromtxt(data, delimiter='|', skip_header=1, usecols=(2,), dtype='S64')
    data.reset()
    lat, lon, elev = np.genfromtxt(data, delimiter='|', skip_header=1, usecols=(9,10,15)).T
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


def engdahl_cat(path='engdahl-centennial-cat.npy'):
    """
    Engdahl Centennial Earthquake Catalog.
    http://earthquake.usgs.gov/research/data/centennial.php
    """
    import os, urllib
    import numpy as np

    f = os.path.join(repo, path)
    if not os.path.exists(f):
        d = [
            6, ('icat',   'S6'),
            1, ('asol',   'S1'),
            5, ('isol',   'S5'),
            4, ('year',   'u2'),
            3, ('month',  'u1'),
            3, ('day',    'u1'),
            4, ('hour',   'u1'),
            3, ('minute', 'u1'),
            6, ('second', 'f4'),
            9, ('lat',    'f4'),
            8, ('lon',    'f4'),
            6, ('depth',  'f4'),
            4, ('greg',   'u2'),
            4, ('ntel',   'u2'),
            4, ('mag',    'f4'),
            3, ('msc',    'S3'),
            6, ('mdo',    'S6'),
        ]
        url = 'http://earthquake.usgs.gov/research/data/centennial.cat'
        print('Retrieving %s' % url)
        url = urllib.urlopen(url)
        data = np.genfromtxt(url, dtype=d[1::2], delimiter=d[0::2])
        np.save(f, data)
    else:
        data = np.load(f)
    return data


def lsh_cat(path='lsh-catalog.npy'):
    """
    Lin, Shearer, Hauksson southern California seismicity catalog.
    http://www.rsmas.miami.edu/personal/glin/LSH.html
    """
    import os, urllib
    import numpy as np

    f = os.path.join(repo, path)
    if not os.path.exists(f):
        dtype = [
            ('year',    'u2'),
            ('month',   'u1'),
            ('day',     'u1'),
            ('hour',    'u1'),
            ('minute',  'u1'),
            ('second',  'f4'),
            ('cuspid',  'u4'),
            ('lat',     'f4'),
            ('lon',     'f4'),
            ('depth',   'f4'),
            ('mag',     'f4'),
            ('np',      'u2'),
            ('ns',      'u2'),
            ('rms',     'f2'),
            ('daytime', 'u1'),
            ('clnum',   'u1'),
            ('nclst',   'u2'),
            ('ndif',    'u2'),
            ('aer_h',   'f4'),
            ('aer_z',   'f4'),
            ('rer_h',   'f4'),
            ('rer_z',   'f4'),
            ('type',    'S2'),
        ]
        url="http://www.rsmas.miami.edu/personal/glin/LSH_files/LSH_1.12"
        print('Retrieving %s' % url)
        url = urllib.urlopen(url)
        data = np.genfromtxt(url, dtype=dtype)
        np.save(f, data)
    else:
        data = np.load(f)
    return data


def cybershake(isrc, irup, islip, ihypo, name=None):
    """
    CyberShake sources.

    Must have account on intensity.usc.edu with auto SSH authentication.

    Parameters
    ----------
    isrc: source ID
    irup: rupture ID
    islip: slip variation ID
    ihypo: hypocenter ID
    name: optional name for the rupture
    """
    import os, subprocess
    import numpy as np
    from . import source

    # get reports
    url = 'intensity.usc.edu:/home/scec-00/cybershk/reports/'
    for f in 'erf35_source_rups.txt', 'erf35_sources.txt':
        if not os.path.exists(f):
            subprocess.check_call(['scp', url + f, f])
    segments = dict(np.loadtxt(f, 'i,S64', delimiter='\t', skiprows=1))

    # get source files
    url = 'intensity.usc.edu:/home/rcf-104/CyberShake2007/ruptures/RuptureVariations_35_V2_3/'
    url = 'intensity.usc.edu:/home/rcf-104/CyberShake2007/ruptures/RuptureVariations_35_V3_2/'
    mesh = '%s%d/%d/%d_%d.txt' % (url, isrc, irup, isrc, irup)
    head = '%s%d/%d/%d_%d.txt.variation.output' % (url, isrc, irup, isrc, irup)
    srf  = '%s%d/%d/%d_%d.txt.variation-s%04d-h%04d' % (url, isrc, irup, isrc, irup, islip, ihypo)
    subprocess.check_call(['scp', head, 'head'])
    subprocess.check_call(['scp', mesh, 'mesh'])
    subprocess.check_call(['scp', srf, 'srf'])

    # extract SRF file
    src = source.srf('srf')

    # update metadata
    shape = src.plane[0]['shape']
    v = open('head').next().split()
    src.nslip = int(v[6])
    src.nhypo = int(v[8])
    with open('mesh', 'r') as fh:
        src.probability = float(fh.next().split()[-1])
        src.magnitude = float(fh.next().split()[-1])
    src.segment = segments[isrc].replace(';', ' ')
    src.event = name
    src.isrc = isrc
    src.irup = irup
    src.islip = islip
    src.ihypo = ihypo
    if not name:
        src.name = src.segment

    # extract trace
    x = src.lon.reshape(shape[::-1]).T
    y = src.lat.reshape(shape[::-1]).T
    src.trace = np.array([x[:,0], y[:,0]])

    # clean up
    subprocess.check_call(['gzip', 'srf'])
    os.remove('mesh')
    os.remove('head')
    return src


