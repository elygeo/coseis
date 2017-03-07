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

import numpy as np
from . import home
from . import interp

repository = home + 'repo' + os.sep

# TODO
# Quaternary Fault Database
# ftp://hazards.cr.usgs.gov/maps/qfault/
# http://earthquake.usgs.gov/hazards/qfaults/KML/Quaternaryall.zip


def upsample(f):
    """
    Up-sample a 2D array by a factor of 2 by interpolation.
    """
    n = [f.shape[0] * 2 - 1, f.shape[1] * 2 - 1] + list(f.shape[2:])
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
    n = f.shape
    n = (n[0] + 1) // d, (n[1] + 1) // d
    g = np.zeros(n, f.dtype)
    for k in range(d):
        for j in range(d):
            g += f[j::d, k::d]
    g *= 1.0 / (d * d)
    return g


def clipdata(x, xmin, xmax, lines=1):
    """
    Clip out-of-range data.
    x is data with dimensions (..., n)
    xmin: lower bound with dimensions (n)
    xmax: upper bound with dimensions (n)
    lines:
        0: points, assume no connectivity.
        1: line segments, include one extra point past the boundary.
        -1: line segments, do not include extra point past the boundary.
    """
    x = np.asarray(x)
    xmin = np.asarray(xmin)
    xmax = np.asarray(xmax)
    i = (x >= xmin).min(-1) & (x <= xmax).min(-1)
    if lines:
        if lines > 0:
            i[:-1] = i[:-1] | i[1:]
            i[1:] = i[:-1] | i[1:]
        x[~i] = float('nan')
        i[1:] = i[:-1] | i[1:]
    return x[i], i


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

    coords: (lon, lat)
        If length of lon and lat are 2, they specify the region limits,
        otherwise they specify interpolation points
    scale: Scaling factor for elevation data
    downsample:
        <0: Upsample by factor of 2
        0:  GLOBE 30 sec, with missing data filled by ETOPO1
        1:  ETOPO1 60 sec
        >1: Down-sample factor for ETOPO1
    mesh: return coordinate mesh with topo

    Returns (when given region limits):
        lon, lat, elev: 2D arrays for regular mesh
    Returns (when given interpolation points):
        elev: array of elevation values at the interpolation points
    """
    sample = len(coords) > 2
    if sample:
        coords = np.asarray(coords)
        i = ~np.isnan(coords).max(-1)
        x = coords[..., 0]
        y = coords[..., 1]
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
        return interp.interp2(extent, z, coords)
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
    f = os.path.join(repository, 'Vs30-Wald-%s.npy') % region.replace('_', '-')
    u = 'http://earthquake.usgs.gov/hazards/apps/vs30/downloads/%s.grd.gz'
    if not os.path.exists(f):
        u = u % region
        print('Retrieving %s' % u)
        z = urlopen(u).read()
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


def gshhg(
    kind=None, resolution='high', extent=None, min_area=0.0, min_level=0,
    max_level=4, delta=None
):
    """
    Global Self-consistent, Hierarchical, High-resolution Geography Database
    http://www.soest.hawaii.edu/wessel/gshhg/index.html
    http://www.ngdc.noaa.gov/mgg/shorelines/gshhs.html

    kind: 'coastlines', 'rivers', 'borders', or None
    resolution: 'crude', 'low', 'intermediate', 'high', or 'full'
    extent: (min_lon, max_lon), (min_lat, max_lat)
    delta: densify line segments to given delta.
    clip: clipdata
    min_level, max_level: where levels 1-4 are
        1: coastline
        2: lake shore
        3: island-in-lake shore
        4: lake-in-island-in-lake shore
    Returns N x 2 coordinate array.
    """
    # url = 'http://www.soest.hawaii.edu/pwessel/gshhg/gshhg-bin-2.3.6.zip'
    url = (
        'https://www.ngdc.noaa.gov/mgg/shorelines/'
        'data/gshhg/latest/gshhg-bin-2.3.6.zip'
    )
    d = repository + 'GSHHG'
    if not os.path.exists(d):
        print('Retrieving %s' % url)
        data = urlopen(url)
        data = io.BytesIO(data.read())
        zipfile.ZipFile(data).extractall(d)
    if not kind:
        return
    name = {'c': 'GSHHS coastlines', 'r': 'WDB rivers', 'b': 'WDB borders'}
    name = name[kind[0]]
    kind = {'c': 'gshhs', 'r': 'wdb_rivers', 'b': 'wdb_borders'}[kind[0]]
    if kind != 'gshhs':
        min_area = 0.0
    min_area *= 10
    if extent is not None:
        lon, lat = extent
        lon = lon[0] % 360, lon[1] % 360
        extent = lon, lat
        west, east = 1000000 * lon[0], 1000000 * lon[1]
        south, north = 1000000 * lat[0], 1000000 * lat[1]
    f = os.path.join(repository, 'GSHHG/%s_%s.b' % (kind, resolution[0]))
    data = np.fromfile(f, '>i')
    print('Reading %s resolution %s.' % (resolution, name))
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
        if level > max_level:
            break
        if level < min_level:
            continue
        if hdr[7] < min_area:
            continue
        if extent is not None:
            if (
                hdr[3] > east or hdr[5] > north or
                hdr[4] < west or hdr[6] < south
            ):
                continue
        x = 1e-6 * data[ii-2*n:ii].reshape(n, 2).astype('f')
        if delta:
            x = densify(x, delta)
        xx.append(x)
    return xx
    #     if extent is not None and clip != 0:
    #         if delta:
    #             x = clipdata(x, extent, 1)[:2]
    #             x = densify(x, delta)
    #         x = clipdata(x, extent, clip)[:2]
    #     elif delta:
    #         x = densify(x, delta)
    #     xx += [x, [float('nan')]]
    # if nkeep:
    #     xx = np.concatenate(xx)[:-1]
    # return xx


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
        x = np.genfromtxt(x, dtype=t[1::2], delimiter=t[0::2])
        np.save(f, x)
        del(x)
    return np.load(f, mmap_mode='c')


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
        x = np.genfromtxt(x, dtype=t)
        np.save(f, x)
    x = np.load(f, mmap_mode='c')
    return x


def cybershake(isrc, irup, islip=None, ihypo=None, version=(3, 2)):
    """
    CyberShake SRF sources.
    Must have account on intensity.usc.edu with auto SSH authentication.
    isrc: source ID
    irup: rupture ID
    islip: slip variation ID
    ihypo: hypocenter ID
    """
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
    print('Downloading all data sets')
    engdahl_cat()
    lsh_cat()
    gshhg()
    globe30()
    etopo1()


if __name__ == '__main__':
    download()
