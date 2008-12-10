#!/usr/bin/env python
"Coordinate conversions"

def rotation( strike, dip, rake ):
    """
    For given strike, dip, and rake, in degrees, and using the Aki & Richards
    convention of dip to the right of the strike vector, find rotation matrix from
    (slip, rake, normal) coordinate system, to (north, east, up) coordinate system.
    """
    import numpy
    strike = numpy.pi / 180. * numpy.asarray( strike )
    dip    = numpy.pi / 180. * numpy.asarray( dip ) 
    rake   = numpy.pi / 180. * numpy.asarray( rake )
    u = numpy.ones( strike.shape )
    z = numpy.zeros( strike.shape )
    c = numpy.cos( strike )
    s = numpy.sin( strike )
    A = numpy.array([[ s, -c, z ], [ c, s, z ], [ z, z, u ]])
    c = numpy.cos( dip )
    s = numpy.sin( dip )
    B = numpy.array([[ u, z, z ], [ z, c, -s ], [ z, s, c ]])
    c = numpy.cos( rake )
    s = numpy.sin( rake )
    C = numpy.array([[ c, -s, z ], [ s, c, z ], [ z, z, u ]])
    return numpy.dot( numpy.dot( C.T, B.T ), A.T ).T

def ll2ts( lon, lat ):
    "Project lon/lat to UTM and rotate to TeraShake coordinates"
    import numpy, pyproj
    proj = pyproj.Proj( proj='utm', zone=11, ellps='WGS84' )
    rot = 40.
    lon0, lat0 = -121., 34.5
    x0, y0 = proj( lon0, lat0 )
    c = numpy.cos( numpy.pi / 180. * rot )
    s = numpy.sin( numpy.pi / 180. * rot )
    lon = numpy.asarray( lon )
    lat = numpy.asarray( lat )
    x, y = proj( lon, lat )
    xx = x - x0
    yy = y - y0
    x = c * xx - s * yy
    y = s * xx + c * yy
    return x, y

def ts2ll( x, y ):
    "Rotate TeraShake coordinates to UTM and inverse-project to lon/lat"
    import numpy, pyproj
    proj = pyproj.Proj( proj='utm', zone=11, ellps='WGS84' )
    rot = 40.
    lon0, lat0 = -121., 34.5
    x0, y0 = proj( lon0, lat0 )
    c = numpy.cos( numpy.pi / 180. * rot )
    s = numpy.sin( numpy.pi / 180. * rot )
    xx = numpy.asarray( x )
    yy = numpy.asarray( y )
    x =  c * xx + s * yy + x0
    y = -s * xx + c * yy + y0
    lon, lat = proj( x, y, inverse=True )
    return lon, lat

def tsrotation( x, y ):
    "Rotation matrix for TeraShake coordinates"
    import numpy
    lon0, lat0 = ts2ll( x, y )
    eps = 0.01
    lon = [ lon0-eps, lon0, lon0+eps, lon0 ]
    lat = [ lat0, lat0-eps, lat0, lat0+eps ]
    x, y = ll2ts( lon, lat )
    x = x[2:] - x[:2]
    y = y[2:] - y[:2]
    s = 1. / numpy.sqrt( x*x + y*y )
    mat = numpy.array([ s*x, s*y ])
    phi = 180. / numpy.pi * numpy.arctan2( mat[1], mat[0] )
    phi[1] = phi[1] - 90.
    return mat, phi

if __name__ == '__main__':
    import sys, getopt, numpy
    opts, args = getopt.getopt( sys.argv[1:], 'i' )
    for f in args:
        x0, y0 = numpy.loadtxt( f, unpack=True )
        if '-i' in opts[0]:
            x1, y1 = ts2ll( x0, y0 )
        else:
            x1, y1 = ll2ts( x0, y0 )
        for x, y in zip( x1, y1 ):
            print x, y

