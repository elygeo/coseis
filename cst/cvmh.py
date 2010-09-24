#!/usr/bin/env python
"""
SCEC Community Velocity Model (CVM-H) extraction tool
"""
import os, sys, urllib, gzip
import numpy as np
from . import coord, gocad

# parameters
projection = dict( proj='utm', zone=11, datum='NAD27', ellps='clrk66' )
extent = (131000.0, 828000.0), (3431000.0, 4058000.0), (-200000.0, 4900.0)
extent_gtl = (-31000.0, 849000.0), (3410000.0, 4274000.0)
prop2d = {'topo': '1', 'base': '2', 'moho': '3'}
prop3d = {'vp': '1', 'vs': '3', 'tag': '2'}
voxet3d = {
    'mantle': ( 'CVM_CM', None ),
    'crust':  ( 'CVM_LR', [(0, 0), (0, 0), (1, 0)] ),
    'lab':    ( 'CVM_HR', [(1, 1), (1, 1), (1, 1)] ),
}


def gtl_coords( delta_gtl=250.0 ):
    """
    Create GTL lon/lat mesh coordinates.
    """
    import pyproj
    proj = pyproj.Proj( **projection )
    d = 0.5 * delta_gtl
    x, y = extent_gtl
    x = np.arange( x[0], x[1] + d, delta_gtl )
    y = np.arange( y[0], y[1] + d, delta_gtl )
    y, x = np.meshgrid( y, x )
    x, y = proj( x, y, inverse=True )
    return x, y


def vs30_wald( rebuild=False ):
    """
    Wald, et al. Vs30 map.
    """
    import cst
    repo = cst.site.repo
    filename = os.path.join( repo, 'cvm_vs30_wald.npy' )
    if not rebuild and os.path.exists( filename ):
        data = np.load( filename )
    else:
        f1 = os.path.join( repo, 'Western_US.grd' )
        if not os.path.exists( f1 ):
            url = 'http://earthquake.usgs.gov/hazards/apps/vs30/downloads/Western_US.grd.gz'
            print( 'Downloading %s' % url )
            f = os.path.join( repo, os.path.basename( url ) )
            urllib.urlretrieve( url, f )
            open( f1, 'wb' ).write( gzip.open( f ).read() )
        fh = open( f1 )
        print( 'Resampling Wald Vs30' )
        dtype = '>f'
        nx, ny = 2280, 2400
        fh.seek( 19512 )
        data = fh.read()
        data = np.fromstring( data, dtype ).reshape( (ny, nx) ).T
        delta = 0.25 / 60
        x = -125.0 + delta, -106.0 - delta
        y =   30.0 + delta,   50.0 - delta
        extent = x, y
        x, y = gtl_coords()
        data = coord.interp2( extent, data, (x, y), method='linear' ).astype( 'f' )
        np.save( filename, data )
    return extent_gtl, None, data


def vs30_wills( rebuild=False ):
    """
    Wills and Clahan Vs30 map.
    """
    import cst
    repo = cst.site.repo
    url = 'http://earth.usc.edu/~gely/coseis/download/cvm_vs30_wills.npy'
    filename = os.path.join( repo, os.path.basename( url ) )
    if not rebuild:
        if not os.path.exists( filename ):
            print( 'Downloading %s' % url )
            urllib.urlretrieve( url, filename )
        data = np.load( filename )
    else:
        data = vs30_wald()[2]
        x, y = gtl_coords()
        url = 'opensha.usc.edu:/export/opensha/data/siteData/wills2006.bin'
        f = os.path.join( repo, os.path.basename( url ) )
        if not os.path.exists( f ):
            print( 'Downloading %s' % url )
            if os.system( 'scp %s %s' % (url, f) ):
                sys.exit()
        fh = open( f, 'rb' )
        dtype = '<i2'
        bytes = np.dtype( dtype ).itemsize
        delta = 0.00021967246502752
        nx, ny, nz = 49867, 1048, 42 # slowest, least memory
        nx, ny, nz = 49867, 1834, 24 # medium
        nx, ny, nz = 49867, 2751, 16 # fastest, most memory
        x0, y0 = -124.52997177169, 32.441345502265
        x1 = x0 + (nx - 1) * delta
        bound = (True, True), (True, True)
        print( 'Resampling Wills Vs30 (takes about 5 min)' )
        for k in range( nz ):
            sys.stdout.write( '.' )
            sys.stdout.flush()
            y1 = y0 + ((nz - k) * ny - 1) * delta
            y2 = y0 + ((nz - k) * ny - ny) * delta
            extent = (x0, x1), (y1, y2)
            v = fh.read( nx * ny * bytes )
            v = np.fromstring( v, dtype ).astype( 'f' ).reshape( (ny, nx) ).T
            v[v<=0] = np.nan
            coord.interp2( extent, v, (x, y), data, 'nearest', bound, mask_nan=True )
        print('')
        np.save( filename, data )
    return extent_gtl, None, data


def nafe_drake( f ):
    """
    Density derived from V_p via Nafe-Drake curve, Brocher (2005) eqn 1.
    """
    f = np.asarray( f ) * 0.001
    f = f * (1.6612 - f * (0.4721 - f * (0.0671 - f * (0.0043 - f * 0.000106))))
    f = np.maximum( f, 1.0 ) * 1000.0
    return f


def brocher_vp( f ):
    """
    V_p derived from V_s via Brocher (2005) eqn 9.
    """
    f = np.asarray( f ) * 0.001
    f = 0.9409 + f * (2.0947 - f * (0.8206 - f * (0.2683 - f * 0.0251)))
    f *= 1000.0
    return f


def cvmh_voxet( prop=None, voxet=None, no_data_value='nan', version='vx63' ):
    """
    Download and read SCEC CVM-H voxet.

    Parameters
    ----------
        prop:
            2d property: 'topo', 'base', or 'moho'
            3d property: 'vp', 'vs', or 'tag'
        voxet:
            3d voxet: 'mantle', 'crust', 'lab'

    Returns
    -------
        extent: (x0, x1), (y0, y1), (z0, z1)
        bound: (x0, x1), (y0, y1), (z0, z1)
        data: Array of properties
    """
    import cst
    repo = cst.site.repo

    # download if not found
    path = os.path.join( repo, version, 'bin' )
    if not os.path.exists( path ):
        url = 'http://structure.harvard.edu/cvm-h/download/%s.tar.bz2' % version
        print( 'Downloading %s' % url )
        f = os.path.join( repo, os.path.basename( url ) )
        urllib.urlretrieve( url, f )
        if os.system( 'tar -C %s -jxf %s' % (repo, f) ):
            sys.exit()

    # voxet ID
    if voxet in voxet3d:
        vid, bound = voxet3d[voxet]
    else:
        vid, bound = 'interfaces', None
    voxfile = os.path.join( path, vid + '.vo' )

    # load voxet
    if prop is None:
        return gocad.voxet( voxfile )
    elif prop in prop2d:
        pid = prop2d[prop]
    else:
        pid = prop3d[prop]
    voxet = gocad.voxet( voxfile, pid, no_data_value )['1']

    # extent
    x, y, z = voxet['AXIS']['O']
    u, v, w = voxet['AXIS']['U'][0], voxet['AXIS']['V'][1], voxet['AXIS']['W'][2]
    extent = (x, x + u), (y, y + v), (z, z + w)

    # property data
    data = voxet['PROP'][pid]['DATA']
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

    Call parameters
    ---------------
        x, y, z: Sample coordinate arrays.
        out: Optional output array with same shape as coordinate arrays.
        interpolation: 'nearest', or 'linear'

    Returns
    -------
        out: Property samples at coordinates (x, y, z)
    """
    def __init__( self, prop, voxet=['mantle', 'crust'], no_data_value='nan', version='vx63' ):
        self.prop = prop
        if prop == 'wald':
            self.voxet = [ vs30_wald() ]
        elif prop == 'wills':
            self.voxet = [ vs30_wills() ]
        elif prop in prop2d:
            self.voxet = [ cvmh_voxet( prop, version=version ) ]
        else:
            self.voxet = []
            for vox in voxet:
                self.voxet += [ cvmh_voxet( prop, vox, no_data_value, version ) ]
        return
    def __call__( self, x, y, z=None, out=None, interpolation='nearest' ):
        if out is None:
            out = np.empty_like( x )
            out.fill( np.nan )
        for extent, bound, data in self.voxet:
            if z is None:
                data = data.reshape( data.shape[:2] )
                coord.interp2( extent[:2], data, (x, y), out, interpolation, bound )
            else:
                coord.interp3( extent, data, (x, y, z), out, interpolation, bound )
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
    def __init__( self, x, y, vm, vs30='wills', topo='topo', interpolation='nearest',
        **kwargs ):
        x = np.asarray( x )
        y = np.asarray( y )
        if type( vm ) is str:
            vm = Model( vm, **kwargs )
        if vm.prop in prop2d:
            sys.exit( 'Cannot extract 2D model' )
        elif vm.prop == 'tag':
            vs30 = None
        if type( topo ) is str:
            topo = Model( topo, **kwargs )
        z0 = topo( x, y, interpolation='linear' )
        if type( vs30 ) is str:
            vs30 = Model( vs30, **kwargs )
        if vs30 is None:
            zt = None
        else:
            zt = 350.0
            v0 = vs30( x, y, interpolation='linear' )
            if vm.prop == 'vp':
                v0 = brocher_vp( v0 )
            vt = vm( x, y, z0 - zt, interpolation=interpolation )
            self.gtl = v0, vt
        self.data = x, y, z0, zt, vm, interpolation
        return
    def __call__( self, z, out=None, min_depth=None, by_depth=True ):
        x, y, z0, zt, vm, interpolation = self.data
        z = np.asarray( z )
        if out is None:
            out = np.empty_like( z )
            out.fill( np.nan )
        if by_depth is False:
            vm( x, y, z, out, interpolation )
            z = z0 - z
        else:
            vm( x, y, z0 - z, out, interpolation )
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
                g = a - (a + 3.0 * c) * z + c * z * z + 2.0 * c * np.sqrt( z )
                i = z < 1.0
                out[i] = (f * vt + g * v0)[i]
        return out


def extract( x, y, z, vm, geographic=True, by_depth=True, **kwargs ):
    """
    Simple CVM-H extraction.

    Parameters
    ----------
        x, y, z: Coordinates arrays
        vm: 'vp', 'vs', 'tag', or Model object.
        geographic: X Y coordinate type, True for geographic, False for UTM.
        by_depth: Z coordinate type, True for depth, False for elevation.
        **kwargs: Keyword arguments passed to Extraction()

    Returns
    -------
        out: Property samples at coordinates (x, y, z)
    """
    if geographic:
        import pyproj
        proj = pyproj.Proj( **projection )
        x, y = proj( x, y )
    f = Extraction( x, y, vm, **kwargs )
    out = f( z, by_depth=by_depth )
    return out

