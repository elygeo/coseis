"""
Data retrieval and processing tools.
"""
import os
import io
import json
import gzip
import math
import zipfile
import subprocess
import urllib.request
from . import repo as repository

# TODO
# Quaternary Fault Database
# ftp://hazards.cr.usgs.gov/maps/qfault/
# http://earthquake.usgs.gov/hazards/qfaults/KML/Quaternaryall.zip


def upsample(f):
    """
    Up-sample a 2D array by a factor of 2 by interpolation.
    """
    import numpy as np
    n = list(f.shape)
    n[:2] = [n[0] * 2 - 1, n[1] * 2 - 1]
    g = np.empty(n, f.dtype)
    g[0::2, 0::2] = f
    g[0::2, 1::2] = 0.5 * (f[:, :-1] + f[:, 1:])
    g[1::2, 0::2] = 0.5 * (f[:-1, :] + f[1:, :])
    g[1::2, 1::2] = 0.25 * (f[:-1, :-1] + f[1:, 1:] + f[:-1, 1:] + f[1:, :-1])
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
            g += f[j::d, k::d]
    g *= 1.0 / (d * d)
    return g


def clipdata(x, y, extent, lines=1):
    """
    Clip data outside extent.

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
    x = np.asarray(x)
    y = np.asarray(y)
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
            g = g + f[j, k]
    g[:, 0] = g[:, 0].mean()
    g[:, -1] = g[:, -1].mean()
    g *= 1.0 / (d * d)
    return g


def etopo1(downsample=1):
    """
    ETOPO1 Global Relief Model.
    http://www.ngdc.noaa.gov/mgg/global/global.html
    """
    import numpy as np
    f = repository + 'DEM0060.npy'
    g = repository + 'DEM%04d.npy' % (60 * downsample)
    u = (
        'http://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/'
        'ice_surface/grid_registered/binary/etopo1_ice_g_i2.zip'
    )
    n = 10801, 21601
    if not os.path.exists(f):
        print('Retrieving %s' % u)
        z = urllib.request.urlopen(u)
        z = io.BytesIO(z.read())
        z = zipfile.ZipFile(z)
        z = z.read('etopo1_ice_g_i2.bin')
        z = np.fromstring(z, '<i2').reshape(n).T[:, ::-1]
        print('Creating %s' % f)
        np.save(f, z)
    if not os.path.exists(g):
        z = np.load(f, mmap_mode='c')
        z = downsample_sphere(z, downsample)
        print('Creating %s' % g)
        np.save(g, z)
    z = np.load(g, mmap_mode='c')
    return z


def globe30(tile=(0, 1), fill=True):
    """
    Global Land One-km Base Elevation DEM.
    Missing bathymetry is optionally filled with ETOPO1.
    http://www.ngdc.noaa.gov/mgg/topo/globe.html

    Parameters:
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
    import numpy as np
    filename = repository + 'DEM0030-%s%s.npy' % tile
    url = 'http://www.ngdc.noaa.gov/mgg/topo/DATATILES/elev/%s10g.gz'
    tiles = ('im', 'jn', 'ko', 'lp'), ('ae', 'bf', 'cg', 'dh')
    shape = 10800, 10800
    if not os.path.exists(filename):
        z = b''
        j, k = tile
        for i in 0, 1:
            t = tiles[k][j][i]
            u = url % t
            print('Retrieving %s' % u)
            f = urllib.request.urlopen(u)
            f = io.BytesIO(f.read())
            z += gzip.GzipFile(fileobj=f).read()
        z = np.fromstring(z, '<i2').reshape(shape).T[:, ::-1]
        if fill:
            n = shape[1] // 2
            m = shape[0] // 2
            j = slice(tile[0] * n, tile[0] * n + n + 1)
            k = slice(tile[1] * m, tile[1] * m + m + 1)
            x = 0.0625 * etopo1()[j, k]
            y = np.empty_like(z)
            i0 = slice(None, -1)
            i1 = slice(1, None)
            y[0::2, 0::2] = 9 * x[i0, i0] + x[i1, i1] + 3 * (
                x[i0, i1] + x[i1, i0]) + 0.5
            y[0::2, 1::2] = 9 * x[i0, i1] + x[i1, i0] + 3 * (
                x[i0, i0] + x[i1, i1]) + 0.5
            y[1::2, 0::2] = 9 * x[i1, i0] + x[i0, i1] + 3 * (
                x[i1, i1] + x[i0, i0]) + 0.5
            y[1::2, 1::2] = 9 * x[i1, i1] + x[i0, i0] + 3 * (
                x[i1, i0] + x[i0, i1]) + 0.5
            del(x)
            i = z == -500
            z[i] = y[i]
            del(y, i)
        print('Creating %s' % filename)
        np.save(filename, z)
        del(z)
    return np.load(filename, mmap_mode='c')


def dem(coords, scale=1.0, downsample=0, mesh=False):
    """
    Extract digital elevation model for given region.

    Parameters:
        coords: (lon, lat)
            If length of lon and lat are 2, they specify the region limits,
            otherwise they specify interpolation points
        scale: Scaling factor for elevation data
        downsample:
            <0: Upsample by factor of 2
            0:  GLOBE 30 sec, with missing data filled by ETOPO1
            1:  ETOPO1 60 sec
            >1: Down-sample factor for ETOPO1

    Returns (when given region limits):
        lon, lat, elev: 2D arrays for regular mesh

    Returns (when given interpolation points):
        elev: array of elevation values at the interpolation points
    """
    import numpy as np
    from . import interp
    x, y = np.asarray(coords)
    sample = x.size > 2 or y.size > 2
    if sample:
        i = ~(np.isnan(x) | np.isnan(y))
        xlim = x[i].min(), x[i].max()
        ylim = y[i].min(), y[i].max()
    else:
        xlim, ylim = coords
    if downsample > 0:
        res = 60 // downsample
        x0, y0 = -180.0, -90.0
    else:
        res = 120
        x0 = -180.0 + 0.5 / res
        y0 = -90.0 + 0.5 / res
    j0 = int(math.floor((xlim[0] - x0) % 360 * res))
    j1 = int(math.ceil((xlim[1] - x0) % 360 * res))
    k0 = int(math.floor((ylim[0] - y0) * res))
    k1 = int(math.ceil((ylim[1] - y0) * res))
    delta = 1.0 / res
    xlim = x0 + j0 * delta, x0 + j1 * delta
    ylim = y0 + k0 * delta, y0 + k1 * delta
    extent = xlim, ylim
    if downsample > 0:
        z = etopo1(downsample)[j0:j1, k0:k1]
    else:
        n = 10800
        tile0 = j0 // n, k0 // n
        tile1 = j1 // n, k1 // n
        if tile0 != tile1:
            print('Multiple tiles not implemented.')
            print('Try ETOPO1 (downsample=1) or manually assemble tiles.')
            raise Exception
        j0, j1 = j0 % n, j1 % n
        k0, k1 = k0 % n, k1 % n
        z = globe30(tile0)[j0:j1+1, k0:k1+1]
        if downsample < 0:
            z = upsample(z)
            res *= 2
    z = z * scale  # always do this to convert to float
    if sample:
        return interp.interp2(extent, z, (x, y))
    elif mesh:
        delta = 1.0 / res
        n = z.shape
        x = xlim[0] + delta * np.arange(n[0])
        y = ylim[0] + delta * np.arange(n[1])
        y, x = np.meshgrid(y, x)
        return (x, y, z)
    else:
        return extent, z


def vs30_wald(x, y, mesh=False, region='Western_US', method='nearest'):
    """
    Wald, et al. Vs30 map.
    """
    import numpy as np
    from . import interp
    f = os.path.join(repository, 'Vs30-Wald-%s.npy') % region.replace('_', '-')
    u = 'http://earthquake.usgs.gov/hazards/apps/vs30/downloads/%s.grd.gz'
    if not os.path.exists(f):
        u = u % region
        print('Retrieving %s' % u)
        z = urllib.request.urlopen(u).read()
        z = io.BytesIO(z)
        z = gzip.GzipFile(fileobj=z).read()[19512:]
        z = np.fromstring(z, '>f').reshape((2400, 2280)).T
        np.save(f, z)
    x = np.asarray(x)
    y = np.asarray(y)
    sample = x.size > 2 or y.size > 2
    if sample:
        xlim = x.min(), x.max()
        ylim = y.min(), y.max()
    else:
        xlim, ylim = x, y
    res = 120
    delta = 1.0 / res
    x0 = -125.0 + 0.5 * delta
    y0 = 30.0 + 0.5 * delta
    j0 = int(math.floor((xlim[0] - x0) % 360 * res))
    j1 = int(math.ceil((xlim[1] - x0) % 360 * res))
    k0 = int(math.floor((ylim[0] - y0) * res))
    k1 = int(math.ceil((ylim[1] - y0) * res))
    xlim = x0 + j0 * delta, x0 + j1 * delta
    ylim = y0 + k0 * delta, y0 + k1 * delta
    extent = xlim, ylim
    z = np.load(f, mmap_mode='c')[j0:j1+1, k0:k1+1]
    if sample:
        z = interp.interp2(extent, z, (x, y), method=method)
        return z
    elif mesh:
        n = z.shape
        x = xlim[0] + delta * np.arange(n[0])
        y = ylim[0] + delta * np.arange(n[1])
        y, x = np.meshgrid(y, x)
        return (x, y, z)
    else:
        return extent, z


def mapdata(
    kind=None, resolution='high', extent=None, min_area=0.0, min_level=0,
    max_level=4, delta=None, clip=1
):
    """
    Reader for the Global Self-consistent, Hierarchical, High-resolution
    Shoreline database (GSHHS) by Wessel and Smith.  WGS-84 ellipsoid.

    Parameters:
        kind: 'coastlines', 'rivers', 'borders', or None
        resolution: 'crude', 'low', 'intermediate', 'high', or 'full'
        extent: (min_lon, max_lon), (min_lat, max_lat)
        delta: densify line segments to given delta.
        min_level, max_level: where levels 1-4 are (1) coastline, (2)
            lakeshore, (3) island-in-lake shore, and (4) lake-in-island-in-lake
            shore.

    Returns (x, y) coordinates arrays.

    Reference:
    Wessel, P., and W. H. F. Smith, A Global Self-consistent, Hierarchical,
    High-resolution Shoreline Database, J. Geophys. Res., 101, 8741-8743, 1996.
    http://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html
    http://www.soest.hawaii.edu/wessel/gshhs/index.html
    """
    import numpy as np

    url = (
        'http://www.ngdc.noaa.gov/mgg/shorelines/'
        'data/gshhg/latest/gshhg-bin-2.3.5.zip'
    )
    d = os.path.join(repository, 'GSHHS')
    if not os.path.exists(d):
        print('Retrieving %s' % url)
        data = urllib.request.urlopen(url)
        data = io.BytesIO(data.read())
        zipfile.ZipFile(data).extractall(d)
    if not kind:
        return
    name = {'c': 'GSHHS coastlines', 'r': 'WDB rivers', 'b': 'WDB borders'}
    name = name[kind[0]]
    kind = {'c': 'gshhs', 'r': 'wdb_rivers', 'b': 'wdb_borders'}[kind[0]]
    filename = os.path.join(
        repository, 'GSHHS/%s_%s.b' % (kind, resolution[0])
    )
    data = np.fromfile(filename, '>i')
    if kind != 'gshhs':
        min_area = 0.0
    if extent is not None:
        lon, lat = extent
        lon = lon[0] % 360, lon[1] % 360
        extent = lon, lat
    print('Reading %s resolution %s.' % (resolution, name))
    xx = []
    yy = []
    ii = 0
    nh = 11  # number of header values
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
            if (
                east < lon[0] or north < lat[0] or
                west > lon[1] or south > lat[1]
            ):
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


def us_place_names():
    """
    USGS place name database.
    """
    import numpy as np

    u = 'http://geonames.usgs.gov/docs/stategaz/US_CONCISE.zip'
    f = repository + 'US-Place-Names.npy'
    c = 1, 2, 3, 5, 9, 10, 15
    t = [
        ('name', 'S84'),
        ('class', 'S15'),
        ('state', 'S2'),
        ('county', 'S26'),
        ('lat', 'f'),
        ('lon', 'f'),
        ('elev', 'i'),
    ]
    if not os.path.exists(f):
        print('Retrieving %s' % u)
        x = urllib.request.urlopen(u)
        x = io.BytesIO(x.read())
        x = zipfile.ZipFile(x)
        x = x.open(x.namelist()[0])
        x = np.genfromtxt(x, delimiter='|', skip_header=1, usecols=c, dtype=t)
        np.save(f, x)
        del(x)
    return np.load(f, mmap_mode='c')


def engdahl_cat():
    """
    Engdahl Centennial Earthquake Catalog.
    http://earthquake.usgs.gov/data/centennial/
    """
    import numpy as np
    f = repository + 'Engdahl-Centennial-Cat.npy'
    u = 'http://earthquake.usgs.gov/data/centennial/centennial_Y2K.CAT'
    t = [
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
    if not os.path.exists(f):
        print('Retrieving %s' % u)
        x = urllib.request.urlopen(u)
        x = np.genfromtxt(x, dtype=t[1::2], delimiter=t[0::2])
        np.save(f, x)
        del(x)
    return np.load(f, mmap_mode='c')


def lsh_cat():
    """
    Lin, Shearer, Hauksson southern California seismicity catalog.
    http://www.rsmas.miami.edu/personal/glin/LSH.html
    """
    import numpy as np
    f = repository + 'LSH-Catalog.npy'
    u = "http://www.rsmas.miami.edu/personal/glin/LSH_files/LSH_1.12"
    t = [
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
    if not os.path.exists(f):
        print('Retrieving %s' % u)
        x = urllib.request.urlopen(u)
        x = np.genfromtxt(x, dtype=t)
        np.save(f, x)
    x = np.load(f, mmap_mode='c')
    return x


def cybershake(isrc, irup, islip=None, ihypo=None, version=(3, 2)):
    """
    Fetch CyberShake SRF sources.

    Must have account on intensity.usc.edu with auto SSH authentication.

    Parameters:

    isrc: source ID
    irup: rupture ID
    islip: slip variation ID
    ihypo: hypocenter ID

    Returns (metadata, data) SRF dictionaries
    """
    import numpy as np
    from . import srf as srflib

    # locations
    v0, v1 = version
    path = repository + 'CyberShake' + os.sep
    host = 'intensity.usc.edu'
    erf = '/home/scec-00/cybershk/reports/'
    srf = (
        '/home/rcf-104/CyberShake2007/ruptures/'
        'RuptureVariations_35_V%d_%d/%d/%d/%d_%d.txt'
    )
    try:
        os.mkdir(path)
    except OSError:
        pass

    # segment name
    for f in 'erf35_source_rups.txt', 'erf35_sources.txt':
        g = path + f
        if not os.path.exists(g):
            print('Retrieving ' + f)
            f = 'scp', host + ':' + erf + f, g
            subprocess.check_call(f)

    # metadata
    f = path + '%1d%1d-%03d-%03d.json' % (v0, v1, isrc, irup)
    if os.path.exists(f):
        meta = json.load(open(f))
    else:
        print('Retrieving ' + os.path.basename(f))
        g = path + 'erf35_sources.txt'
        g = np.loadtxt(g, 'i,S64', delimiter='\t', skiprows=1)
        g = dict(g)[isrc]
        h = srf % (v0, v1, isrc, irup, isrc, irup)
        h = 'ssh', host, 'head -2 %s %s.variation.output' % (h, h)
        h = subprocess.check_output(h).split()
        meta = {
            'segment': g,
            'isrc': isrc,
            'irup': irup,
            'nslip': int(h[18]),
            'nhypo': int(h[20]),
            'magnitude': float(h[8]),
            'probability': float(h[5]),
        }
        json.dump(meta, open(f, 'w'), indent=4, sort_keys=True)
    if ihypo is None:
        return meta
    meta.update({
        'islip': islip,
        'ihypo': ihypo,
    })

    # fetch SRF
    f = '%1d%1d-%03d-%03d-%02d-%02d.srf.gz'
    f = path + f % (v0, v1, isrc, irup, islip, ihypo)
    if os.path.exists(f):
        g = gzip.open(f)
    else:
        print('Retrieving ' + os.path.basename(f))
        g = srf + '.variation-s%04d-h%04d'
        g = g % (v0, v1, isrc, irup, isrc, irup, islip, ihypo)
        g = 'ssh', host, 'gzip -c ' + g
        g = subprocess.check_output(g)
        open(f, 'wb').write(g)
        g = io.BytesIO(g)
        g = gzip.GzipFile(fileobj=g)
    m, data = srflib.read(g)
    m.update(meta)
    return m, data


def download():
    engdahl_cat()
    us_place_names()
    lsh_cat()
    mapdata()
    globe30()
    etopo1()
