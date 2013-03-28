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
        cat = {str(k):v for k, v in cat.items()}
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


def tree(cat):
    import pprint
    tree = {}
    for f, n in cat.items():
        k = f.split('-', 3)
        node = tree
        for i in range(3):
            if k[i] not in node:
                node[k[i]] = {}
            node = node[k[i]]
        node[k[-1]] = n
    pprint.pprint(tree)
    return


def search(cat, items, split=1, maxsplit=3):
    import os

    # search the catalog
    if items == []:
        match = sorted(cat)
        prefix = []
        n = 0
    else:
        match = set()
        if isinstance(items, basestring):
            items = [items]
        for a in items:
            b = a.split(':')[0].lower()
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


def read(faults, cat=None, version='CFM4-socal-primary'):
    """
    Read CFM triangulated surface data for a given list of fault
    names, returning:
    vtx: 3 x M array of vertex Cartesian coordinates
    tri: 3 x N array of vertex indices
    """
    import os
    import numpy as np

    # prep
    if cat == None:
        cat = catalog(version=version)
    path = os.path.join(repo, 'cfm4', version)
    npy = os.path.join(path, '%s-%04d-%s.npy')

    # read faults
    vtx = []
    tri = []
    if isinstance(faults, basestring):
        faults = [faults]
    for fs in faults:
        f, s = (fs + ':').split(':')[:2]
        if s:
            s = (int(i) for i in s.split(','))
        else:
            s = range(cat[f])
        for i in s:
            vtx.append(np.load(npy % (f, i, 'xyz')))
            tri.append(np.load(npy % (f, i, 'tri')))
    if len(vtx) == 0:
        return
    vtx, tri = tsurf_merge(vtx, tri)

    return vtx, tri


def tsurf_merge(vtx, tri):
    """
    Merge list of multiple triangulated surfaces
    """
    import numpy as np
    n = 0
    for i in range(len(vtx)):
        tri[i] += n
        n += vtx[i][0].size
    vtx = np.hstack(vtx)
    tri = np.hstack(tri)
    return vtx, tri


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
        'centroid_utm': ctr,
        'centroid': center,
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


def explore(prefix, faults, cat=None):
    """
    CFMX: Community Fault Model Explorer
    ====================================

    A simple tool for exploring the CFM

    Keyboard Controls
    -----------------

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

    # faults
    single_fault = isinstance(faults, basestring)
    if not faults:
        print('No faults found')
        return

    # parameters
    import os
    import numpy as np
    from . import data, interpolate
    import pyproj
    proj = pyproj.Proj(**projection)
    extent = (-122.0, -114.0), (31.5, 37.5)
    resolution = 'high'
    view_azimuth = -90
    view_elevation = 45
    view_angle = 15
    color_bg = 1.0, 1.0, 0.0
    color_hl = 1.0, 0.0, 0.0

    # setup figure
    from enthought.mayavi import mlab
    s = 'SCEC Community Fault Model'
    if prefix:
        s = [s] + [fault_names[i][k] for i, k in enumerate(prefix[:3])]
        if single_fault:
            s += [prefix[3].replace('_', ' ')]
        s = ', '.join(s)
    print('\n%s\n' % s)
    fig = mlab.figure(bgcolor=(1,1,1), fgcolor=(0,0,0), size=(1280, 720))
    fig.name = s
    fig.scene.disable_render = True
    #text_handle = mlab.text(0.01, 0.01, 'Here is \nsome text\nyay.')

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

    # read fault surfaces
    if single_fault:
        f, s = (faults + ':').split(':')[:2]
        if s:
            faults = ['%s:%s' % (f, i) for i in s.split(',')]
        else:
            faults = ['%s:%s' % (f, i) for i in range(cat[f])]
    surfs = []
    for ifault, f in enumerate(faults):
        if isinstance(f, basestring):
            name = f
        else:
            name, f = f
        print(name)
        vtx, tri = read(f, cat)
        m = geometry(vtx, tri)
        a = m['area'] * 0.000001
        c = m['centroid']
        u = m['centroid_utm']
        x, y, z = vtx
        s = [
            'Mean Strike:   %10.5f deg' % m['stk'],
            'Mean Dip:      %10.5f deg' % m['dip'],
            'Centroid Lon:  %10.5f deg' % c[0],
            'Centroid Lat:  %10.5f deg' % c[1],
            'Centroid Elev: %10d m'     % c[2],
            'Min Elevation: %10d m'     % z.min(),
            'Max Elevation: %10d m'     % z.max(),
            'Surface Area:  %10d km^2'  % a,
        ]
        k = name.split('-', 3)
        s += [fault_names[i][a] for i, a in enumerate(k[:3])]
        if k[3:]:
            s += [k[3].replace('_', ' ')]
        s += [name]
        p = mlab.triangular_mesh(
            x, y, z, tri.T,
            representation = 'surface',
            color = color_bg,
        ).actor.actor.property
        if single_fault:
            surfs.append((ifault, u, s, p))
        else:
            surfs.append((c[0], u, s, p))
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
            print explore.__doc__
        fig.scene.disable_render = False
        save[0] = isurf
        return

    # finish up
    fig.scene.interactor.add_observer('KeyPressEvent', on_key_press)
    mlab.view(view_azimuth, view_elevation)
    fig.scene.camera.view_angle = view_angle
    fig.scene.disable_render = False
    print "\nPress H in the figure window for help."
    mlab.show()
    return

fault_names = [{
"BNRA": "Basin and Range Fault Area",
"CRFA": "Coast Ranges Fault Area",
"ETRA": "Eastern Transverse Ranges",
"GRFS": "Garlock Fault System",
"GVFA": "Great Valley Fault Area",
"MJVA": "Mojave Fault Area",
"OCBA": "Offshore Continental Borderland",
"OCCA": "Offshore Central California",
"PNRA": "Peninsular Ranges",
"SAFS": "San Andreas Fault System",
"SALT": "Salton Trough Fault Area",
"SNFA": "Sierra Nevada Fault Area",
"WTRA": "Western Tranverse Ranges"
}, {
"AHTC": "Ash Hill-Tank Canyon fault system",
"BBFS": "Big Bear fault system",
"BCFZ": "Blue Cut fault zone",
"BMFZ": "Black Mountain fault zone",
"BPPM": "Big Pine-Pine Mountain fault system",
"BRSZ": "Brawley Seismic Zone",
"BWFZ": "Blackwater fault zone",
"CBFZ": "Coronado Bank fault zone",
"CEPS": "Compton-Lower Elysian Park fault system",
"CHFZ": "Calico-Hildalgo fault zone",
"CIFS": "Channel Islands fault system",
"CLFZ": "Cleghorn fault zone",
"CPFZ": "Cerro Prieto fault zone",
"CREC": "Camp Rock-Emerson-Copper Mtn fault zone",
"CRFS": "Cross fault",
"CRSF": "Cross fault",
"CSTL": "Coastal faults",
"ELSZ": "Elsinore-Laguna Salada fault zone",
"GLPS": "Goldstone Lake-Paradise fault system",
"GMFS": "Granite Mountains fault system",
"GRFZ": "Garlock fault zone",
"HMFZ": "Hunter Mountain fault zone",
"HPFZ": "Harper Lake fault zone",
"HSFZ": "Hosgri fault zone",
"HSLZ": "Helendale-South Lockhart fault zone",
"HVFZ": "Homestead Valley fault zone",
"IBFS": "Inner Borderland fault system",
"IMFZ": "Imperial fault zone",
"JVFZ": "Johnson Valley fault zone",
"LDWZ": "Ludlow fault zone",
"LILZ": "Lake Isabella Lineament zone",
"LLFZ": "Little Lake fault zone",
"LSBM": "Little San Bernardino Mtns fault system",
"MHFZ": "Mecca Hills-Hidden Springs fault system",
"MNXZ": "Manix fault zone",
"MRFS": "Mission Ridge fault system",
"NAFZ": "Nacimiento fault zone",
"NBJD": "Northern Baja Detachments?",
"NCFS": "North Channel fault system",
"NDVZ": "Northern Death Valley fault zone",
"NFTS": "North Frontal thrust system",
"NIFZ": "Newport-Inglewood fault zone",
"NIRC": "Newport-Inglewood-Rose Canyon fault zone",
"NULL": "undefined",
"ORFZ": "Oak Ridge fault zone",
"OSMS": "Oceanside-San Mateo fault system",
"OWFZ": "Owens Valley fault zone",
"PBFZ": "Pisgah-Bullion fault zone",
"PLFZ": "Pleito fault zone",
"PMFZ": "Pinto Mountain fault zone",
"PMVZ": "Panamint Valley fault zone",
"PVFZ": "Palos Verdes fault zone",
"SAFZ": "San Andreas fault zone",
"SBCF": "Santa Barbara Channel faults",
"SBTS": "Southern Boundary Thrust system",
"SCCR": "Santa Cruz-Catalina Ridge fault zone",
"SCFZ": "South Cuyama fault zone",
"SDTZ": "San Diego Trough fault zone",
"SDVZ": "Southern Death Valley fault zone",
"SFFS": "Southern Frontal fault system",
"SFNS": "San Fernando fault system",
"SGFZ": "San Gabriel fault zone",
"SGMF": "San Gabriel Mountain faults",
"SGRP": "San Gorgonio Pass fault system",
"SJFZ": "San Jacinto fault zone",
"SJMZ": "San Juan-Morales fault zone",
"SLCZ": "Sisar-Lion Canyon fault zone",
"SMFZ": "Sierra Madre fault zone",
"SNFZ": "Southern Sierra Nevada fault zone",
"SOCZ": "San Onofre-Carlsbad fault zone",
"SPBZ": "San Pedro Basin fault zone",
"SSFZ": "Santa Susana fault zone",
"SSRZ": "Simi-Santa Rosa fault zone",
"SYFZ": "Santa Ynez fault zone",
"TDRS": "Temblor-Diablo Range fault system",
"TMFZ": "Tiefort Mountains fault zone",
"WWFZ": "White Wolf fault zone"
}, {
"1857": "1857 rupture",
"1872": "1872 rupture",
"1992": "1992 rupture",
"ALCM": "Agua Caliente-Laguna Mts.?",
"ANCP": "Anacapa",
"ANZA": "Anza",
"AGCL": "Agua Caliente",
"ASHH": "Ash Hill",
"BRMT": "Burnt Mountain",
"BRSZ": "Brawley Seismic Zone",
"CDVD": "Canada-David",
"CHNH": "Chino Hills",
"CHNO": "Chino",
"CLCZ": "Cholame-Carrizo",
"CMGF": "Cucamonga fault",
"CNTR": "Central",
"COAL": "Coalinga",
"COAV": "Coachella",
"CRCT": "Cerro-Centinela",
"CRPR": "Cerro Prieto basin",
"CSPC": "Clamshell-Sawpit Canyon",
"CYMT": "Coyote Mountain",
"CYTC": "Coyote Creek",
"EAST": "Eastern",
"EMCP": "El_Mayor-Cucapah",
"EMRS": "Emerson",
"EMTB": "East Montebello",
"EQVS": "Earthquake Valley",
"ERPK": "Eureka Peak",
"GLDS": "Goldstone Lake",
"GLIV": "Glen Ivy",
"HMVS": "Homestead Valley",
"HTSP": "Hot Springs",
"IMPV": "Imperial Valley",
"INDP": "Independence",
"JNSV": "Johnson Valley",
"JULN": "Julian",
"KTLM": "Kettleman Hills",
"LABS": "Los Angeles Basin",
"LCKV": "Lockwood Valley",
"LGSD": "Laguna Salada",
"LSBM": "Little San Bernardino Mtns",
"LSTH": "Lost Hills",
"LVLK": "Lavic Lake",
"MCHS": "Mecca Hills-Hidden Springs",
"MJVS": "Mojave",
"MRLS": "Morales",
"MSNH": "Mission Hills",
"MULT": "multiple",
"NCPP": "North Channel-Pitas Point",
"NE": "Northeast",
"NTEW": "Northeast-Northwest",
"NWPT": "Newport",
"OCNS": "Oceanside",
"OFFS": "Offshore",
"PARK": "Parkfield",
"PHLS": "Peralta Hills",
"PLMS": "Palomas",
"PMTS": "Pine Mountain",
"PPMC": "Pitas Point-Mid-Channel trend",
"PPT": "Pitas Point",
"PPTV": "Pitas Point-Ventura",
"PRDS": "Paradise",
"RDMT": "Red Mountain",
"RDNC": "Redondo Canyon",
"RSCN": "Rose Canyon",
"SANC": "San Antonio Canyon",
"SBMT": "San Bernardino Mountains",
"SBRN": "San Bernardino",
"SCVA": "Santa Clarita Valley",
"SFNV": "San Fernando Valley",
"SGPS": "San Gorgonio Pass",
"SGV": "San Gabriel Valley",
"SJCV": "San Jacinto-Claremont",
"SJMT": "San Jacinto Mts",
"SJSH": "San Jose Hills",
"SLTS": "Salton Sea",
"SMMT": "Santa Monica Mountains",
"SMNB": "Santa Monica basin",
"SNCZ": "Santa Cruz",
"SNRS": "Santa Rosa",
"SPDB": "San Pedro basin",
"SQJH": "San Joaquin Hills",
"SSHS": "Superstition Hills",
"SSMT": "Superstition Mountain",
"STEW": "Southeast-Southwest",
"TANK": "Tank Canyon",
"TMBK": "Thirty Mile Bank",
"TMCL": "Temecula",
"USAF": "Upper Santa Ana Valley",
"USAV": "Upper Santa Ana Valley",
"VNTB": "Ventura basin",
"VRDM": "Verdugo Mountains",
"WEST": "Western",
"WHIT": "Whittier"
}]
