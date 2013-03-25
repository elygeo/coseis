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
    import os, urllib, zipfile, json
    import numpy as np
    from . import gocad

    fault_file = os.path.join(repo, 'cfm4', 'fault-list.json')
    path = os.path.join(repo, 'cfm4', version)
    npy = os.path.join(path, '%s-%04d-%s.npy')
    url = 'http://structure.harvard.edu/cfm/download/vdo/SCEC_VDO.jar'

    if os.path.exists(fault_file):
        cat = json.load(open(fault_file))
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
        f = open(fault_file, 'w')
        json.dump(cat, f, indent=0, sort_keys=True)

    return cat


def search(cat, items):
    """
    Search a catalog for a list of items. If the item string starts with '*', it is
    patterned matched. Any part of the item string starting with ':' is ignored.
    """
    if isinstance(items, basestring):
        items = [items]
    match = []
    for a in items:
        if ':' in a:
            i = a.index(':')
            a, b = a[:i], a[i:]
        else:
            b = ''
        if a[0] == '*':
            a = a[1:].lower()
            ab = (i + b for i in cat if a in i.lower())
        else:
            if a not in cat:
                raise Exception('Not found in catalog: ' + a)
            ab = [a + b]
        match.extend(ab)
    match = sorted(match)

    return match


def read(faults, version='CFM4-socal-primary'):
    """
    Read CFM triangulated surface data for a given list of fault
    names, returning three objects:
    vtx: 3 x M array of vertex Cartesian coordinates
    tri: N x 3 array of vertex indices
    name: Common prefix of the fault names
    """
    import os
    import numpy as np

    # prep
    cat = catalog(version=version)
    path = os.path.join(repo, 'cfm4', version)
    npy = os.path.join(path, '%s-%04d-%s.npy')

    # read faults
    n = 0
    vtx = []
    tri = []
    name = []
    if isinstance(faults, basestring):
        faults = [faults]
    for fs in faults:
        f, s = (fs + ':').split(':')[:2]
        if s:
            s = (int(i) for i in s.split(','))
        else:
            s = range(cat[f])
        for i in s:
            x, y, z = np.load(npy % (f, i, 'xyz'))
            vtx.append([x, y, z])
            t = np.load(npy % (f, i, 'tri'))
            tri.append(t + n)
            n += x.size
        name.append(fs)

    # combine segments
    if len(vtx) == 0:
        return
    vtx = np.hstack(vtx)
    tri = np.hstack(tri)
    name = os.path.commonprefix(name)

    return vtx, tri, name


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
    center_utm: [x, y, z] center of mass Cartesian coordinates
    center: [lon, lat, z] center of mass geographic coordinates
    stk: Fault strike
    dip: Fault dip
    area: Total surface area
    """
    import math
    import pyproj

    proj = pyproj.Proj(**projection)
    ctr, nrm, area = tsurf_plane(vtx, tri)
    x0, y0, z0 = ctr
    x, y, z = nrm
    r = math.sqrt(x * x + y * y) / z
    dip = math.atan(r) / math.pi * 180.0
    x = x0, x0 - x, x0 + x
    y = y0, y0 - y, y0 + y
    x, y = proj(x, y, inverse=True)
    center = x[0], y[0], z0
    x = 0.5 * (x[2] - x[1]) * math.cos(center[1] / 180.0 * math.pi)
    y = 0.5 * (y[2] - y[1])
    stk = (math.atan2(-y, x) / math.pi * 180.0) % 360.0

    # data dictionary
    meta = {
        'center_utm': ctr,
        'center': center,
        'stk': stk,
        'dip': dip,
        'area': area,
    }

    return meta


def outline(vtx, tri, delta=100, geographic=True):
    """
    Find the outline of a tri surf. A quick and dirty method that samples the tri
    surf onto a regular mesh, and then contours the boundary of non-empty samples.
    Smaller values of delta give finer results but take longer to compute.
    """
    import numpy as np
    from . import trinterp, plt

    d = delta / 10
    x, y = vtx
    xi = np.arange(x.min() - d, x.max() + d + delta, delta)
    yi = np.arange(y.min() - d, y.max() + d + delta, delta)
    yi, xi = np.meshgrid(yi, xi)
    z = np.ones_like(x)
    zi = trinterp.trinterp((x, y), z, tri, (xi, yi), no_data_val=-1)
    x, y = plt.contour(xi, yi, zi, [0])[0]

    if geographic:
        import pyproj
        proj = pyproj.Proj(**projection)
        x, y = proj(x, y, inverse=True)

    return x, y


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


def explore(faults=None, split=False):
    """
    CFMX: Community Fault Model Explorer
    ====================================

    A simple tool for exploring the CFM

    Keyboard Controls
    -----------------

    Fault selection                  [ ]
    Fault selection with focus       { }
    Reset fault selection              \\
    Rotate the view               Arrows
    Pan the view            Shift-Arrows
    Zoom the view                    - =
    Reset the view                Delete
    Toggle stereo view                 3
    Save a screen-shot                 S
    Info on selected fault             I
    Help                             h ?
    """
    import os
    import numpy as np
    import pyproj
    from enthought.mayavi import mlab
    from . import data, interpolate

    # parameters
    proj = pyproj.Proj(**projection)
    extent = (-122.0, -114.0), (31.5, 37.5)
    resolution = 'high'
    view_azimuth = -90
    view_elevation = 45
    view_angle = 15
    color_bg = 1.0, 1.0, 0.0
    color_hl = 1.0, 0.0, 0.0

    # setup figure
    fig_name = 'CFMX: Community Fault Model Explorer'
    print('\n%s\n' % fig_name)
    fig = mlab.figure(bgcolor=(1,1,1), fgcolor=(0,0,0), size=(1280, 720))
    fig.name = fig_name
    fig.scene.disable_render = True

    # DEM
    f = os.path.join(repo, 'cfm4', 'dem.npy')
    if os.path.exists(f):
        x, y, z = np.load(f)
    else:
        x, y, z = data.dem(extent, mesh=True)
        extent = (x.min(), x.max()), (y.min(), y.max())
        x, y = proj(x, y)
        np.save(f, [x, y, z])
    mlab.mesh(x, y, z, color=(1,1,1), opacity=0.3)

    # base map
    f = os.path.join(repo, 'cfm4', 'mapdata.npy')
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
        z = interpolate.interp2(extent, z, (x, y))
        x, y = proj(x, y)
        i = np.isnan(z)
        x[i] = float('nan')
        y[i] = float('nan')
        np.save(f, [x, y, z])
    mlab.plot3d(x, y, z, color=(0,0,0), line_width=1, tube_radius=None)

    # fault surfaces
    cat = catalog()
    if not faults:
        faults = sorted(cat)
    else:
        faults = search(cat, faults)
    surfs = []
    print('\nReading %s fault surfaces:\n' % len(faults))
    for fs in faults:
        print(fs)
        if split:
            f, s = (fs + ':').split(':')[:2]
            if s:
                fss = ('%s:%s' % (f, i) for i in s.split(','))
            else:
                fss = ('%s:%s' % (f, i) for i in range(cat[f]))
        else:
            fss = [fs]
        for fs in fss:
            vtx, tri, name = read(fs)
            x, y, z = vtx
            s = mlab.triangular_mesh(
                x, y, z, tri.T,
                representation = 'surface',
                color = color_bg,
            )
            p = s.actor.actor.property
            surfs.append((p, name, vtx, tri))

    # handle key press
    def on_key_press(obj, event, save=[None]):
        i = save[0]
        k = obj.GetKeyCode()
        fig.scene.disable_render = True
        if k in '[]{}':
            if i == None:
                i = 0
            else:
                p = surfs[i][0]
                p.color = color_bg
                d = {'[': -1, ']': 1, '{': -1, '}': 1}[k]
                i = (i + d) % len(surfs)
            p, name, vtx = surfs[i][:3]
            p.color = color_hl
            fig.name = name
            if k in '{}':
                x, y, z = vtx
                x = 0.5 * (x.min() + x.max())
                y = 0.5 * (y.min() + y.max())
                z = 0.5 * (z.min() + z.max())
                mlab.view(focalpoint=[x, y, z])
        elif k == '\\' and i != None:
            p = surfs[i][0]
            p.color = color_bg
            fig.name = fig_name
            i = None
        elif k == 'i':
            import json
            name, vtx, tri = surfs[i][1:]
            m = geometry(vtx, tri)
            m = json.dumps(m, indent=4, sort_keys=True)
            print('\n' + name + ' ' + m)
        elif ord(k) == 8: # delete key
            mlab.view(view_azimuth, view_elevation)
            fig.scene.camera.view_angle = view_angle
        elif k in '/?h':
            from .cfm import explore
            print explore.__doc__
        fig.scene.disable_render = False
        save[0] = i
        return

    # finish up
    fig.scene.interactor.add_observer('KeyPressEvent', on_key_press)
    mlab.view(view_azimuth, view_elevation)
    fig.scene.camera.view_angle = view_angle
    fig.scene.disable_render = False
    print "\nPress H in the figure window for help."
    mlab.show()
    return


