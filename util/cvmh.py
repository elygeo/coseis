#!/usr/bin/env python
"""
SCEC Community Velocity Model (CVM-H) extraction tool
"""
import os, sys, urllib, pyproj
import numpy as np
import coord, gocad

# projection
proj = pyproj.Proj( proj='utm', zone=11, datum='NAD27', ellps='clrk66' )
extent = (131000.0, 828000.0), (3431000.0, 4058000.0), (-200000.0, 4900.0)

# lookup tables
property2d = {'topo': '1', 'base': '2', 'moho': '3'}
property3d = {'rho': '1', 'vp': '1', 'vs': '3', 'tag': '2'}
voxet3d = {'mantle': 'CVM_CM', 'crust': 'CVM_LR', 'lab': 'CVM_HR'}

def read_voxet( property=None, voxet=None ):
    """
    Download and read SCEC CVM-H voxet.

    Parameters
    ----------
        2d property: 'topo', 'base', or 'moho'
        3d property: 'rho', 'vp', 'vs', or 'tag'
        3d voxet: 'mantle', 'crust', 'lab'

    Returns
    -------
        extent: (x0, x1), (y0, y1), (z0, z1)
        delta: dx, dy, dz
        data: property voxet array
    """

    # download if not found
    repo = os.path.expanduser( '~/mapdata' )
    url = 'http://structure.harvard.edu/cvm-h/download/vx62.tar.bz2'
    version = os.path.basename( url ).split( '.' )[0]
    path = os.path.join( repo, version, 'bin' )
    if not os.path.exists( path ):
        if not os.path.exists( repo ):
            os.makedirs( repo )
        f = os.path.join( repo, os.path.basename( url ) )
        if not os.path.exists( f ):
            print( 'Downloading %s' % url )
            urllib.urlretrieve( url, f )
        if os.system( 'tar jxv -C %r -f %r' % (repo, f) ):
            sys.exit( 'Error extraction tar file' )

    # lookup property and voxet
    if property in property2d:
        property = property2d[property]
        voxet = 'interfaces'
    if property in property3d:
        property = property3d[property]
    if voxet in voxet3d:
        voxet = voxet3d[voxet]

    # load voxet
    f = os.path.join( path, voxet + '.vo' )
    voxet = gocad.voxet( f, property )['1']

    # extent
    x, y, z = voxet['AXIS']['O']
    u, v, w = voxet['AXIS']['U'][0], voxet['AXIS']['V'][1], voxet['AXIS']['W'][2]
    extent = (x, x + u), (y, y + v), (z, z + w)

    # data
    if property == None:
        return voxet, extent
    else:
        data = voxet['PROP'][property]['DATA']
        if property == 'rho':
            data *= 0.001
            data = 1000.0 * (data * (1.6612 + data * (-0.4721 + data * (0.0671 +
                f * (-0.0043 + data * 0.000106)))))
            data = np.maximum( data, 1000.0 )
        return data, extent

class Extraction():
    """
    SCEC CVM-H extraction.

    Init parameters
    ---------------
        2d property: 'topo', 'base', or 'moho'
        3d property: 'rho', 'vp', 'vs', or 'tag'
        3d voxet list: ['mantle', 'crust', 'lab']

    Call parameters
    ---------------
        x, y, z: sample coordinate arrays.
        out (optional): output array, same shape as x, y, and z.
        interpolation: 'nearest', 'linear'

    Returns
    -------
        f: property samples at coordinates (x, y, z)
    """
    def __init__( self, property, voxet=['mantle', 'crust', 'lab'] ):
        self.property = property
        if property in property2d:
            self.voxet = [ read_voxet( property ) ]
        else:
            self.voxet = []
            for vox in voxet:
                self.voxet += [ read_voxet( property, vox ) ]
        return
    def __call__( self, x, y, z=None, out=None, interpolation='linear' ):
        if out == None:
            out = np.empty_like( x )
            out.fill( np.nan )
        for data, extent in self.voxet:
            if self.property in property2d:
                data = data.reshape( data.shape[:2] )
                coord.interp2( extent[:2], data, (x, y), out, method=interpolation )
            else:
                coord.interp3( extent, data, (x, y, z), out, method=interpolation )
        return out

# continue with test if run from the command line
if __name__ == '__main__':
    import matplotlib.pyplot as plt

    topo = Extraction( 'topo' )
    vp = Extraction( 'vp' )

    d = 250.0
    x, y = extent[:2]
    x = np.arange( x[0], x[1] + d, 2 * d )
    y = np.arange( y[0], y[1] + d, 2 * d )
    y, x = np.meshgrid( y, x )
    z = topo( x, y ) - 100.0

    f = vp( x, y, z, interpolation='nearest' )
    fig = plt.figure()
    fig.clf()
    ax = plt.gca()
    ax.imshow( f.T, vmin=0.0, vmax=8000.0, origin='lower', interpolation='nearest' )
    ax.axis( 'image' )

    f = vp( x, y, z, interpolation='linear' )
    fig = plt.figure()
    fig.clf()
    ax = plt.gca()
    ax.imshow( f.T, vmin=0.0, vmax=8000.0, origin='lower', interpolation='nearest' )
    ax.axis( 'image' )

    plt.show()

