#!/usr/bin/env python
"""
SCEC Community Velocity Model (CVM-H) extraction tool

TODO: merge Wills and Wald Vs30 maps into CVMH projection
"""
import os, sys
import numpy as np
import coord, gocad
import cst

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


def vs30_wald():
    """
    Download and prepare Wald, et al. Vs30 map.
    """
    repo = cst.site.repo
    f = os.path.join( repo, 'cvm_vs30_wald.npy' )
    if os.path.exists( f ):
        data = np.load( f )
    else:
        import urllib, gzip
        url = 'http://earthquake.usgs.gov/hazards/apps/vs30/downloads/Western_US.grd.gz'
        f0 = os.path.join( repo, os.path.basename( url ) )
        if not os.path.exists( f0 ):
            print( 'Downloading %s' % url )
            urllib.urlretrieve( url, f0 )
        fh = gzip.open( f0 )
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
        np.save( f, data )
    return extent_gtl, None, data, None


def vs30_wills():
    """
    Download and prepare Wills Vs30 map.
    """
    repo = cst.site.repo
    f = os.path.join( repo, 'cvm_vs30_wills.npy' )
    if os.path.exists( f ):
        data = np.load( f )
    else:
        data = vs30_wald()[2]
        x, y = gtl_coords()
        url = 'opensha.usc.edu:/export/opensha/data/siteData/wills2006.bin'
        f0 = os.path.join( repo, os.path.basename( url ) )
        if not os.path.exists( f0 ):
            print( 'Downloading %s' % url )
            if os.system( 'scp %s %s' % (url, f0) ):
                sys.exit()
        fh = open( f0, 'rb' )
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
        np.save( f, data )
    return extent_gtl, None, data, None


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


def cvmh_voxet( prop=None, voxet=None, no_data_value='nan', version='vx62' ):
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
        surface: array of properties for 2d data or model top for 3d data.
        volume: array of properties for 3d data or None for 2d data.
    """

    # download if not found
    repo = cst.site.repo
    path = os.path.join( repo, version, 'bin' )
    if not os.path.exists( path ):
        import urllib, tarfile
        f = os.path.join( repo, '%s.tar.bz2' % version )
        if not os.path.exists( f ):
            url = 'http://structure.harvard.edu/cvm-h/download/%s.tar.bz2' % version
            print( 'Downloading %s' % url )
            urllib.urlretrieve( url, f )
        tarfile.open( f, 'r:bz2' ).extractall( repo )

    # voxet ID
    if voxet in voxet3d:
        vid, bound = voxet3d[voxet]
    else:
        vid, bound = 'interfaces', None
    voxfile = os.path.join( path, vid + '.vo' )
    topfile = os.path.join( path, vid + '_TOP@@' )

    # compute model top from Vs if not found
    if not os.path.exists( topfile ) and prop in prop3d:
        print 'Searching for model top'
        p = prop3d['vs']
        voxet = gocad.voxet( voxfile, p )['1']
        data = voxet['PROP'][p]['DATA']
        z0 = voxet['AXIS']['O'][2]
        z1 = voxet['AXIS']['W'][2] + z0
        nz = data.shape[2]
        dz = (z1 - z0) / (nz - 1)
        top = np.empty_like( data[:,:,0] )
        top.fill( np.nan )
        for j in range( nz ):
            if dz < 0.0:
                j = nz - 1 - j
            f = data[:,:,j].copy()
            f[1:,:]  = f[1:,:]  + f[:-1,:]
            f[:-1,:] = f[:-1,:] + f[1:,:]
            f[:,1:]  = f[:,1:]  + f[:,:-1]
            f[:,:-1] = f[:,:-1] + f[:,1:]
            i = ~np.isnan( f )
            z = z0 + j * dz
            top[i] = z
        top.T.tofile( topfile )

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
    nx, ny, nz = data.shape
    if nz == 1:
        return extent, bound, data.squeeze(), None
    else:
        top = np.fromfile( topfile, data.dtype ).reshape( [ny, nx] ).T
        return extent, bound, top, data


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
        x, y, z: sample coordinate arrays.
        out: output array, same shape as x, y, and z.
        interpolation: 'nearest', 'linear'

    Returns
    -------
        out: property samples at coordinates (x, y, z)
    """
    def __init__( self, prop, voxet=['mantle', 'crust'], no_data_value='nan' ):
        self.prop = prop
        if prop == 'wald':
            self.voxet = [ vs30_wald() ]
        elif prop == 'wills':
            self.voxet = [ vs30_wills() ]
        elif prop in prop2d:
            self.voxet = [ cvmh_voxet( prop ) ]
        else:
            self.voxet = []
            for vox in voxet:
                self.voxet += [ cvmh_voxet( prop, vox, no_data_value ) ]
        return
    def __call__( self, x, y, z=None, out=None, interpolation='linear' ):
        if out is None:
            out = np.empty_like( x )
            out.fill( np.nan )
        for extent, bound, surface, volume in self.voxet:
            if z is None:
                coord.interp2( extent[:2], surface, (x, y), out, interpolation, bound )
            else:
                coord.interp3( extent, volume, (x, y, z), out, interpolation, bound )
        return out


class Extraction():
    """
    Model extraction with geotechnical layer (GTL)

    Init parameters
    ---------------
        vm: velocity model
        x, y: Cartesian coordinates
        topo: topography model
        vs30: Vs30 model, None=omit GTL
        zgtl: GTL interpolation depth
        interpolation: 'nearest', 'linear'

    Call parameters
    ---------------
        z: elevation (or depth) coordinate
        out: output array, same shape as z
        by_depth: z coordinate type, True=depth, False=elevation

    Returns
    -------
        out: property samples at coordinates (x, y, z)
    """
    def __init__( self, x, y, vm, topo, vs30=None, gtl_depth=100.0, interpolation='linear' ):
        x = np.asarray( x )
        y = np.asarray( y )
        z0 = topo( x, y )
        if vs30 is None:
            gtl_depth = 0.0
        else:
            z1 = vm( x, y )
            z1 = np.minimum( z0 - gtl_depth, z1 - 1.0 )
            d0 = 30.0
            d1 = z0 - z1
            v_ = vs30( x, y )
            v0 = v_ * 0.55
            v1 = v_ * 1.45
            v2 = vm( x, y, z1, interpolation=interpolation )
            b0 = (v1 - v0) / d0
            if vm.prop == 'vp':
                v1 = brocher_vp( v1 )
            b1 = (v2 - v1) / (d1 - d0)
            c0 = v0
            c1 = v1 - b1 * d0
            self.gtl = b0, b1, c0, c1, d0, d1
            gtl_depth = max( gtl_depth, d1.max() )
        self.data = x, y, z0, vm, interpolation, gtl_depth
        return
    def __call__( self, z, out=None, min_depth=None, by_depth=True ):
        x, y, z0, vm, interpolation, gtl_depth = self.data
        z = np.asarray( z )
        if out is None:
            out = np.empty_like( z )
            out.fill( np.nan )
        if by_depth is False:
            vm( x, y, z, out, interpolation )
            d = z0 - z
        else:
            vm( x, y, z0 - z, out, interpolation )
            d = z
        if gtl_depth > 0.0:
            if min_depth is None:
                min_depth = d.min()
            if min_depth < gtl_depth:
                b0, b1, c0, c1, d0, d1 = self.gtl
                i = d < 0.0
                out[i] = np.nan
                i = (d >= 0.0) & (d < d0)
                if vm.prop == 'vp':
                    out[i] = brocher_vp( c0[i] + b0[i] * d[i] )
                else:
                    out[i] = c0[i] + b0[i] * d[i]
                i = (d >= d0) & (d < d1)
                out[i] = c1[i] + b1[i] * d[i]
        return out


def extract( prop, x, y, z, geographic=True, by_depth=True, gtl_depth=100.0, vs30='wald', method='linear' ):
    """
    Simple CVM-H extraction

    Parameters
    ----------
        prop: Material property, 'rho', 'vp', 'vs', or 'tag'.
        x, y, z: Coordinate arrays.
        geographic: X, Y coordinates, True=geographic, False=UTM.
        by_depth: Z coordinate, True=depth, False=elevation.
        gtl_depth: GTL interpolation depth, 0 = no GTL.
        vs30: Vs30 map, 'wills', or 'wald'.
        method: Interpolation method, 'linear', or 'nearest'.

    Returns
    -------
        f: Material array
    """
    vm = Model( prop )
    topo = Model( 'topo' )
    if geographic:
        import pyproj
        proj = pyproj.Proj( **projection )
        x, y = proj( x, y )
    if gtl_depth:
        vs30 = Model( vs30 )
        ex = Extraction( x, y, vm, topo, vs30, gtl_depth, method )
    else:
        ex = Extraction( x, y, vm, topo, None, gtl_depth, method )
    f = ex( z, by_depth=by_depth )
    return f

