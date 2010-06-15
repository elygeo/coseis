#!/usr/bin/env python
"""
SCEC Community Velocity Model (CVM-H) extraction tool
"""
import os, sys
import numpy as np
import coord, gocad
import cst

# parameters
projection = dict( proj='utm', zone=11, datum='NAD27', ellps='clrk66' )
extent = (131000.0, 828000.0), (3431000.0, 4058000.0), (-200000.0, 4900.0)
prop2d = {'topo': '1', 'base': '2', 'moho': '3'}
prop3d = {'vp': '1', 'vs': '3', 'tag': '2'}
voxet3d = {'mantle': 'CVM_CM', 'crust': 'CVM_LR', 'lab': 'CVM_HR'}

def wald_vs30():
    """
    Download and read Wald, et al. Vs30 map.
    """
    repo = cst.site.repo
    url = 'http://earthquake.usgs.gov/hazards/apps/vs30/downloads/Western_US.grd.gz'
    f0 = os.path.join( repo, os.path.basename( url ) )
    f = f0.split( '.' )[0]
    if not os.path.exists( f ):
        import urllib, gzip
        print( 'Downloading %s' % url )
        urllib.urlretrieve( url, f0 )
        fh = gzip.open( f0 )
        fh.seek( 19512 )
        open( f, 'wb' ).write( fh.read() )
    shape = 2280, 2400
    delta = 0.25 / 60
    x = -125.0 + delta, -106.0 - delta
    y =   30.0 + delta,   50.0 - delta
    extent = x, y
    data = np.fromfile( f, '>f' ).reshape( shape[::-1] ).T
    return extent, data, None

def wills_vs30():
    """
    Download and read Wills Vs30 map.
    """
    repo = cst.site.repo
    url = 'opensha.usc.edu:/export/opensha/data/siteData/wills2006.bin'
    f = os.path.join( repo, os.path.basename( url ) )
    if not os.path.exists( f ):
        print( 'Downloading %s' % url )
        if os.system( 'scp %s %s' % (url, f) ):
            sys.exit()
    shape = 49867, 44016
    delta = 0.00021967246502752
    x, y = -124.52997177169, 32.441345502265
    x = x, x + (shape[0] - 1) * delta
    y = y + (shape[1] - 1) * delta, y
    extent = x, y
    data = np.fromfile( f, '<i2' ).reshape( shape ).T
    #i = data == -9999
    return extent, data, None

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
        vid = voxet3d[voxet]
    else:
        vid = 'interfaces'
    voxfile = os.path.join( path, vid + '.vo' )
    topfile = os.path.join( path, vid + '_TOP@@' )

    # compute model top from Vs if not found
    if not os.path.exists( topfile ) and prop in prop3d:
        p = prop3d['vs']
        voxet = gocad.voxet( voxfile, p )['1']
        data = voxet['PROP'][p]['DATA']
        z0 = voxet['AXIS']['O']
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
    if prop == None:
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
        return extent, data.squeeze(), None
    else:
        dtype = data.dtype
        top = np.fromfile( topfile, dtype ).reshape( [ny, nx] ).T
        return extent, top, data

class Model():
    """
    SCEC CVM-H model.

    Init parameters
    ---------------
        prop:
            2d property: 'topo', 'base', or 'moho'
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
    def __init__( self, prop, voxet=['mantle', 'crust', 'lab'], no_data_value='nan' ):
        self.prop = prop
        if prop == 'vs30':
            #self.voxet = [ wills_vs30 ]
            self.voxet = [ wald_vs30() ]
        elif prop in prop2d:
            self.voxet = [ cvmh_voxet( prop ) ]
        else:
            self.voxet = []
            for vox in voxet:
                self.voxet += [ cvmh_voxet( prop, vox, no_data_value ) ]
        return
    def __call__( self, x, y, z=None, out=None, interpolation='linear' ):
        if out == None:
            out = np.empty_like( x )
            out.fill( np.nan )
        for extent, surface, volume in self.voxet:
            if z == None:
                coord.interp2( extent[:2], surface, (x, y), out, method=interpolation )
            else:
                coord.interp3( extent, volume, (x, y, z), out, method=interpolation )
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
        lon, lat: geographic coordinates
        zgrl: GTL interpolation depth
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
    def __init__( self, x, y, vm, topo, lon=None, lat=None, vs30=None, gtl_depth=100.0, interpolation='linear' ):
        x = np.asarray( x )
        y = np.asarray( y )
        z0 = topo( x, y )
        if vs30 == None:
            gtl_depth = 0.0
        else:
            z1 = vm( x, y )
            z1 = np.minimum( z0 - gtl_depth, z1 - 1.0 )
            d0 = 30.0
            d1 = z0 - z1
            v_ = vs30( lon, lat )
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
        if out == None:
            out = np.empty_like( z )
            out.fill( np.nan )
        if by_depth == False:
            vm( x, y, z, out, interpolation )
            d = z0 - z
        else:
            vm( x, y, z0 - z, out, interpolation )
            d = z
        if gtl_depth > 0.0:
            if min_depth == None:
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

