#!/usr/bin/env python
"""
SCEC Community Velocity Model (CVM-H) extraction tool
"""
import os, sys
import numpy as np
import coord, gocad

# parameters
repo = os.path.expanduser( '~/mapdata' )
projection = dict( proj='utm', zone=11, datum='NAD27', ellps='clrk66' )
extent = (131000.0, 828000.0), (3431000.0, 4058000.0), (-200000.0, 4900.0)
prop2d = {'topo': '1', 'base': '2', 'moho': '3'}
prop3d = {'rho': '1', 'vp': '1', 'vs': '3', 'tag': '2'}
voxet3d = {'mantle': 'CVM_CM', 'crust': 'CVM_LR', 'lab': 'CVM_HR'}

def nafe_drake( data ):
    """
    Derive density from Vp
    """
    data *= 0.001
    data = 1000.0 * (data * (1.6612 + data * (-0.4721
        + data * (0.0671 + data * (-0.0043 + data * 0.000106)))))
    return data

def wald_vs30():
    """
    Download and read Wald, et al. Vs30 map.
    """
    url = 'http://earthquake.usgs.gov/hazards/apps/vs30/downloads/Western_US.grd.gz'
    f0 = os.path.join( repo, os.path.basename( url ) )
    f = f0.split( '.' )[0]
    if not os.path.exists( f ):
        import urllib, gzip
        if not os.path.exists( repo ):
            os.makedirs( repo )
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

def wills_v30():
    """
    Download and read Wills Vs30 map.
    """
    url = 'opensha.usc.edu:/export/opensha/data/siteData/wills2006.bin'
    f = os.path.join( repo, os.path.basename( url ) )
    if not os.path.exists( f ):
        if not os.path.exists( repo ):
            os.makedirs( repo )
        print( 'Downloading %s' % url )
        os.system( 'ssh %s .' % url )
    shape = 49867, 44016
    delta = 0.00021967246502752
    x, y = -124.52997177169, 32.441345502265
    x = x, x + (shape[0] - 1) * delta
    y = y + (shape[1] - 1) * delta, y
    extent = x, y
    data = np.fromfile( f, '<i' ).reshape( shape ).T
    return extent, data, None

def cvmh_voxet( prop=None, voxet=None, no_data_value='nan' ):
    """
    Download and read SCEC CVM-H voxet.

    Parameters
    ----------
        prop:
            2d property: 'topo', 'base', or 'moho'
            3d property: 'rho', 'vp', 'vs', or 'tag'
        voxet:
            3d voxet: 'mantle', 'crust', 'lab'

    Returns
    -------
        extent: (x0, x1), (y0, y1), (z0, z1)
        surface: array of properties for 2d data or model top for 3d data.
        volume: array of properties for 3d data or None for 2d data.
    """

    # download if not found
    url = 'http://structure.harvard.edu/cvm-h/download/vx62.tar.bz2'
    version = os.path.basename( url ).split( '.' )[0]
    path = os.path.join( repo, version, 'bin' )
    if not os.path.exists( path ):
        import urllib
        if not os.path.exists( repo ):
            os.makedirs( repo )
        f = os.path.join( repo, os.path.basename( url ) )
        if not os.path.exists( f ):
            print( 'Downloading %s' % url )
            urllib.urlretrieve( url, f )
        if os.system( 'tar jxv -C %r -f %r' % (repo, f) ):
            sys.exit( 'Error extraction tar file' )

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
    if prop == 'rho':
        data = nafe_drake( data )
        data = np.maximum( data, 1000.0 )
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
            3d property: 'rho', 'vp', 'vs', or 'tag'
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
            #self.voxet = [ wald_vs30(), wills_vs30 ]
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
    def __init__( self, vm, x, y, topo, vs30=None, lon=None, lat=None, zgtl=100.0, interpolation='linear' ):
        z1 = topo( x, y )
        z2 = vm( x, y )
        z2 = np.minimum( z1 - zgtl, z2 - 1.0 )
        if vs30 == None:
            self.gtl = None
        else:
            v1 = vs30( lon, lat )
            v2 = vm( x, y, z2, interpolation=interpolation )
            self.gtl = v1, v2
        self.data = vm, x, y, z1, z2, interpolation
        return
    def __call__( self, z, out=None, by_depth=True ):
        vm, x, y, z1, z2, interpolation = self.data
        if out == None:
            out = np.empty_like( z )
            out.fill( np.nan )
        if by_depth:
            vm( x, y, z1 - z, out, interpolation )
            w = z / (z1 - z2)
        else:
            vm( x, y, z, out, interpolation )
            w = (z1 - z) / (z1 - z2)
        if self.gtl != None:
            v1, v2 = self.gtl
            i = w < 0.0
            out[i] = np.nan
            i = (w >= 0.0) & (w <= 1.0)
            out[i] = (1.0 - w[i]) * v1[i] + w[i] * v2[i]
        return out

def xsection( vm, topo, vs30, base, lim, delta=(500.0, 50.0), interpolation='linear' ):
    """
    Cross section plot.
    """
    import pyproj
    import matplotlib.pyplot as plt
    zgtl = 200.0
    scale = 0.001
    x1, x2 = lim[0]
    y1, y2 = lim[1]
    z1, z2 = lim[2]
    v1, v2 = lim[3]
    dx, dy = x2 - x1, y2 - y1
    L = np.sqrt( dx * dx + dy * dy )
    ex = [ scale * r for r in [0, L, z1, z2] ]
    r = np.arange( 0, L + 0.5 * delta[0], delta[0] )
    x = x1 + dx / L * r
    y = y1 + dy / L * r
    z = np.arange( z1, z2 + 0.5 * delta[1], delta[1] )
    zz, xx = np.meshgrid( z, x )
    zz, yy = np.meshgrid( z, y )
    proj = pyproj.Proj( **projection )
    lon, lat = proj( xx, yy, inverse=True )
    extract = Extraction( vm, xx, yy, topo, vs30, lon, lat, zgtl, interpolation )
    f = extract( zz, by_depth=False )
    fig = plt.figure()
    fig.clf()
    ax = plt.gca()
    im = ax.imshow( f.T, extent=ex, vmin=v1, vmax=v2, origin='lower', interpolation='nearest' )
    fig.colorbar( im, orientation='horizontal' )
    ax.set_title( vm.prop )
    ax.set_xlabel( 'X (km)' )
    ax.set_ylabel( 'Z (km)' )
    for surf in topo, base:
        if surf:
            f = surf( x, y, interpolation='linear' )
            ax.plot( scale * r, scale * f, 'k-' )
    ax.axis( 'auto' )
    ax.axis( ex )
    return fig

def zplane( vm, topo, vs30, mapdata, lim, delta=500.0, interpolation='linear' ):
    """
    Depth plane plot.
    """
    import pyproj
    import matplotlib.pyplot as plt
    zgtl = 100.0
    scale = 0.001
    x1, x2 = lim[0]
    y1, y2 = lim[1]
    z0 = lim[2]
    v1, v2 = lim[3]
    ex = [ scale * r for r in [x1, x2, y1, y2] ]
    x = np.arange( x1, x2 + 0.5 * delta, delta )
    y = np.arange( y1, y2 + 0.5 * delta, delta )
    y, x = np.meshgrid( y, x )
    z = np.empty_like( x )
    z.fill( z0 )
    proj = pyproj.Proj( **projection )
    lon, lat = proj( x, y, inverse=True )
    extract = Extraction( vm, x, y, topo, vs30, lon, lat, zgtl, interpolation )
    f = extract( z, by_depth=True )
    fig = plt.figure()
    fig.clf()
    ax = plt.gca()
    im = ax.imshow( f.T, extent=ex, vmin=v1, vmax=v2, origin='lower', interpolation='nearest' )
    fig.colorbar( im )
    if mapdata:
        x, y = mapdata
        ax.plot( scale * x, scale * y, '-k' )
    ax.set_title( vm.prop )
    ax.axis( ex )
    return fig

# continue if run from the command line
if __name__ == '__main__':

    # models
    vm = Model( 'vs', ['crust'] )
    vs30 = Model( 'vs30' )
    topo = Model( 'topo' )
    base = Model( 'base' )

    # cross sections
    if 1:
        surf = topo, base
        delta = 100.0, 10.0
        lim = (400000.0, 400000.0), (3650000.0, 3850000.0), (-3000.0, 2000.0), (150.0, 3200.0)
        xsection( vm, topo, None, base, lim, delta, 'nearest' ).show()
        xsection( vm, topo, vs30, base, lim, delta, 'linear' ).show()

    # depth planes
    if 1:
        if 0:
            import data
            import pyproj
            proj = pyproj.Proj( **projection )
            ll = (-121.3, -113.3), (30.9, 36.8)
            x, y = data.mapdata( 'coast', 'high', ll, 20.0, 1, 1 )
            u, v = data.mapdata( 'border', 'high', ll, delta=0.1 )
            x = np.r_[ x, np.nan, u ]
            y = np.r_[ y, np.nan, v ]
            mapdata = proj( x, y )
        else:
            mapdata = None
        delta = 500.0
        x, y, z = extent
        x = x[0] + delta, x[1] - delta
        y = y[0] + delta, y[1] - delta
        z = 20.0
        v = 150.0, 1500.0
        zplane( vm, topo, None, mapdata, (x, y, z, v), delta, 'nearest' ).show()
        zplane( vm, topo, vs30, mapdata, (x, y, z, v), delta, 'linear' ).show()

