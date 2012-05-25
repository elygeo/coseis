"""
SCEC Community Fault Model (CFM) tools.
"""

# data repository location
import os
repo = os.path.join(os.path.dirname(__file__), 'data')
del(os)

# projection: UTM zone 11, NAD 1927 datum (implies Clark 1866 geoid)
projection = dict(proj='utm', zone=11, datum='NAD27')

def catalog(version='CFM4-socal-primary'):
    """
    Return a dictionary of available faults. The dictionary key:value pair is
    the fault name and number of segments. The CFM database is downloaded if not
    already present.
    """
    import os, urllib, zipfile
    import numpy as np
    from . import gocad

    fault_file = os.path.join(repo, 'cfm4', 'fault-list.txt')
    path = os.path.join(repo, 'cfm4', version)
    npy = os.path.join(path, '%s-%04d-%s.npy')
    url = 'http://structure.harvard.edu/cfm/download/vdo/SCEC_VDO.jar'
    dtype = [('name', 'S64'), ('nseg', 'i')]

    if os.path.exists(fault_file):
        cat = dict(np.loadtxt(fault_file, dtype))
    else:
        f = os.path.join(repo, 'scec-vdo.jar')
        if not os.path.exists(f):
            print('Downloading %s' % url)
            urllib.urlretrieve(url, f)
        zp = zipfile.ZipFile(f)
        src = os.path.join('data', 'Faults', version)
        os.makedirs(path)
        cat = {}
        for f in zp.namelist():
            base, key = os.path.split(f)
            if base != src or not key.endswith('.ts'):
                continue
            key = key[:-3]
            data = zp.read(f)
            xyz, tri = gocad.tsurf(data)[0][2:4]
            cat[key] = len(tri)
            for k, t in enumerate(tri):
                i, j = np.unique(t, return_inverse=True)
                t = np.arange(t.size)[j].reshape(t.shape)
                x = xyz[:,i]
                np.save(npy % (key, k, 'xyz'), x)
                np.save(npy % (key, k, 'tri'), t)
        f = np.array(sorted(cat.items()), dtype)
        np.savetxt(fault_file, f, '%s %s')
    return cat


def tsurf_plane(xyz, tri):
    """
    Find the center of mass, best-fit plane, and total surface area of a
    triangulated surface.

    Parameters
    ----------
    xyz: vertex coordinates (x, y, z)
    tri: triangle indices (j, k, l)

    Returns
    -------
    center: center of mass (x, y, z)
    normal: mean unit surface normal (nx, ny, nz)
    area: total surface area
    """
    import math
    import numpy as np
    import scipy.optimize

    # area normals
    x, y, z = xyz
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
    area = a.sum()
    d = 1.0 / (3.0 * area)
    x = d * ((x[j] + x[k] + x[l]) * a).sum()
    y = d * ((y[j] + y[k] + y[l]) * a).sum()
    z = d * ((z[j] + z[k] + z[l]) * a).sum()
    center = x, y, z

    # best fit plane
    def misfit(plane):
        phi, theta = plane
        x = math.cos(theta) * math.cos(phi)
        y = math.cos(theta) * math.sin(phi)
        z = math.sin(theta)
        return -abs(x * wx + y * wy + z * wz).sum()
    phi, theta = scipy.optimize.fmin(misfit, (0.0, 0.0), disp=False)
    x = math.cos(theta) * math.cos(phi)
    y = math.cos(theta) * math.sin(phi)
    z = math.sin(theta)
    if z < 0.0:
        x, y, z = -x, -y, -z
    normal = x, y, z
    return center, normal, area


def read(faults=None, extent=None, version='CFM4-socal-primary'):
    """
    Read CFM triangulated surface data and compute various geometrical properties.
    Data is returned as a single object with attributes.

    Parameters
    ----------

    faults: List of faults names, and (optionally) segment indices.
    extent: Return None if outside range (xmin, xmax), (ymin, ymax).
    version: CFM version name

    Return object attributes
    ------------------------

    name: Fault name
    x, y, z: Vertex Cartesian coordinates
    x0, y0, z0: Center of mass Cartesian coordinates
    lon, lat: vertex geographic coordinate
    lon0, lat0: Center of mass geographic coordinates
    extent: (min_lon, max_lon), (min_lat, max_lat)
    tri: List of N x 3 array of vertex indices
    stk: Fault strike
    dip: Fault dip
    area: Total surface area
    """
    import os, math
    import numpy as np
    import pyproj

    # prep
    nseg = catalog(version=version)
    proj = pyproj.Proj(**projection)
    path = os.path.join(repo, 'cfm4', version)
    npy = os.path.join(path, '%s-%04d-%s.npy')

    # read faults
    n = 0
    vtx = []
    tri = []
    name = []
    if isinstance(faults, basestring):
        faults = [faults]
    for f in faults:
        if type(f) in (list, tuple):
            f, segs = f
        else:
            segs = range(nseg[f])
        for i in segs:
            x, y, z = np.load(npy % (f, i, 'xyz'))
            lon, lat = proj(x, y, inverse=True)
            if extent:
                xlim, ylim = extent
                if (
                    lon.max() < xlim[0] or
                    lon.min() > xlim[1] or
                    lat.max() < ylim[0] or
                    lat.min() > ylim[1]
                ):
                    continue
            vtx.append([x, y, z, lon, lat])
            t = np.load(npy % (f, i, 'tri'))
            tri.append(t + n)
            n += x.size
        name.append('%s%s' % (f, segs))

    # combine segments
    if len(vtx) == 0:
        return
    vtx = np.hstack(vtx)
    tri = np.hstack(tri)
    name = os.path.commonprefix(name)

    # properties
    x, y, z, lon, lat = vtx
    ctr, nrm, area = tsurf_plane((x, y, z), tri)
    x, y, z = nrm
    x0, y0, z0 = ctr
    r = math.sqrt(x * x + y * y) / z
    dip = math.atan(r) / math.pi * 180.0
    x = x0, x0 - x, x0 + x
    y = y0, y0 - y, y0 + y
    x, y = proj(x, y, inverse=True)
    lon0, lat0 = x[0], y[0]
    x = 0.5 * (x[2] - x[1]) * math.cos(lat0 / 180.0 * math.pi)
    y = 0.5 * (y[2] - y[1])
    stk = (math.atan2(-y, x) / math.pi * 180.0) % 360.0
    extent = (lon.min(), lon.max()), (lat.min(), lat.max())

    # data object
    x, y, z, lon, lat = vtx
    class obj:
        def __init__(self, **kwarg):
            self.__dict__.update(**kwarg)
    obj = obj(
        name = name,
        lon = lon, lon0 = lon0,
        lat = lat, lat0 = lat0,
        extent = extent,
        x = x, x0 = x0,
        y = y, y0 = y0,
        z = z, z0 = z0,
        tri = tri,
        stk = stk,
        dip = dip,
    )
    return obj


def search(cat, patterns, split=False):
    """
    Search a catalog for a list of string patterns.
    Non-string patterns are passed through.
    """
    if not patterns:
        match = sorted(cat)
    elif isinstance(patterns, basestring):
        p = patterns.lower()
        match = sorted(k for k in cat if p in k.lower())
        if split:
            match = [(k, i) for k in match for i in range(cat[k])]
    else:
        match = []
        for p in patterns:
            if ~isinstance(p, basestring):
                match.append(p)
            else:
                p = p.lower()
                m = (k for k in cat if p in k.lower())
                if split:
                    m = ((k, i) for k in m for i in range(cat[k]))
                match.extend(m)
        match = sorted(match)
    return match


def explore(faults=None, split=False):
    """
    CFMX: Community Fault Model Explorer
    ====================================

    A simple tool for exploring the CFM

    Keyboard Controls
    -----------------

    Fault selection                  [ ]
    Reset fault selection              \\
    Rotate the view               Arrows          
    Pan the view            Shift-Arrows    
    Zoom the view                    - =             
    Reset the view                Delete               
    Toggle stereo view                 3               
    Save a screen-shot                 S               
    Help                             h ?
    """
    import numpy as np
    import pyproj
    from enthought.mayavi import mlab
    from . import coord, data, interpolate

    # parameters
    proj = pyproj.Proj(proj='tmerc', lon_0=-118.0, lat_0=34.5)
    extent = (-122.0, -114.0), (31.5, 37.5)
    resolution = 'high'
    view_azimuth = -90
    view_elevation = 45
    view_angle = 15
    opacity = 0.3
    opacity = 1.0
    color_bg = 1.0, 1.0, 0.0
    color_hl = 1.0, 0.0, 0.0

    # setup figure
    fig_name = 'CFMX: Community Fault Model Explorer'
    print '\n%s\n' % fig_name
    fig = mlab.figure(bgcolor=(1,1,1), fgcolor=(0,0,0), size=(1280, 720))
    fig.name = fig_name
    fig.scene.disable_render = True

    # DEM
    dem, extent = data.dem(extent, mesh=True)
    x, y, z = dem
    x, y = proj(x, y)
    mlab.mesh(x, y, z, color=(1,1,1), opacity=0.3)

    # base map
    ddeg = 0.5 / 60.0
    x, y = np.c_[
        data.mapdata('coastlines', resolution, extent, 10.0, delta=ddeg),
        [float('nan'), float('nan')],
        data.mapdata('borders', resolution, extent, delta=ddeg),
    ]
    x -= 360.0
    z = interpolate.interp2(extent, dem[2], (x, y))
    x, y = proj(x, y)
    i = np.isnan(z)
    x[i] = float('nan')
    y[i] = float('nan')
    mlab.plot3d(x, y, z, color=(0,0,0), line_width=1, tube_radius=None)

    # fault surfaces
    print '\nReading fault surfaces:\n'
    names = {}
    coords = []
    for f in search(catalog(), faults):
        print('    ' + repr(f))
        f = read(f)
        x, y = proj(f.lon, f.lat)
        z, t = f.z, f.tri.T
        s = mlab.triangular_mesh(x, y, z, t, representation='surface', color=color_bg)
        x, y = proj(f.lon0, f.lat0)
        z = f.z0
        a = s.actor.actor
        coords += [[x, y, z, a]]
        names[a] = f.name

    # handle key press
    def on_key_press(obj, event, current=[None]):
        k = obj.GetKeyCode()
        fig.scene.disable_render = True
        if k in '[]':
            m = fig.scene.camera.view_transform_matrix.to_array()
            mx, my, mz, mt = m[0]
            actors = [(mx*x + my*y + mz*z + mt, a) for x, y, z, a in coords]
            actors = [a for r, a in sorted(actors)]
            if current[0]:
                d = {'[': -1, ']': 1}[k]
                i = (actors.index(current[0]) + d) % len(actors)
                current[0].property.opacity = opacity
                current[0].property.color = color_bg
            else:
                i = len(actors) // 2
                for a in names.keys():
                    a.property.opacity = opacity
                    a.property.color = color_bg
            a = actors[i]
            a.property.opacity = 1.0
            a.property.color = color_hl
            fig.name = names[a]
            current[0] = a
        elif k == '\\' and current[0]:
            current[0] = None
            fig.name = fig_name
            for a in names.keys():
                a.property.opacity = 1.0
                a.property.color = color_hl
        elif ord(k) == 8: # delete key
            mlab.view(view_azimuth, view_elevation)
            fig.scene.camera.view_angle = view_angle
        elif k in '/?h':
            print __doc__
        fig.scene.disable_render = False
        return

    # finish up
    fig.scene.interactor.add_observer('KeyPressEvent', on_key_press)
    mlab.view(view_azimuth, view_elevation)
    fig.scene.camera.view_angle = view_angle
    fig.scene.disable_render = False
    mlab.show()
    print "\nPress H in the figure window for help."

