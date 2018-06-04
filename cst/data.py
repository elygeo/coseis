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

try:
    from urllib.request import urlopen
except ImportError:
    from urllib2 import urlopen

import numpy
from . import home
from . import interp

repository = home + 'repo' + os.sep

# TODO
# Quaternary Fault Database
# ftp://hazards.cr.usgs.gov/maps/qfault/
# http://earthquake.usgs.gov/hazards/qfaults/KML/Quaternaryall.zip


def upsample2(x):
    """
    Up-sample a 2D array by a factor of 2 by interpolation.
    Result is scaled by a factor of 4.
    """
    n = [x.shape[0] * 2 - 1, x.shape[1] * 2 - 1] + list(x.shape[2:])
    y = numpy.empty(n, x.dtype)
    y[0::2, 0::2] = 4 * x
    y[0::2, 1::2] = 2 * (x[:, :-1] + x[:, 1:])
    y[1::2, 0::2] = 2 * (x[:-1, :] + x[1:, :])
    y[1::2, 1::2] = x[:-1, :-1] + x[1:, 1:] + x[:-1, 1:] + x[1:, :-1]
    return y


def upsample3(x):
    """
    Up-sample a 2D array by a factor of 3 by interpolation.
    Result is scaled by a factor of 9.
    """
    n = [x.shape[0] * 3 - 2, x.shape[1] * 3 - 2] + list(x.shape[2:])
    y = numpy.empty(n, x.dtype)
    y[0::3, 0::3] = 9 * x
    y[0::3, 1::3] = 6 * x[:, :-1] + 3 * x[:, 1:]
    y[0::3, 2::3] = 6 * x[:, 1:] + 3 * x[:, :-1]
    y[1::3, 0::3] = 6 * x[:-1, :] + 3 * x[1:, :]
    y[2::3, 0::3] = 6 * x[1:, :] + 3 * x[:-1, :]
    y[1::3, 1::3] = 4 * x[:-1, :-1] + x[1:, 1:] + 2 * (x[:-1, 1:] + x[1:, :-1])
    y[1::3, 2::3] = 4 * x[:-1, 1:] + x[1:, :-1] + 2 * (x[:-1, :-1] + x[1:, 1:])
    y[2::3, 1::3] = 4 * x[1:, :-1] + x[:-1, 1:] + 2 * (x[1:, 1:] + x[:-1, :-1])
    y[2::3, 2::3] = 4 * x[1:, 1:] + x[:-1, :-1] + 2 * (x[1:, :-1] + x[:-1, 1:])
    return y


def downsample(x, d):
    """
    Down-sample a 2D array by a factor d, with averaging.
    Result is scaled by a factor of d squared.
    """
    n = x.shape
    n = (n[0] + 1) // d, (n[1] + 1) // d
    y = numpy.zeros(n, x.dtype)
    for k in range(d):
        for j in range(d):
            y += x[j::d, k::d]
    return y


def clipdata(x, bounds, overshoot=True, inside=False, separator=None):
    """
    Clip data outside the bounds.
    x: data with dimensions (n, ...)
    bounds: lower and upper bound with dimensions (n, 2)
    overshoot: include one adjacent point outside the bounds.
    inside: clip data inside the bounds rather than outside.
    separator: value to insert at clip boundaries.
    """
    xmin, xmax = numpy.asarray(bounds).T
    x = numpy.asarray(x).T
    if inside:
        i = (x <= xmin).max(-1) | (x >= xmax).max(-1)
    else:
        i = (x >= xmin).min(-1) & (x <= xmax).min(-1)
    if overshoot:
        i[:-1] = i[:-1] | i[1:]
        i[1:] = i[:-1] | i[1:]
    if separator is not None:
        x[~i] = separator
        i[1:] = i[:-1] | i[1:]
    return x[i].T


def densify(xy, delta):
    """
    Piecewise up-sample line segments with spacing delta. Not appropriate for
    geographic coordinates at high latitude with large delta (does not trace
    great-circle arc).
    """
    if len(xy) <= 1:
        return xy
    x, y = xy[0]
    xxyy = [(x, y)]
    for x1, y1 in xy[1:]:
        dx = x1 - x
        dy = y1 - y
        if dx == dx and dy == dy:  # not NaN
            n = int(math.sqrt(dx * dx + dy * dy) / delta)
            dx /= (n + 1)
            dy /= (n + 1)
            for i in range(n):
                x += dx
                y += dy
                xxyy.append((x, y))
        x, y = x1, y1
        xxyy.append((x, y))
    return xxyy


def simplify(points, closepath=False, max_area=0):
    """
    Remove vertices from a line starting with the smallest vertex area until
    max_area is reached (Visvalingam's algorithm). Vertex area is that of the
    triangle formed by a vertex with it's two neighbors. The closepath
    parameter indicates that the endpoints are connected to form a polygon.
    """
    p = list(points)
    area = max_area * max_area
    n = len(p)
    m = 1
    if closepath:
        m = 0
    while n > m + m:
        amin = area
        imin = None
        for i in range(m, n - m):
            j = (i - 1) % n
            k = (i + 1) % n
            a = ((p[j][0] - p[i][0]) * (p[k][1] - p[i][1]))
            a -= ((p[j][1] - p[i][1]) * (p[k][0] - p[i][0]))
            a = a * a
            if a <= amin:
                amin = a
                imin = i
        if imin is None:
            break
        p.pop(imin)
        n -= 1
    return p


def simplify_indexed(points, indices, closepath=False, max_area=0):
    p = points
    indices = list(indices)
    area = max_area * max_area
    n = len(indices)
    m = 1
    if closepath:
        m = 0
    while n > m + m:
        amin = area
        imin = None
        for i in range(m, n - m):
            j = indices[(i - 1) % n]
            k = indices[(i + 1) % n]
            a = ((p[j][0] - p[i][0]) * (p[k][1] - p[i][1]))
            a -= ((p[j][1] - p[i][1]) * (p[k][0] - p[i][0]))
            a = a * a
            if a <= amin:
                amin = a
                imin = i
        if imin is None:
            break
        indices.pop(imin)
        n -= 1
    return indices


def downsample_sphere(f, d):
    """
    Down-sample node-registered spherical surface with averaging. The indices
    of the 2D array f are longitude and latitude. d is the decimation interval
    which should be odd to preserve nodal registration.
    """
    if d == 1:
        return f
    assert(d % 2 == 1)
    f = numpy.asarray(f)
    m, n = f.shape[:2]
    i = numpy.arange(d) - (d - 1) // 2
    jj = numpy.arange(0, m, d)
    kk = numpy.arange(0, n, d)
    g = numpy.zeros([jj.size, kk.size], f.dtype)
    jj, kk = numpy.ix_(jj, kk)
    for dk in i:
        k = n - 1 - abs(n - 1 - abs(dk + kk))
        for dj in i:
            j = (jj + dj) % m
            g = g + f[j, k]
    if g.dtype.kind == 'i':
        g[:, 0] = g[:, 0].mean() + 0.5
        g[:, -1] = g[:, -1].mean() + 0.5
    else:
        g[:, 0] = g[:, 0].mean()
        g[:, -1] = g[:, -1].mean()
    return g


def etopo1(downsample=1):
    """
    ETOPO1 Global Relief Model.
    http://www.ngdc.noaa.gov/mgg/global/global.html
    """
    f = repository + 'DEM0060.npy'
    g = repository + 'DEM%04d.npy' % (60 * downsample)
    u = (
        'http://www.ngdc.noaa.gov/mgg/global/relief/ETOPO1/data/'
        'ice_surface/grid_registered/binary/etopo1_ice_g_i2.zip'
    )
    n = 10801, 21601
    if not os.path.exists(f):
        print('Retrieving %s' % u)
        z = urlopen(u)
        z = io.BytesIO(z.read())
        z = zipfile.ZipFile(z)
        z = z.read('etopo1_ice_g_i2.bin')
        z = numpy.fromstring(z, '<i2').reshape(n).T[:, ::-1]
        print('Creating %s' % f)
        numpy.save(f, z)
    if not os.path.exists(g):
        z = numpy.load(f, mmap_mode='c')
        if downsample > 1:
            z = downsample_sphere(z, downsample)
            d = downsample * downsample
            z += d // 2
            z //= d
        print('Creating %s' % g)
        numpy.save(g, z)
    z = numpy.load(g, mmap_mode='c')
    return z


def globe30(tile=(0, 1), fill=True):
    """
    Retrieve Global Land One-km Base Elevation DEM.
    Missing bathymetry is optionally filled with ETOPO1.
    http://www.ngdc.noaa.gov/mgg/topo/globe.html
    tile: 90 x 90 degree tile indices:
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
            f = urlopen(u)
            f = io.BytesIO(f.read())
            z += gzip.GzipFile(fileobj=f).read()
        z = numpy.fromstring(z, '<i2').reshape(shape).T[:, ::-1]
        if fill:
            m = shape[0] // 2
            n = shape[1] // 2
            j = slice(tile[0] * n, tile[0] * n + n + 1)
            k = slice(tile[1] * m, tile[1] * m + m + 1)
            x = etopo1()[j, k]
            y = numpy.empty_like(z)
            x00 = x[:-1, :-1]
            x01 = x[:-1, 1:]
            x10 = x[1:, :-1]
            x11 = x[1:, 1:]
            y[0::2, 0::2] = 9 * x00 + x11 + 3 * (x01 + x10)
            y[0::2, 1::2] = 9 * x01 + x10 + 3 * (x00 + x11)
            y[1::2, 0::2] = 9 * x10 + x01 + 3 * (x11 + x00)
            y[1::2, 1::2] = 9 * x11 + x00 + 3 * (x10 + x01)
            del(x)
            i = z == -500
            z[i] = (y[i] + 8) // 16
            del(y, i)
        print('Creating %s' % filename)
        numpy.save(filename, z)
        del(z)
    return numpy.load(filename, mmap_mode='c')


def dem(coords, downsample=0):
    """
    Extract digital elevation model for given region.

    coords: (lon, lat)
        If length of lon and lat are 2, they specify the region limits,
        otherwise they specify interpolation points
    downsample:
        <0: Upsample by factor of 2. Elevation scaled by 4
        0:  GLOBE 30 sec, with missing data filled by ETOPO1
        1:  ETOPO1 60 sec
        >1: Down-sample factor for ETOPO1

    Returns (when given region limits):
        lon, lat, elev: 2D arrays for regular mesh
    Returns (when given interpolation points):
        elev: array of elevation values at the interpolation points
    """
    x, y = numpy.asarray(coords)
    sample = x.size > 2 or y.size > 2
    if sample:
        i = ~(numpy.isnan(x) | numpy.isnan(y))
        xlim = x[i].min(), x[i].max()
        ylim = y[i].min(), y[i].max()
    else:
        xlim, ylim = coords
    if downsample > 0:
        res = 60 // downsample
        x0, y0 = -180, -90
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
        while downsample < -1:
            if downsample % 3 == 0:
                downsample //= 3
                z = upsample3(z / 9.0)
                res *= 3
            elif downsample % 2 == 0:
                downsample //= 2
                z = upsample2(z * 0.25)
                res *= 2
    if sample:
        return interp.interp2(extent, z, coords)
    else:
        delta = 1.0 / res
        n = z.shape
        x = xlim[0] + delta * numpy.arange(n[0])
        y = ylim[0] + delta * numpy.arange(n[1])
        x, y = numpy.meshgrid(x, y, indexing='ij')
        return (x, y, z)


def vs30_wald(x, y, mesh=False, region='Western_US', method='nearest'):
    """
    Wald, et al. Vs30 map.
    """
    raise Exception('File moved. Needs update.')
    # new file: 'ftp://hazards.cr.usgs.gov/web/data/global_vs30_grd.zip'
    f = os.path.join(repository, 'Vs30-Wald-%s.npy') % region.replace('_', '-')
    u = 'http://earthquake.usgs.gov/hazards/apps/vs30/downloads/%s.grd.gz'
    if not os.path.exists(f):
        u = u % region
        print('Retrieving %s' % u)
        z = urlopen(u).read()
        z = io.BytesIO(z)
        z = gzip.GzipFile(fileobj=z).read()[19512:]
        z = numpy.fromstring(z, '>f').reshape((2400, 2280)).T
        numpy.save(f, z)
    x = numpy.asarray(x)
    y = numpy.asarray(y)
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
    z = numpy.load(f, mmap_mode='c')[j0:j1+1, k0:k1+1]
    if sample:
        z = interp.interp2(extent, z, (x, y), method=method)
        return z
    elif mesh:
        n = z.shape
        x = xlim[0] + delta * numpy.arange(n[0])
        y = ylim[0] + delta * numpy.arange(n[1])
        y, x = numpy.meshgrid(y, x)
        return (x, y, z)
    else:
        return extent, z


def gshhg(
    kind=None, resolution='high', extent=None, area=-1, levels=[], delta=None
):
    """
    Global Self-consistent, Hierarchical, High-resolution Geography Database
    http://www.soest.hawaii.edu/wessel/gshhg/index.html
    http://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html

    kind: coastlines, rivers, borders, or None
    resolution: 'crude', 'low', 'intermediate', 'high', or 'full'
    extent: (west, east lon), (south, north lat)
    area: minimum area in 1/10 km^2
    levels: list of levels to include
        1: land
        2: lake
        3: island-in-lake
        4: pond-in-island-in-lake
        5: Antarctic ice-front
        6: Antarctic grounding-line
    delta: densify line segments to given delta.
    Returns list of (2, n) shape coordinate array in micro-degrees
    """
    # url = 'http://www.soest.hawaii.edu/pwessel/gshhg/gshhg-bin-2.3.6.zip'
    url = (
        'https://www.ngdc.noaa.gov/mgg/shorelines/'
        'data/gshhg/latest/gshhg-bin-2.3.7.zip'
http://www.soest.hawaii.edu/pwessel/gshhg/gshhg-bin-2.3.7.zip
    )
    d = repository + 'GSHHG'
    if not os.path.exists(d):
        print('Retrieving %s' % url)
        data = urlopen(url)
        data = io.BytesIO(data.read())
        zipfile.ZipFile(data).extractall(d)
    if not kind:
        return
    break_level0 = -1
    break_level1 = -1
    if 'coastlines'.startswith(kind):
        kind = 'gshhs'
        for i in levels:
            if i > break_level0 and i not in [5, 6]:
                break_level0 = i
        break_level1 = 4
        # workaround for improperly sorted data in GSHHG
        if resolution[0] == 'f' and break_level0 == 2:
            break_level0 = 3
    elif 'rivers'.startswith(kind):
        kind = 'wdb_rivers'
    elif 'borders'.startswith(kind):
        kind = 'wdb_borders'
        for i in levels:
            if i > break_level0:
                break_level0 = i
        break_level1 = 13
    else:
        raise Exception
    if extent is not None:
        (west, east), (south, north) = extent
        west = 1000000 * (west % 360)
        east = 1000000 * (east % 360)
        south *= 1000000
        north *= 1000000
    f = os.path.join(repository, 'GSHHG/%s_%s.b' % (kind, resolution[0]))
    data = numpy.fromfile(f, '>i')
    xx = []
    ii = 0
    nhead = 11
    ntotal = 0
    while ii < data.size:
        ntotal += 1
        hdr = data[ii:ii+nhead]
        n = hdr[1]
        ii += nhead + 2 * n
        level = hdr[2:3].view('i1')[3]
        if levels and level not in levels:
            if level > break_level0 and level <= break_level1:
                break
            continue
        if hdr[7] <= area:
            continue
        if extent is not None:
            if (
                hdr[3] > east or hdr[5] > north or
                hdr[4] < west or hdr[6] < south
            ):
                continue
        x = data[ii-2*n:ii].reshape(n, 2)
        if delta:
            x = densify(x, delta)
        xx.append(x.T)
    return xx


def engdahl_cat():
    """
    Engdahl Centennial Earthquake Catalog
    http://earthquake.usgs.gov/data/centennial/
    """
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
        x = urlopen(u)
        x = numpy.genfromtxt(x, dtype=t[1::2], delimiter=t[0::2])
        numpy.save(f, x)
        del(x)
    return numpy.load(f, mmap_mode='c')


def lsh_cat():
    """
    Lin, Shearer, Hauksson southern California seismicity catalog
    http://www.rsmas.miami.edu/personal/glin/LSH.html
    """
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
        x = urlopen(u)
        x = numpy.genfromtxt(x, dtype=t)
        numpy.save(f, x)
    x = numpy.load(f, mmap_mode='c')
    return x


def download():
    print('Downloading all data sets')
    engdahl_cat()
    lsh_cat()
    gshhg()
    globe30()
    etopo1()


if __name__ == '__main__':
    download()
