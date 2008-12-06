#!/usr/bin/env python
"Convert between lon/lat and TeraShake coordinates."

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

