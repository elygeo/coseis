"""
SCEC Community Velocity Model (CVM-H) tools.
"""

# data repository location
import os
repo = os.path.join(os.path.dirname(__file__), 'data')
del(os)

# parameters
projection = dict(proj='utm', zone=11, datum='NAD27', ellps='clrk66')
extent = (131000.0, 828000.0), (3431000.0, 4058000.0), (-200000.0, 4900.0)
extent_gtl = (-31000.0, 849000.0), (3410000.0, 4274000.0)
prop2d = {'topo': '1', 'base': '2', 'moho': '3'}
prop3d = {'vp': '1', 'vs': '3', 'tag': '2'}
voxet3d = {
    'mantle': ('CVM_CM', False),
    'crust':  ('CVM_LR', [(False, False), (False, False), (True, False)]),
    'lab':    ('CVM_HR', True),
}


def gtl_coords(delta_gtl=250.0):
    """
    Create GTL lon/lat mesh coordinates.
    """
    import numpy as np
    import pyproj
    proj = pyproj.Proj(**projection)
    d = 0.5 * delta_gtl
    x, y = extent_gtl
    x = np.arange(x[0], x[1] + d, delta_gtl)
    y = np.arange(y[0], y[1] + d, delta_gtl)
    y, x = np.meshgrid(y, x)
    x, y = proj(x, y, inverse=True)
    return x, y


def vs30_wald(rebuild=False):
    """
    Wald, et al. Vs30 map.
    """
    import os
    import numpy as np
    from . import data
    f = os.path.join(repo, 'cvmh-vs30-wald.npy')
    if not os.path.exists(f):
        x, y = gtl_coords()
        v = data.vs30_wald([x, y])
        np.save(f, v)
    return extent_gtl, None, np.load(f, mmap_mode='c')


def vs30_wills(rebuild=False):
    """
    Wills and Clahan Vs30 map.
    """
    import os, sys, urllib, subprocess
    import numpy as np
    from . import interpolate

    url = 'http://earth.usc.edu/~gely/cvm-data/cvmh-vs30-wills.npy'
    filename = os.path.join(repo, os.path.basename(url))
    if not rebuild:
        if not os.path.exists(filename):
            print('Downloading %s' % url)
            urllib.urlretrieve(url, filename)
        data = np.load(filename)
    else:
        data = vs30_wald()[2]
        x, y = gtl_coords()
        url = 'opensha.usc.edu:/export/opensha/data/siteData/wills2006.bin'
        f = os.path.join(repo, os.path.basename(url))
        if not os.path.exists(f):
            print('Downloading %s' % url)
            subprocess.check_call(['scp', url, f])
        fh = open(f, 'rb')
        dtype = '<i2'
        bytes = np.dtype(dtype).itemsize
        delta = 0.00021967246502752
        nx, ny, nz = 49867, 1048, 42 # slowest, least memory
        nx, ny, nz = 49867, 1834, 24 # medium
        nx, ny, nz = 49867, 2751, 16 # fastest, most memory
        x0, y0 = -124.52997177169, 32.441345502265
        x1 = x0 + (nx - 1) * delta
        print('Resampling Wills Vs30 (takes about 5 min)')
        for k in range(nz):
            sys.stdout.write('.')
            sys.stdout.flush()
            y1 = y0 + ((nz - k) * ny - 1) * delta
            y2 = y0 + ((nz - k) * ny - ny) * delta
            extent = (x0, x1), (y1, y2)
            v = fh.read(nx * ny * bytes)
            v = np.fromstring(v, dtype).astype('f').reshape((ny, nx)).T
            v[v <= 0] = float('nan')
            interpolate.interp2(extent, v, (x, y), data, bound=True, mask_nan=True)
        print('')
        np.save(filename, data)
    return extent_gtl, None, data


def nafe_drake(f):
    """
    Density derived from V_p via Nafe-Drake curve, Brocher (2005) eqn 1.
    """
    import numpy as np
    f = np.asarray(f) * 0.001
    f = f * (1.6612 - f * (0.4721 - f * (0.0671 - f * (0.0043 - f * 0.000106))))
    f = np.maximum(f, 1.0) * 1000.0
    return f


def brocher_vp(f):
    """
    V_p derived from V_s via Brocher (2005) eqn 9.
    """
    import numpy as np
    f = np.asarray(f) * 0.001
    f = 0.9409 + f * (2.0947 - f * (0.8206 - f * (0.2683 - f * 0.0251)))
    f *= 1000.0
    return f


def cvmh_voxet(prop=None, voxet=None, no_data_value=None, version='11.9.0'):
    """
    Download and read SCEC CVM-H voxet.

    Parameters
    ----------
    prop:
        2d property: 'topo', 'base', or 'moho'
        3d property: 'vp', 'vs', or 'tag'
    voxet:
        3d voxet: 'mantle', 'crust', or 'lab'
    no_data_value: None, 'nan', or float value. None = filled from below.
    version: 'vx62', 'vx63', '11.2.0', or '11.9.0'

    Returns
    -------
    extent: (x0, x1), (y0, y1), (z0, z1)
    bound: (x0, x1), (y0, y1), (z0, z1)
    data: Array of properties
    """
    import os, urllib, tarfile
    from . import gocad

    path = os.path.join(repo, 'cvmh-%s' % version)
    if version[:2] == 'vx':
        url = 'http://structure.harvard.edu/cvm-h/download/%s.tar.bz2' % version
        base = '%s/bin' % version
        f = path + '.bztar'
    else:
        url = 'http://hypocenter.usc.edu/research/cvmh/11.9.0/cvmh-%s.tar.gz' % version
        base = 'cvmh-%s/model' % version
        f = path + '.tgz'

    # download if not found
    if not os.path.exists(path):
        if not os.path.exists(f):
            print('Downloading %s' % url)
            urllib.urlretrieve(url, f)
        print('Extracting %s' % f)
        tar = tarfile.open(f)
        os.mkdir(path)
        with tar as tar:
            for t in tar:
                if not t.name.startswith(base):
                    continue
                if t.name.endswith('.vo') or t.name.endswith('@@'):
                    f = os.path.join(path, os.path.split(t.name)[1])
                    open(f, 'wb').write(tar.extractfile(t).read())

    # fill 3d voxets
    turd = os.path.join(path, 'filled')
    if not os.path.exists(turd):
        for vox in voxet3d:
            print('Filling voxet %s %s' % (version, vox))
            vp, vs, tag = prop3d['vp'], prop3d['vs'], prop3d['tag']
            vid = voxet3d[vox][0]
            voxfile = os.path.join(path, vid + '.vo')
            vox = gocad.voxet(voxfile, [vp, vs, tag])['1']
            w = vox['AXIS']['W'][2]
            d1 = vox['PROP'][vp]['DATA']
            d2 = vox['PROP'][vs]['DATA']
            d3 = vox['PROP'][tag]['DATA']
            v1 = vox['PROP'][vp]['NO_DATA_VALUE']
            v2 = vox['PROP'][vs]['NO_DATA_VALUE']
            n = d1.shape[2]
            if w > 0.0:
                for i in range(1, n):
                    ii = (d1[:,:,i] == v1) | (d2[:,:,i] == v2)
                    d1[:,:,i][ii] = d1[:,:,i-1][ii]
                    d2[:,:,i][ii] = d2[:,:,i-1][ii]
                    d3[:,:,i][ii] = d3[:,:,i-1][ii]
            else:
                for i in range(n-1, 0, -1):
                    ii = (d1[:,:,i-1] == v1) | (d2[:,:,i-1] == v2)
                    d1[:,:,i-1][ii] = d1[:,:,i][ii]
                    d2[:,:,i-1][ii] = d2[:,:,i][ii]
                    d3[:,:,i-1][ii] = d3[:,:,i][ii]
            f1 = os.path.join(path, vox['PROP'][vp]['FILE'] + '-filled')
            f2 = os.path.join(path, vox['PROP'][vs]['FILE'] + '-filled')
            f3 = os.path.join(path, vox['PROP'][tag]['FILE'] + '-filled')
            d1.T.tofile(f1)
            d2.T.tofile(f2)
            d3.T.tofile(f3)
            open(turd, 'w')

    # voxet ID
    if voxet in voxet3d:
        vid, bound = voxet3d[voxet]
    else:
        vid, bound = 'interfaces', None
    voxfile = os.path.join(path, vid + '.vo')

    # load voxet
    if prop is None:
        return gocad.voxet(voxfile)
    elif prop in prop2d:
        pid = prop2d[prop]
    else:
        pid = prop3d[prop]
    if no_data_value == None and prop in prop3d:
        vox = gocad.voxet(voxfile, [pid], alternate='-filled')['1']
    else:
        vox = gocad.voxet(voxfile, [pid], no_data_value=no_data_value)['1']

    # extent
    x, y, z = vox['AXIS']['O']
    u, v, w = vox['AXIS']['U'][0], vox['AXIS']['V'][1], vox['AXIS']['W'][2]
    extent = (x, x + u), (y, y + v), (z, z + w)

    # property data
    data = vox['PROP'][pid]['DATA']
    return extent, bound, data


class Model():
    """
    SCEC CVM-H model.

    Init parameters
    ---------------
    prop:
        2d property: 'topo', 'base', 'moho', 'wald', or 'wills'
        3d property: 'vp', 'vs', or 'tag'
    voxet:
        3d voxet list: ['mantle', 'crust', 'lab']
    no_data_value: None, 'nan', or float value. None = filled from below.
    version: 'vx62', 'vx63', '11.2.0', or '11.9.0'

    Call parameters
    ---------------
    x, y, z: Sample coordinate arrays.
    out: Optional output array with same shape as coordinate arrays.
    interpolation: 'nearest', or 'linear'

    Returns
    -------
    out: Property samples at coordinates (x, y, z)
    """
    def __init__(self, prop, voxet=['mantle', 'crust'], no_data_value=None, version='11.9.0'):
        self.prop = prop
        if prop == 'wald':
            self.voxet = [vs30_wald()]
        elif prop == 'wills':
            self.voxet = [vs30_wills()]
        elif prop in prop2d:
            self.voxet = [cvmh_voxet(prop, version=version)]
        else:
            self.voxet = []
            for vox in voxet:
                self.voxet += [cvmh_voxet(prop, vox, no_data_value, version)]
        return
    def __call__(self, x, y, z=None, out=None, interpolation='nearest'):
        import numpy as np
        from . import interpolate
        if out is None:
            out = np.empty_like(x)
            out.fill(float('nan'))
        for extent, bound, data in self.voxet:
            if z is None:
                data = data.reshape(data.shape[:2])
                interpolate.interp2(extent[:2], data, (x, y), out, interpolation, bound)
            else:
                interpolate.interp3(extent, data, (x, y, z), out, interpolation, bound)
        return out


class Extraction():
    """
    CVM-H extraction with geotechnical layer (GTL)

    Init parameters
    ---------------
    x, y: Coordinates arrays
    vm: 'vp', 'vs', 'tag', or Model object.
    vs30: 'wills', 'wald', None, or Model object.
    topo: 'topo' or Model object.
    interpolation: 'nearest', or 'linear'.
    **kwargs: Keyword arguments passed to Model()

    Call parameters
    ---------------
    z: Vertical coordinate array.
    out: Optional output array, same shape as coordinate arrays.
    min_depth: Minimum depth in Z array, optional but provides speed-up.
    by_depth: Z coordinate type, True for depth, False for elevation.

    Returns
    -------
    out: Property samples at coordinates (x, y, z)
    """

    def __init__(self, x, y, vm, vs30='wills', topo='topo', interpolation='nearest',
        **kwargs):
        import numpy as np
        x = np.asarray(x)
        y = np.asarray(y)
        if type(vm) is str:
            vm = Model(vm, **kwargs)
        if vm.prop in prop2d:
            raise Exception('Cannot extract 2D model')
        elif vm.prop == 'tag':
            vs30 = None
        if type(topo) is str:
            topo = Model(topo, **kwargs)
        z0 = topo(x, y, interpolation='linear')
        if type(vs30) is str:
            vs30 = Model(vs30, **kwargs)
        if vs30 is None:
            zt = None
        else:
            zt = 350.0
            v0 = vs30(x, y, interpolation='linear')
            if vm.prop == 'vp':
                v0 = brocher_vp(v0)
            vt = vm(x, y, z0 - zt, interpolation=interpolation)
            if 0: # FIXME add option for this
                v0 = np.maximum(vt, v0)
            if np.isnan(vt).any():
                print('WARNING: NaNs in GTL')
            self.gtl = v0, vt
        self.x, self.y, self.z0, self.zt = x, y, z0, zt
        self.vm, self.interpolation = vm, interpolation
        return

    def __call__(self, z, out=None, min_depth=None, by_depth=True):
        import numpy as np
        x, y, z0, zt = self.x, self.y, self.z0, self.zt
        vm, interpolation = self.vm, self.interpolation
        z = np.asarray(z)
        if out is None:
            out = np.empty_like(z)
            out.fill(float('nan'))
        if by_depth is False:
            vm(x, y, z, out, interpolation)
            z = z0 - z
        else:
            vm(x, y, z0 - z, out, interpolation)
        if zt:
            if min_depth is None:
                min_depth = z.min()
            if min_depth < zt:
                v0, vt = self.gtl
                a = 0.5
                b = 2.0 / 3.0
                c = 1.5
                z = z / zt
                f = z + b * (z - z * z)
                g = a - (a + 3.0 * c) * z + c * z * z + 2.0 * c * np.sqrt(z)
                i = z < 1.0
                out[i] = (f * vt + g * v0)[i]
        return out


def extract(x, y, z, vm=['rho', 'vp', 'vs'], geographic=True, by_depth=True, **kwargs):
    """
    Simple CVM-H extraction.

    Parameters
    ----------
    x, y, z: Coordinates arrays
    vm: 'rho', 'vp', 'vs', 'tag', or Model object.
    geographic: X Y coordinate type, True for geographic, False for UTM.
    by_depth: Z coordinate type, True for depth, False for elevation.
    **kwargs: Keyword arguments passed to Extraction()

    Returns
    -------
    out: Property samples at coordinates (x, y, z)
    """
    import numpy as np
    import pyproj

    x = np.asarray(x)
    y = np.asarray(y)
    if type(vm) not in [list, tuple]:
        vm = [vm]
    if geographic:
        proj = pyproj.Proj(**projection)
        dtype = x.dtype
        x, y = proj(x, y)
        x = x.astype(dtype)
        y = y.astype(dtype)
    out = []
    f = None
    for v in vm:
        prop = v
        if v == 'rho':
            prop = 'vp'
        if not out or prop != f.vm.prop:
            f = Extraction(x, y, prop, **kwargs)
        if v == 'rho':
            out += [nafe_drake(f(z, by_depth=by_depth))]
        else:
            out += [f(z, by_depth=by_depth)]
    return np.array(out)

