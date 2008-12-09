#!/usr/bin/env python
"Coordinate conversions"

def rotmat( strike, dip, rake ):
    """
    For given strike, dip, and rake, in degrees, and using the Aki & Richards
    convention of dip to the right of the strike vector, find rotation matrix from
    (slip, rake, normal) coordinate system, to (north, east, up) coordinate system.
    """
    from numpy import pi, cos, sin, dot, zeros, ones, array, asarray
    strike = pi / 180. * asarray( strike )
    dip    = pi / 180. * asarray( dip )
    rake   = pi / 180. * asarray( rake )
    zero   = zeros( strike.shape )
    one    = ones( strike.shape )
    A = array([
        [ sin(strike), -cos(strike), zero ],
        [ cos(strike),  sin(strike), zero ],
        [ zero,         zero,        one  ],
    ])
    B = array([
        [ one,  zero,      zero     ],
        [ zero, cos(dip), -sin(dip) ],
        [ zero, sin(dip),  cos(dip) ],
    ])
    C = array([
        [ cos(rake), -sin(rake), zero ],
        [ sin(rake),  cos(rake), zero ],
        [ zero,       zero,      one  ],
    ])
    return dot( dot( A, B ), C ) )

def ll2ts( lon, lat ):
    "Project lon/lat to UTM and rotate to TeraShake coordinates"
    import pyproj, numpy
    proj = pyproj.Proj( proj='utm', zone=11, ellps='WGS84' )
    rot = 40.
    lon0, lat0 = -121., 34.5
    x0, y0 = proj( lon0, lat0 )
    c = numpy.cos( rot * numpy.pi / 180. )
    s = numpy.sin( rot * numpy.pi / 180. )
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
    import pyproj, numpy
    proj = pyproj.Proj( proj='utm', zone=11, ellps='WGS84' )
    rot = 40.
    lon0, lat0 = -121., 34.5
    x0, y0 = proj( lon0, lat0 )
    c = numpy.cos( rot * numpy.pi / 180. )
    s = numpy.sin( rot * numpy.pi / 180. )
    xx = numpy.asarray( x )
    yy = numpy.asarray( y )
    x =  c * xx + s * yy + x0
    y = -s * xx + c * yy + y0
    lon, lat = proj( x, y, inverse=True )
    return lon, lat

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

