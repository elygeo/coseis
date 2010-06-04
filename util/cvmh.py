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

def wills_vs30():
    """
    Download and read Wills Vs30 map.
    """
    url = 'opensha.usc.edu:/export/opensha/data/siteData/wills2006.bin'
    f = os.path.join( repo, os.path.basename( url ) )
    if not os.path.exists( f ):
        if not os.path.exists( repo ):
            os.makedirs( repo )
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
    def __init__( self, x, y, vm, topo, lon=None, lat=None, vs30=None, zgtl=100.0, interpolation='linear' ):
        z0 = topo( x, y )
        if vs30 == None:
            self.gtl = None
        else:
            slope_factor = 0.03
            d0 = 15.0
            v0 = vs30( lon, lat )
            z1 = vm( x, y )
            z1 = np.minimum( z0 - zgtl, z1 - 1.0 )
            v1 = vm( x, y, z1, interpolation=interpolation )
            w = z0 - z1
            b = v0 * slope_factor
            a = v1 / ((w - d0) * ((w - d0) + b) + v0)
            self.gtl = d0, v0, w, b, a
        self.data = x, y, z0, vm, interpolation
        return
    def __call__( self, z, out=None, by_depth=True ):
        x, y, z0, vm, interpolation = self.data
        if out == None:
            out = np.empty_like( z )
            out.fill( np.nan )
        if by_depth:
            vm( x, y, z0 - z, out, interpolation )
            d = z
        else:
            vm( x, y, z, out, interpolation )
            d = z0 - z
        if self.gtl != None:
            d0, v0, w, b, a = self.gtl
            i = d < 0.0
            out[i] = np.nan
            i = (d >= 0.0) & (d < d0)
            out[i] = v0[i] + (d[i] - d0) * b[i]
            i = (d >= d0) & (d < w)
            out[i] = v0[i] + (d[i] - d0) * (b[i] + a[i] * (d[i] - d0))
        return out

def zprofile( lim, vm, topo, vs30, nsample=200, interpolation='linear' ):
    """
    Depth profile plot.
    """
    import pyproj
    import matplotlib.pyplot as plt
    zgtl = 100.0
    x = lim[0]
    y = lim[1]
    z0, z1 = lim[2]
    z = np.linspace( z0, z1, nsample )
    proj = pyproj.Proj( **projection )
    lon, lat = proj( x, y, inverse=True )
    extract = Extraction( x, y, vm, topo, lon, lat, vs30, zgtl, interpolation )
    f = extract( z, by_depth=True )
    fig = plt.figure()
    fig.clf()
    ax = plt.gca()
    ax.plot( f, z )
    ax.set_title( vm.prop )
    ax.set_ylabel( 'Z (km)' )
    return fig

def xsection( lim, vm, topo, vs30, base, delta=(500.0, 50.0), interpolation='linear' ):
    """
    Cross section plot.
    """
    import pyproj
    import matplotlib.pyplot as plt
    zgtl = 100.0
    scale = 0.001
    x0, x1 = lim[0]
    y0, y1 = lim[1]
    z0, z1 = lim[2]
    v0, v1 = lim[3]
    dx, dy = x1 - x0, y1 - y0
    L = np.sqrt( dx * dx + dy * dy )
    ex = [ scale * r for r in [0, L, z0, z1] ]
    r = np.arange( 0, L + 0.5 * delta[0], delta[0] )
    x = x0 + dx / L * r
    y = y0 + dy / L * r
    z = np.arange( z0, z1 + 0.5 * delta[1], delta[1] )
    zz, xx = np.meshgrid( z, x )
    zz, yy = np.meshgrid( z, y )
    proj = pyproj.Proj( **projection )
    lon, lat = proj( xx, yy, inverse=True )
    extract = Extraction( xx, yy, vm, topo, lon, lat, vs30, zgtl, interpolation )
    f = extract( zz, by_depth=False )
    fig = plt.figure()
    fig.clf()
    ax = plt.gca()
    im = ax.imshow( f.T, extent=ex, vmin=v0, vmax=v1, origin='lower', interpolation='nearest' )
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

def zplane( lim, vm, topo, vs30, mapdata, delta=500.0, interpolation='linear' ):
    """
    Depth plane plot.
    """
    import pyproj
    import matplotlib.pyplot as plt
    zgtl = 100.0
    scale = 0.001
    x0, x1 = lim[0]
    y0, y1 = lim[1]
    z0 = lim[2]
    v0, v1 = lim[3]
    ex = [ scale * r for r in [x0, x1, y0, y1] ]
    x = np.arange( x0, x1 + 0.5 * delta, delta )
    y = np.arange( y0, y1 + 0.5 * delta, delta )
    y, x = np.meshgrid( y, x )
    z = np.empty_like( x )
    z.fill( z0 )
    proj = pyproj.Proj( **projection )
    lon, lat = proj( x, y, inverse=True )
    extract = Extraction( x, y, vm, topo, lon, lat, vs30, zgtl, interpolation )
    f = extract( z, by_depth=True )
    fig = plt.figure()
    fig.clf()
    ax = plt.gca()
    im = ax.imshow( f.T, extent=ex, vmin=v0, vmax=v1, origin='lower', interpolation='nearest' )
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
    topo = Model( 'topo' )
    base = Model( 'base' )
    vs30 = Model( 'vs30' )

    # profiles
    if 1:
        lim = 400000.0, 3750000.0, (150.0, 3200.0)
        zprofile( lim, vm, topo, vs30 ).show()

    # cross sections
    if 0:
        delta = 100.0, 10.0
        lim = (400000.0, 400000.0), (3650000.0, 3850000.0), (-3000.0, 2000.0), (150.0, 3200.0)
        xsection( lim, vm, topo, None, base, delta, 'nearest' ).show()
        xsection( lim, vm, topo, vs30, base, delta, 'linear' ).show()

    # depth planes
    if 0:
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
        zplane( (x, y, z, v), vm, topo, None, mapdata, delta, 'nearest' ).show()
        zplane( (x, y, z, v), vm, topo, vs30, mapdata, delta, 'linear' ).show()

