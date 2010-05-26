#!/usr/bin/env python
"""
SCEC Community Velocity Model (CVM-H) extraction tool
"""
import os, sys, urllib, pyproj
import numpy as np
import coord, gocad
reload( coord )
reload( gocad )

# projection
proj = pyproj.Proj( proj='utm', zone=11, datum='NAD27', ellps='clrk66' )

# lookup tables
prop2d = {'topo': '1', 'base': '2', 'moho': '3'}
prop3d = {'rho': '1', 'vp': '1', 'vs': '3', 'tag': '2'}
voxet3d = {'mantle': 'CVM_CM', 'crust': 'CVM_LR', 'lab': 'CVM_HR'}

def read_voxet( property, voxet=None ):
    """
    Download and read SCEC CVM-H voxet.

    Parameters
    ----------
        2d property: 'topo', 'base', or 'moho'
        3d property: 'rho', 'vp', 'vs', or 'tag'
        3d voxet: 'mantle', 'crust', 'lab'

    Returns
    -------
        origin: (x0, y0, z0)
        delta: (dx, dy, dz)
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

    # lookup property
    if property in prop2d:
        prop = prop2d[property] 
        vox = 'interfaces'
    else:
        prop = prop3d[property] 
        vox = voxet3d[voxet] 

    # load voxet
    f = os.path.join( path, vox + '.vo' )
    vox = gocad.voxet( f, prop )['1']

    # axes origin and step size
    j, k, l = vox['AXIS']['N']
    u, v, w = vox['AXIS']['U'][0], vox['AXIS']['V'][1], vox['AXIS']['W'][2]
    if property in prop2d:
        origin = vox['AXIS']['O'][:2]
        delta = u / (j - 1), v / (k - 1)
    else:
        origin = vox['AXIS']['O']
        delta = u / (j - 1), v / (k - 1), w / (l - 1)

    # data
    data = vox['PROP'][prop]['DATA']
    if property in prop2d:
        data = data.reshape( (j, k) )
    if property == 'rho':
        data *= 0.001
        data = 1000.0 * (data * (1.6612 + data * (-0.4721 + data * (0.0671 +
            f * (-0.0043 + data * 0.000106)))))
        data = np.maximum( data, 1000.0 )

    return origin, delta, data

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
 
    Returns
    -------
        f: property samples at coordinates (x, y, z)
    """
    def __init__( self, property, voxet=['mantle', 'crust', 'lab'] ):
        self.property = property
        if property in prop2d:
            self.voxet = [ read_voxet( property ) ]
        else:
            self.voxet = []
            for vox in voxet:
                self.voxet += [ read_voxet( property, vox ) ]
        return
    def __call__( self, x, y, z=None, out=None ):
        if out == None:
            out = np.empty_like( x )
            out.fill( np.nan )
        for origin, delta, data in self.voxet:
            if self.property in prop2d:
                coord.interp2( origin, delta, data, (x, y), out )
            else:
                coord.interp3( origin, delta, data, (x, y, z), out )
        return out

# continue with test if run from the command line
if __name__ == '__main__':
    import matplotlib.pyplot as plt

    o, d, f = read_voxet( 'topo' )
    fig = plt.figure(1)
    fig.clf()
    ax = plt.gca()
    ax.imshow( f.T, origin='lower', interpolation='nearest' )
    ax.axis( 'image' )

    topo = Extraction( 'topo' )
    vp = Extraction( 'vp', ['crust'] )

    x = np.arange( -120.0, -114.5, 0.02 )
    y = np.arange( 32.0, 35.6, 0.02 )

    x = np.arange( -121.2, -113.3, 0.02 )
    y = np.arange( 30.9, 36.7, 0.02 )

    y, x = np.meshgrid( y, x )
    x, y = proj( x, y )
    z = topo( x, y ) - 400.0
    f = vp( x, y, z )

    fig = plt.figure(3)
    fig.clf()
    ax = plt.gca()
    ax.imshow( f.T, origin='lower', interpolation='nearest' )
    ax.axis( 'image' )

    plt.show()

