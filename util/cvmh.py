#!/usr/bin/env python
"""
SCEC Community Velocity Model (CVM-H) extraction tool
"""
import os, sys, urllib, pyproj
import numpy as np
import coord, gocad

# projection
proj = pyproj.Proj( proj='utm', zone=11, datum='NAD27', ellps='clrk66' )

def voxet( name, property_id=None ):
    """
    Download and read SCEC CVM-H voxet.

    Should not be used directly. Use Extraction() instead.
    name: 'CVM_CM', 'CVM_LR', 'CVM_HR', or 'interfaces'.
    property_id: '1', '2', or '3'.
    """
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
    f = os.path.join( path, name + '.vo' )
    vox = gocad.voxet( f, property_id )['1']
    if property_id == None:
        return vox
    else:
        origin  = vox['AXIS']['O']
        j, k, l = vox['AXIS']['N']
        u, v, w = vox['AXIS']['U'][0], vox['AXIS']['V'][1], vox['AXIS']['W'][2]
        delta = u / (j - 1), v / (k - 1), w / (l - 1)
        data = vox['PROP'][property_id]['DATA']
        return origin, delta, data

class Extraction():
    """
    SCEC CVM-H extraction.

    Initialize with property: 'rho', 'vp', 'vs', or 'tag'.
    Call with extaction coordinates: x, y, and z.
    """
    def __init__( self, property ):
        self.property = property
        if property in ('dem', 'topo'):
            self.voxet = [ voxet( 'interfaces', '1' ) ]
        else:
            id_ = {'rho': '1', 'vp': '1', 'vs': '3', 'tag': '2'}[property]
            self.voxet = []
            for name in 'CVM_CM', 'CVM_LR', 'CVM_HR':
                origin, delta, f = voxet( name, id_ )
                if property == 'rho':
                    f *= 0.001
                    f = 1000.0 * (f * (1.6612 + f * (-0.4721 + f * (0.0671 +
                        f * (-0.0043 + f * 0.000106)))))
                    f = np.maximum( f, 1000.0 )
                self.voxet += [ (origin, delta, f) ]
        return
    def __call__( self, x, y, z ):
        ff = np.empty_like( x )
        ff.fill( np.nan )
        for origin, delta, data in self.voxet:
            x0, y0, z0 = origin
            dx, dy, dz = delta
            f, i = coord.interp3( x0, y0, z0, dx, dy, dz, data, x, y, z )
            ff[...,i] = f[...,i]
        return f

# continue if run from the command line
if __name__ == '__main__':
    import pprint
    import matplotlib.pyplot as plt

    vox = voxet( 'interfaces' )
    pprint.pprint( vox )
    o, d, v = voxet( 'interfaces', '1' )

    fig = plt.gcf()
    fig.clf()
    ax = plt.gca()
    ax.imshow( v.squeeze().T, origin='lower', interpolation='nearest' )
    ax.axis( 'image' )
    fig.canvas.draw()
    fig.show()

