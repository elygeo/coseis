#!/usr/bin/env python
"""
SCEC Community Velocity Model (CVM-H) extraction tool
"""
import os, sys, urllib, pyproj
import numpy as np
import coord, gocad

# projection
proj = pyproj.Proj( proj='utm', zone=11, datum='NAD27', ellps='clrk66' )

# lookup tables
voxet3d = { 'mantle': 'CVM_CM', 'lowres': 'CVM_LR', 'hires': 'CVM_HR' }
prop3d = { 'rho': '1', 'vp': '1', 'vs': '3', 'tag': '2' }
prop2d = { 'topo': '1', 'basement': '2', 'moho': '3' }

def read_voxet( property, voxet=None ):
    """
    Download and read SCEC CVM-H voxet.

    2d options
    ----------
        property: 'topo', 'basement', 'moho'

    3d options
    ----------
        property: 'rho', 'vp', 'vs', or 'tag'
        voxet: 'mantle', 'lores', 'hires'
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

    Initialization with property: 'topo', 'basement', 'moho', 'rho', 'vp', 'vs', or 'tag'
    Call with extraction coordinates: x, y, z
    """
    def __init__( self, property ):
        self.property = property
        if property in prop2d:
            self.voxet = [ read_voxet( property ) ]
        else:
            self.voxet = []
            for vox in 'mantle', 'lowres', 'hires':
                self.voxet += [ read_voxet( property, vox ) ]
        return
    def __call__( self, x, y, z=None ):
        f = np.empty_like( x )
        f.fill( np.nan )
        for origin, delta, data in self.voxet:
            if self.property in prop2d:
                coord.interp2( origin, delta, data, (x, y), f )
            else:
                coord.interp3( origin, delta, data, (x, y, z), f )
        return f

# continue with test if run from the command line
if __name__ == '__main__':
    import matplotlib.pyplot as plt

    topo = Extraction( 'topo' )
    vp = Extraction( 'vp' )

    x = np.arange( -118, -116, 0.01)
    y = np.arange( 33, 35, 0.01)
    y, x = np.meshgrid( y, x )
    x, y = proj( x, y )
    z = topo( x, y ) - 300.0
    f = vp( x, y, z )

    fig = plt.figure()
    ax = plt.gca()
    ax.imshow( z.T, origin='lower', interpolation='nearest' )
    ax.axis( 'image' )

    fig = plt.figure()
    ax = plt.gca()
    ax.imshow( f.T, origin='lower', interpolation='nearest' )
    ax.axis( 'image' )

    plt.show()

