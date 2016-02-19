#!/usr/bin/env python3
"""
SCEC Community Fault Model (CFM) tools.
"""

# projection: UTM zone 11, NAD 1927 datum (implies Clark 1866 geoid)
projection = {'proj': 'utm', 'zone': 11, 'datum': 'NAD27'}
repo = os.path.join('..', 'Repository')


def catalog(version='CFM4-socal-primary'):
    """
    Return a dictionary of available faults. The dictionary key:value pair is
    the fault name and number of segments. The CFM database is downloaded if
    not already present.
    """
    import os
    import urllib
    import zipfile
    import numpy as np
    from . import gocad

    url = 'http://structure.harvard.edu/cfm/download/vdo/SCEC_VDO.jar'
    path = os.path.join(repo, 'CFM4', version) + os.sep

    if not os.path.exists(path):
        f = os.path.join(repo, 'SCEC-VDO.jar')
        if not os.path.exists(f):
            print('Downloading %s' % url)
            urllib.urlretrieve(url, f)
        zp = zipfile.ZipFile(f)
        src = os.path.join('data', 'Faults', version)
        os.makedirs(path)
        for f in zp.namelist():
            base, key = os.path.split(f)
            if base != src or not key.endswith('.ts'):
                continue
            key = key[:-3]
            tsurf = gocad.tsurf(zp.read(f))
            if len(tsurf) > 1:
                raise Exception('Not expecting more than 1 tsurf')
            data = tsurf[0][1]
            np.savez(path + key + '.npz', **data)
    cat = sorted(i[:-4] for i in os.listdir(path) if i.endswith('.npz'))

    return cat


def tree():
    import json
    tree = {}
    for f, n in catalog():
        k = f.split('-', 3)
        node = tree
        for i in range(3):
            if k[i] not in node:
                node[k[i]] = {}
            node = node[k[i]]
        node[k[-1]] = ''
    json.dumps(tree, indent=4, sort_keys=True)
    return


def search(items, split=1, maxsplit=3):
    import os

    # search the catalog
    cat = catalog()
    if items == []:
        match = cat
        prefix = []
        n = 0
    else:
        match = set()
        if type(items) == str:
            items = [items]
        for a in items:
            b = a.split(':')[0].lower()
            if b.endswith('.npz'):
                b = b[:-4]
            for c in cat:
                if b in c.lower():
                    match.add(c)
        match = sorted(match)
        if len(match) == 1:
            return match[0].split('-'), match[0]
        prefix = os.path.commonprefix(match).split('-')[:-1]
        n = len(prefix)

    # split into groups
    n += split
    if n == 0:
        return prefix, [('', match)]
    elif n > maxsplit:
        return prefix, match
    groups = {}
    for a in match:
        k = '-'.join(a.split('-', n)[:n])
        if k not in groups:
            groups[k] = [a]
        else:
            groups[k].append(a)
    groups = groups.items()

    # use fault names for single length groups
    n = 1
    for i, s in enumerate(groups):
        n = max(len(s[1]), n)
    if n == 1:
        for i, s in enumerate(groups):
            groups[i] = s[1][0]

    return prefix, groups


def read(fault, version='CFM4-socal-primary'):
    """
    Read triangulated surface data.
    """
    import os
    import numpy as np
    path = os.path.join(repo, 'CFM4', version) + os.sep
    f, i = (fault + ':').split(':')[:2]
    d = np.load(path + f + '.npz')
    x = d['vtx']
    t = d['tri']
    b = d['border']
    s = d['bstone']
    d.close()
    if i:
        t = [t[int(j)] for j in i.split(',')]
    return x, t, b, s


def tsurf_merge(tsurfs, fuse=-1.0, cull=-1.0, clean=True):
    """
    Merge multiple triangulated surfaces

    fuse (float): separation tolerance for combining vertices.
    cull (float): area tolerance for triangle removal.
    clean (bool): remove unused vertices.
    """
    import numpy as np

    # merge surfaces
    n = 0
    vtx, tri = [], []
    for x, t, b, s in tsurfs:
        t = np.vstack(t) + n
        n += x.shape[0]
        vtx.append(x)
        tri.append(t)
    vtx = np.vstack(vtx)
    tri = np.vstack(tri)

    # remove small triangles
    if cull >= 0.0:
        x, y, z = vtx.T
        j, k, l = tri.T
        ux = x[k] - x[j]
        uy = y[k] - y[j]
        uz = z[k] - z[j]
        vx = x[l] - x[j]
        vy = y[l] - y[j]
        vz = z[l] - z[j]
        wx = uy * vz - uz * vy
        wy = uz * vx - ux * vz
        wz = ux * vy - uy * vx
        r = wx * wx + wy * wy + wz * wz
        i = r > cull * cull
        tri = tri[i]

    # merge nearby points
    if fuse >= 0.0:
        tol = fuse * fuse
        i, j = np.unique(tri, return_inverse=True)
        tri = np.arange(tri.size)[j].reshape(tri.shape)
        vtx = vtx[i]
        for j in range(len(i)):
            x = vtx[j, 0] - vtx[j+1:, 0]
            y = vtx[j, 1] - vtx[j+1:, 1]
            z = vtx[j, 2] - vtx[j+1:, 2]
            for k in (x * x + y * y + z * z < tol).nonzero()[0]:
                tri[tri == (j + 1 + k)] = j

    # remove unused vertices
    if clean:
        i, j = np.unique(tri, return_inverse=True)
        tri = np.arange(tri.size)[j].reshape(tri.shape)
        vtx = vtx[i]

    return vtx.T, tri.T


def tsurf_edges(tri):
    """
    Find the boundary polygons of a triangulation.
    """

    # triangle list -> triangle node tree
    surf = {i: set() for i in set(tri.flat)}
    for j, k, l in tri.T:
        surf[j] |= set([k, l])
        surf[k] |= set([l, j])
        surf[l] |= set([j, k])
    del(tri)

    # triangle node tree -> edge node tree
    # boundary segments occur only once
    edge = {}
    for i in surf:
        for j in surf[i]:
            if len(surf[i] & surf[j]) == 1:
                if i not in edge:
                    edge[i] = set()
                edge[i].add(j)
    del(surf)

    # edge node tree -> edge list
    line = []
    while edge:
        j = sorted(edge)[0]
        l = [j]
        while edge[j]:
            i = j
            j = sorted(edge[i])[0]
            l.append(j)
            edge[j].remove(i)
            edge[i].remove(j)
            if not edge[i]:
                edge.pop(i)
        edge.pop(j)
        line.append(l)

    return line


def tsurf_plane(vtx, tri):
    """
    Find the center of mass, best-fit plane, and total surface area of a
    triangulated surface.
    """
    import math
    import numpy as np
    import scipy.optimize

    # area normals
    x, y, z = vtx
    j, k, l = tri
    ux = x[k] - x[j]
    uy = y[k] - y[j]
    uz = z[k] - z[j]
    vx = x[l] - x[j]
    vy = y[l] - y[j]
    vz = z[l] - z[j]
    wx = uy * vz - uz * vy
    wy = uz * vx - ux * vz
    wz = ux * vy - uy * vx

    # center of mass
    a = 0.5 * np.sqrt(wx * wx + wy * wy + wz * wz)
    area = float(a.sum())
    d = 1.0 / (3.0 * area)
    x = d * float(((x[j] + x[k] + x[l]) * a).sum())
    y = d * float(((y[j] + y[k] + y[l]) * a).sum())
    z = d * float(((z[j] + z[k] + z[l]) * a).sum())
    center = x, y, z

    # plane misfit function
    def misfit(plane):
        phi, theta = plane
        x = math.cos(theta) * math.cos(phi)
        y = math.cos(theta) * math.sin(phi)
        z = math.sin(theta)
        return -abs(x * wx + y * wy + z * wz).sum()

    # best fit plane
    phi, theta = scipy.optimize.fmin(misfit, (0.0, 0.0), disp=False)
    x = math.cos(theta) * math.cos(phi)
    y = math.cos(theta) * math.sin(phi)
    z = math.sin(theta)
    if z < 0.0:
        x, y, z = -x, -y, -z
    normal = x, y, z

    return center, normal, area


def geometry(vtx, tri):
    """
    Compute various geometrical properties:
    centroid_lat: center of mass latitude
    centroid_lon: center of mass longitude
    centroid_x: UTM X meters
    centroid_y: UTM Y meters
    centroid_z: Depth meters
    strike: Fault strike
    dip: Fault dip
    area: Total surface area
    """
    import math
    import pyproj

    proj = pyproj.Proj(**projection)
    centroid, normal, area = tsurf_plane(vtx, tri)
    x0, y0, z0 = centroid
    x, y, z = normal
    r = math.sqrt(x * x + y * y) / z
    dip = math.atan(r) / math.pi * 180.0
    x = x0, x0 - x, x0 + x
    y = y0, y0 - y, y0 + y
    x, y = proj(x, y, inverse=True)
    lon, lat = x[0], y[0]
    x = 0.5 * (x[2] - x[1]) * math.cos(lat / 180.0 * math.pi)
    y = 0.5 * (y[2] - y[1])
    strike = (math.atan2(-y, x) / math.pi * 180.0) % 360.0

    # data dictionary
    meta = {
        'centroid_lat': lat,
        'centroid_lon': lon,
        'centroid_x': x0,
        'centroid_y': y0,
        'centroid_z': z0,
        'strike': strike,
        'dip': dip,
        'area': area,
    }

    return meta


def quad_mesh(vtx, tri, delta, drape=False, clean_top=False):
    """
    Quadrilateral mesh from triangular mesh.

    Coordinate transform:

          | a -b 0 |
    M =   | b  a c |
          | 0  0 d |

          |  a b -bc/d     |
    1/M = | -b a -ac/d     | / (aa + bb)
          |  0 0 (aa+bb)/d |
    """
    import math
    import numpy as np
    from . import data, trinterp

    # remove topography
    x, y, z = vtx
    del(vtx)
    if drape:
        import pyproj
        proj = pyproj.Proj(**projection)
        lon, lat = proj(x, y, inverse=True)
        z = data.dem([lon, lat]) - z
        del(lon, lat)

    # get plane orientation
    centroid, normal = tsurf_plane([x, y, z], tri)[:2]
    if normal[2] > 0.9:
        raise Exception('Near-flat tsurf not meshable')

    # Cartesian to logical coordinates
    x = x - centroid[0]
    y = y - centroid[1]
    r = 1.0 / delta
    a = r * normal[1]
    b = r * normal[0]
    c = r * normal[2]
    d = r / (1.0 - normal[2])
    xi = a * x - b * y
    yi = b * x + a * y + c * z
    zi = d * z

    # quad mesh
    x = math.ceil(xi.min()), math.floor(xi.max())
    z = math.ceil(zi.min()), math.floor(zi.max())
    x = np.arange(x[0], x[1] + 1)
    z = np.arange(z[0], z[1] + 1)
    z, x = np.meshgrid(z, x)
    y = trinterp.trinterp([xi, zi], yi, tri, [x, z])
    del(xi, yi, zi, tri)
    mask = np.isnan(y)
    y[mask] = y[~mask].mean()

    # cleanup surface trace
    if clean_top:
        y[:, 0] = 2.0 * y[:, 1] - y[:, 2]

    # logical to Cartesian coordinates
    r = delta / (normal[0] ** 2 + normal[1] ** 2)
    a = r * normal[1]
    b = r * normal[0]
    ac = r * normal[1] * normal[2] * (1.0 - normal[2])
    bc = r * normal[0] * normal[2] * (1.0 - normal[2])
    d = delta * (1.0 - normal[2])
    xi = a * x + b * y - bc * z
    yi = -b * x + a * y - ac * z
    zi = d * z
    xi += centroid[0]
    yi += centroid[1]

    return xi, yi, zi, mask


def line_simplify(vtx, indices, area=None, nkeep=None):
    """
    Remove detail from a line or polygon beginning with the least significant
    vertices using Visvalingam's algorithm. Vertex significance is determined
    by the triangle area formed by a point and it's neighbors.

    Parameters:
    vtx: vertex coordinates.
    indices: indices of vtx for the line or polygon.
    area: maximum triangle area for vertex removal.
    nkeep: minimum number of vertices to keep.

    If the first and last indices match, then the line is assumed to be a
    closed polygon. If neither area nor nkeep are given, then half of the
    indices are removed. If both area and nkeep are given, priority is given to
    case that retains more detail.
    """
    import numpy as np
    if nkeep is None:
        if area:
            nkeep = 3
        else:
            nkeep = max(3, len(indices) // 2)
    x, y = vtx[:2]
    polygon = indices[0] == indices[-1]
    if polygon:
        j = list(indices[:-1])
    else:
        j = list(indices)
    del(vtx, indices)
    while len(j) >= nkeep:
        k = j[1:] + j[:1]
        l = j[-1:] + j[:-1]
        a = ((x[k] - x[j]) * (y[l] - y[j]))
        a -= ((y[k] - y[j]) * (x[l] - x[j]))
        a = a * a
        if polygon:
            i = np.argmin(a)
        else:
            i = np.argmin(a[1:-1]) + 1
        if area and a[i] > area:
            break
        j.pop(i)
    if len(j) == 2:
        j = []
    elif polygon:
        j = j + j[:1]
    return j


def cubit_facet(vtx, tri, geographic=True):
    """
    Create CUBIT Facet File text representation
    """
    x, y, z = vtx
    j, k, l = tri

    if geographic:
        import pyproj
        proj = pyproj.Proj(**projection)
        x, y = proj(x, y, inverse=True)

    out = '%s %s\n' % (x.size, j.size)
    for i in range(x.size):
        out += '%s %s %s %s\n' % (i, x[i], y[i], z[i])
    for i in range(j.size):
        out += '%s %s %s %s\n' % (i, j[i], k[i], l[i])

    return out


def explore(prefix, faults):
    """
    # CFMX: Community Fault Model Explorer

    A simple tool for exploring the CFM

    ## Keyboard Controls

    Fault selection                  [ ]
    Fault selection and view         { }
    Clear fault selection              \\
    Rotate the view               Arrows
    Pan the view            Shift-Arrows
    Zoom the view                    - =
    Reset view                         0
    Toggle stereo view                 3
    Save a screen-shot                 S
    Help                             h ?
    """
    import os
    import numpy as np
    from . import data, interp

    # parameters
    extent = (-122.0, -114.0), (31.5, 37.5)
    resolution = 'high'
    view_azimuth = -90
    view_elevation = 45
    view_angle = 15
    color_bg = 1.0, 1.0, 0.0
    color_hl = 1.0, 0.0, 0.0

    # check
    if not faults:
        print('No faults found')
        return
    single_fault = isinstance(faults, str)

    # projection
    import pyproj
    proj = pyproj.Proj(**projection)

    # setup figure
    from enthought.mayavi import mlab
    s = 'SCEC Community Fault Model'
    if prefix:
        s = [s] + [fault_names[i][k] for i, k in enumerate(prefix[:3])]
        if single_fault:
            s += [prefix[3].replace('_', ' ')]
        s = ', '.join(s)
    print('\n%s\n' % s)
    fig = mlab.figure(bgcolor=(1, 1, 1), fgcolor=(0, 0, 0), size=(1280, 720))
    fig.name = s
    fig.scene.disable_render = True

    # DEM
    f = os.path.join(repo, 'CFM4', 'dem.npy')
    if os.path.exists(f):
        x, y, z = np.load(f)
    else:
        x, y, z = data.dem(extent, mesh=True)
        extent = (x.min(), x.max()), (y.min(), y.max())
        x, y = proj(x, y)
        np.save(f, [x, y, z])
    mlab.mesh(x, y, z, color=(1, 1, 1), opacity=0.3)

    # base map
    f = os.path.join(repo, 'CFM4', 'mapdata.npy')
    if os.path.exists(f):
        x, y, z = np.load(f)
    else:
        ddeg = 0.5 / 60.0
        x, y = np.c_[
            data.mapdata('coastlines', resolution, extent, 10.0, delta=ddeg),
            [float('nan'), float('nan')],
            data.mapdata('borders', resolution, extent, delta=ddeg),
        ]
        x -= 360.0
        z = interp.interp2(extent, z, (x, y))
        x, y = proj(x, y)
        i = np.isnan(z)
        x[i] = float('nan')
        y[i] = float('nan')
        np.save(f, [x, y, z])
    mlab.plot3d(x, y, z, color=(0, 0, 0), line_width=1, tube_radius=None)
    mlab.view(view_azimuth, view_elevation)
    fig.scene.camera.view_angle = view_angle
    fig.scene.disable_render = False
    fig.scene.disable_render = True

    # read fault surfaces
    tsurfs = []
    if single_fault:
        f, s = (faults + ':').split(':')[:2]
        x, t = read(f)[:2]
        if s:
            for i in s.split(','):
                tsurfs.append(('%s:%s' % (f, i), x.T, t[int(i)].T))
        else:
            for i, j in enumerate(t):
                tsurfs.append(('%s:%s' % (f, i), x.T, j.T))
    else:
        for f in faults:
            if type(f) == str:
                x, t = tsurf_merge(read(f))
            else:
                f, s = f
                x, t = tsurf_merge(read(i) for i in s)
            tsurfs.append((f, x, t))

    # plot fault surfaces
    surfs = []
    for isurf, f in enumerate(tsurfs):
        name, vtx, tri = f
        print(name)
        m = geometry(vtx, tri)
        x, y, z = vtx
        s = [
            'Mean Strike:   %10.5f deg' % m['strike'],
            'Mean Dip:      %10.5f deg' % m['dip'],
            'Centroid Lon:  %10.5f deg' % m['centroid_lon'],
            'Centroid Lat:  %10.5f deg' % m['centroid_lat'],
            'Centroid Elev: %10d m' % m['centroid_z'],
            'Min Elevation: %10d m' % z.min(),
            'Max Elevation: %10d m' % z.max(),
            'Surface Area:  %10d km^2' % (m['area'] * 0.000001),
        ]
        k = name.split('-', 3)
        s += [fault_names[i][a] for i, a in enumerate(k[:3])]
        if k[3:]:
            s += [k[3].replace('_', ' ')]
        s += [name]
        p = mlab.triangular_mesh(
            x, y, z, tri.T,
            representation='surface',
            color=color_bg,
        ).actor.actor.property
        i = m['centroid_lon']
        u = m['centroid_x'], m['centroid_y'], m['centroid_z']
        if single_fault:
            surfs.append((isurf, u, s, p))
        else:
            surfs.append((i, u, s, p))
    surfs = [i[1:] for i in sorted(surfs)]

    # handle key press
    def on_key_press(obj, event, save=[0]):
        k = obj.GetKeyCode()
        isurf = save[0]
        fig.scene.disable_render = True
        if k in '[]{}':
            c, s, p = surfs[isurf]
            if p.color == color_bg:
                p.color = color_hl
            else:
                p.color = color_bg
                d = {'[': -1, ']': 1, '{': -1, '}': 1}[k]
                isurf = (isurf + d) % len(surfs)
                c, s, p = surfs[isurf]
                p.color = color_hl
            print('\n' + '\n'.join(s))
            if k in '{}':
                mlab.view(focalpoint=c)
        elif k == '\\':
            surfs[isurf][-1].color = color_bg
        elif k == '0':
            mlab.view(view_azimuth, view_elevation)
            fig.scene.camera.view_angle = view_angle
        elif k in '/?h':
            from .cfm import explore
            print(explore.__doc__)
        fig.scene.disable_render = False
        save[0] = isurf
        return

    # finish up
    fig.scene.interactor.add_observer('KeyPressEvent', on_key_press)
    mlab.view(view_azimuth, view_elevation)
    fig.scene.camera.view_angle = view_angle
    fig.scene.disable_render = False
    print('\nPress H in the figure window for help.')
    mlab.show()
    return


def main():
    import sys
    import getopt
    opts, argv = getopt.getopt(sys.argv[1:], 's:')
    opts = dict(opts)
    if '-s' in opts:
        split = int(opts['-s'])
        prefix, faults = search(argv, split)
    else:
        prefix, faults = search(argv)
    explore(prefix, faults)


fault_names = [{
    'BNRA': 'Basin and Range Fault Area',
    'CRFA': 'Coast Ranges Fault Area',
    'ETRA': 'Eastern Transverse Ranges',
    'GRFS': 'Garlock Fault System',
    'GVFA': 'Great Valley Fault Area',
    'MJVA': 'Mojave Fault Area',
    'OCBA': 'Offshore Continental Borderland',
    'OCCA': 'Offshore Central California',
    'PNRA': 'Peninsular Ranges',
    'SAFS': 'San Andreas Fault System',
    'SALT': 'Salton Trough Fault Area',
    'SNFA': 'Sierra Nevada Fault Area',
    'WTRA': 'Western Tranverse Ranges'
}, {
    'AHTC': 'Ash Hill-Tank Canyon fault system',
    'BBFS': 'Big Bear fault system',
    'BCFZ': 'Blue Cut fault zone',
    'BMFZ': 'Black Mountain fault zone',
    'BPPM': 'Big Pine-Pine Mountain fault system',
    'BRSZ': 'Brawley Seismic Zone',
    'BWFZ': 'Blackwater fault zone',
    'CBFZ': 'Coronado Bank fault zone',
    'CEPS': 'Compton-Lower Elysian Park fault system',
    'CHFZ': 'Calico-Hildalgo fault zone',
    'CIFS': 'Channel Islands fault system',
    'CLFZ': 'Cleghorn fault zone',
    'CPFZ': 'Cerro Prieto fault zone',
    'CREC': 'Camp Rock-Emerson-Copper Mtn fault zone',
    'CRFS': 'Cross fault',
    'CRSF': 'Cross fault',
    'CSTL': 'Coastal faults',
    'ELSZ': 'Elsinore-Laguna Salada fault zone',
    'GLPS': 'Goldstone Lake-Paradise fault system',
    'GMFS': 'Granite Mountains fault system',
    'GRFZ': 'Garlock fault zone',
    'HMFZ': 'Hunter Mountain fault zone',
    'HPFZ': 'Harper Lake fault zone',
    'HSFZ': 'Hosgri fault zone',
    'HSLZ': 'Helendale-South Lockhart fault zone',
    'HVFZ': 'Homestead Valley fault zone',
    'IBFS': 'Inner Borderland fault system',
    'IMFZ': 'Imperial fault zone',
    'JVFZ': 'Johnson Valley fault zone',
    'LDWZ': 'Ludlow fault zone',
    'LILZ': 'Lake Isabella Lineament zone',
    'LLFZ': 'Little Lake fault zone',
    'LSBM': 'Little San Bernardino Mtns fault system',
    'MHFZ': 'Mecca Hills-Hidden Springs fault system',
    'MNXZ': 'Manix fault zone',
    'MRFS': 'Mission Ridge fault system',
    'NAFZ': 'Nacimiento fault zone',
    'NBJD': 'Northern Baja Detachments?',
    'NCFS': 'North Channel fault system',
    'NDVZ': 'Northern Death Valley fault zone',
    'NFTS': 'North Frontal thrust system',
    'NIFZ': 'Newport-Inglewood fault zone',
    'NIRC': 'Newport-Inglewood-Rose Canyon fault zone',
    'NULL': 'undefined',
    'ORFZ': 'Oak Ridge fault zone',
    'OSMS': 'Oceanside-San Mateo fault system',
    'OWFZ': 'Owens Valley fault zone',
    'PBFZ': 'Pisgah-Bullion fault zone',
    'PLFZ': 'Pleito fault zone',
    'PMFZ': 'Pinto Mountain fault zone',
    'PMVZ': 'Panamint Valley fault zone',
    'PVFZ': 'Palos Verdes fault zone',
    'SAFZ': 'San Andreas fault zone',
    'SBCF': 'Santa Barbara Channel faults',
    'SBTS': 'Southern Boundary Thrust system',
    'SCCR': 'Santa Cruz-Catalina Ridge fault zone',
    'SCFZ': 'South Cuyama fault zone',
    'SDTZ': 'San Diego Trough fault zone',
    'SDVZ': 'Southern Death Valley fault zone',
    'SFFS': 'Southern Frontal fault system',
    'SFNS': 'San Fernando fault system',
    'SGFZ': 'San Gabriel fault zone',
    'SGMF': 'San Gabriel Mountain faults',
    'SGRP': 'San Gorgonio Pass fault system',
    'SJFZ': 'San Jacinto fault zone',
    'SJMZ': 'San Juan-Morales fault zone',
    'SLCZ': 'Sisar-Lion Canyon fault zone',
    'SMFZ': 'Sierra Madre fault zone',
    'SNFZ': 'Southern Sierra Nevada fault zone',
    'SOCZ': 'San Onofre-Carlsbad fault zone',
    'SPBZ': 'San Pedro Basin fault zone',
    'SSFZ': 'Santa Susana fault zone',
    'SSRZ': 'Simi-Santa Rosa fault zone',
    'SYFZ': 'Santa Ynez fault zone',
    'TDRS': 'Temblor-Diablo Range fault system',
    'TMFZ': 'Tiefort Mountains fault zone',
    'WWFZ': 'White Wolf fault zone'
}, {
    '1857': '1857 rupture',
    '1872': '1872 rupture',
    '1992': '1992 rupture',
    'ALCM': 'Agua Caliente-Laguna Mts.?',
    'ANCP': 'Anacapa',
    'ANZA': 'Anza',
    'AGCL': 'Agua Caliente',
    'ASHH': 'Ash Hill',
    'BRMT': 'Burnt Mountain',
    'BRSZ': 'Brawley Seismic Zone',
    'CDVD': 'Canada-David',
    'CHNH': 'Chino Hills',
    'CHNO': 'Chino',
    'CLCZ': 'Cholame-Carrizo',
    'CMGF': 'Cucamonga fault',
    'CNTR': 'Central',
    'COAL': 'Coalinga',
    'COAV': 'Coachella',
    'CRCT': 'Cerro-Centinela',
    'CRPR': 'Cerro Prieto basin',
    'CSPC': 'Clamshell-Sawpit Canyon',
    'CYMT': 'Coyote Mountain',
    'CYTC': 'Coyote Creek',
    'EAST': 'Eastern',
    'EMCP': 'El_Mayor-Cucapah',
    'EMRS': 'Emerson',
    'EMTB': 'East Montebello',
    'EQVS': 'Earthquake Valley',
    'ERPK': 'Eureka Peak',
    'GLDS': 'Goldstone Lake',
    'GLIV': 'Glen Ivy',
    'HMVS': 'Homestead Valley',
    'HTSP': 'Hot Springs',
    'IMPV': 'Imperial Valley',
    'INDP': 'Independence',
    'JNSV': 'Johnson Valley',
    'JULN': 'Julian',
    'KTLM': 'Kettleman Hills',
    'LABS': 'Los Angeles Basin',
    'LCKV': 'Lockwood Valley',
    'LGSD': 'Laguna Salada',
    'LSBM': 'Little San Bernardino Mtns',
    'LSTH': 'Lost Hills',
    'LVLK': 'Lavic Lake',
    'MCHS': 'Mecca Hills-Hidden Springs',
    'MJVS': 'Mojave',
    'MRLS': 'Morales',
    'MSNH': 'Mission Hills',
    'MULT': 'multiple',
    'NCPP': 'North Channel-Pitas Point',
    'NE': 'Northeast',
    'NTEW': 'Northeast-Northwest',
    'NWPT': 'Newport',
    'OCNS': 'Oceanside',
    'OFFS': 'Offshore',
    'PARK': 'Parkfield',
    'PHLS': 'Peralta Hills',
    'PLMS': 'Palomas',
    'PMTS': 'Pine Mountain',
    'PPMC': 'Pitas Point-Mid-Channel trend',
    'PPT': 'Pitas Point',
    'PPTV': 'Pitas Point-Ventura',
    'PRDS': 'Paradise',
    'RDMT': 'Red Mountain',
    'RDNC': 'Redondo Canyon',
    'RSCN': 'Rose Canyon',
    'SANC': 'San Antonio Canyon',
    'SBMT': 'San Bernardino Mountains',
    'SBRN': 'San Bernardino',
    'SCVA': 'Santa Clarita Valley',
    'SFNV': 'San Fernando Valley',
    'SGPS': 'San Gorgonio Pass',
    'SGV': 'San Gabriel Valley',
    'SJCV': 'San Jacinto-Claremont',
    'SJMT': 'San Jacinto Mts',
    'SJSH': 'San Jose Hills',
    'SLTS': 'Salton Sea',
    'SMMT': 'Santa Monica Mountains',
    'SMNB': 'Santa Monica basin',
    'SNCZ': 'Santa Cruz',
    'SNRS': 'Santa Rosa',
    'SPDB': 'San Pedro basin',
    'SQJH': 'San Joaquin Hills',
    'SSHS': 'Superstition Hills',
    'SSMT': 'Superstition Mountain',
    'STEW': 'Southeast-Southwest',
    'TANK': 'Tank Canyon',
    'TMBK': 'Thirty Mile Bank',
    'TMCL': 'Temecula',
    'USAF': 'Upper Santa Ana Valley',
    'USAV': 'Upper Santa Ana Valley',
    'VNTB': 'Ventura basin',
    'VRDM': 'Verdugo Mountains',
    'WEST': 'Western',
    'WHIT': 'Whittier'
}]


if __name__ == '__main__':
    main()
