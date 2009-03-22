#!/usr/bin/env python
"""Coordinate conversions"""

def matmul( A, B ):
    """Vectorized matrix multiplication. Not the same as numpy.dot()"""
    import numpy
    A = numpy.array( A )
    B = numpy.array( B )
    return ( A[:,:,numpy.newaxis,...] * B ).sum( axis=1 )

def solve2( A, b ):
    """Vectorized 2x2 linear equation solver"""
    from numpy import array as _
    A = _( A )
    b = _( b ) / ( A[0,0]*A[1,1] - A[0,1]*A[1,0] )
    return _([ b[0]*A[1,1] - b[1]*A[0,1],
               b[1]*A[0,0] - b[0]*A[1,0] ])

def slipvectors( strike, dip, rake ):
    """
    For given strike, dip, and rake (degrees), using the Aki & Richards
    convention of dip to the right of the strike vector, find the transposed
    rotation matrix from the (slip, rake, normal) coordinate system, to the (east,
    north, up) coordinate system.  The rows of the transposed matrix are the unit
    normals for the slip, rake, and fault normal directions.
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
    return matmul( matmul( A, B ), C ).swapaxes( 0, 1 )

def interp2( x0, y0, dx, dy, z, xi, yi, extrapolate=False ):
    """2D interpolation on a regular grid"""
    import numpy
    z  = numpy.asarray( z )
    xi = ( numpy.asarray( xi ) - x0 ) / dx
    yi = ( numpy.asarray( yi ) - y0 ) / dy
    j = numpy.int32( xi )
    k = numpy.int32( yi )
    n = z.shape
    if not extrapolate:
        i = (j < 0) | (j > n[0]-2) | (k < 0) | (k > n[1]-2)
    j = numpy.minimum( numpy.maximum( j, 0 ), n[0]-2 )
    k = numpy.minimum( numpy.maximum( k, 0 ), n[1]-2 )
    zi = ( 1. - xi + j ) * ( 1. - yi + k ) * z[...,j,k] \
       + ( 1. - xi + j ) * (      yi - k ) * z[...,j,k+1] \
       + (      xi - j ) * ( 1. - yi + k ) * z[...,j+1,k] \
       + (      xi - j ) * (      yi - k ) * z[...,j+1,k+1]
    if not extrapolate: # untested
        zi[...,i] = numpy.nan
    return zi

def ibilinear( xx, yy, xi, yi ):
    """Vectorized inverse bilinear interpolation"""
    import sys
    from numpy import array as _
    xx, yy = _( xx ), _( yy )
    xi = _( xi ) - 0.25 * xx.sum(0).sum(0)
    yi = _( yi ) - 0.25 * yy.sum(0).sum(0)
    j1 = 0.25 * _([ [ xx[1,:] - xx[0,:], xx[:,1] - xx[:,0] ],
                    [ yy[1,:] - yy[0,:], yy[:,1] - yy[:,0] ] ]).sum(2)
    j2 = 0.25 * _([   xx[1,1] - xx[0,1] - xx[1,0] + xx[0,0],
                      yy[1,1] - yy[0,1] - yy[1,0] + yy[0,0] ])
    x = dx = solve2( j1, [xi,yi] )
    i = 0
    while( abs( dx ).max() > 1e-6 ):
        i += 1
        if i > 10:
            sys.exit( 'inverse bilinear interpolation did not converge' )
        j = [ [ j1[0,0] + j2[0]*x[1], j1[0,1] + j2[0]*x[0] ],
              [ j1[1,0] + j2[1]*x[1], j1[1,1] + j2[1]*x[0] ] ]
        b = [ xi - j1[0,0]*x[0] - j1[0,1]*x[1] - j2[0]*x[0]*x[1],
              yi - j1[1,0]*x[0] - j1[1,1]*x[1] - j2[1]*x[0]*x[1] ]
        dx = solve2( j, b )
        x  = x + dx
    return x

def ll2cmu( x, y, inverse=False ):
    """CMU TeraShake coordinates projection"""
    import numpy, sys
    xx = [ -121.0, -118.951292 ], [ -116.032285, -113.943965 ]
    yy = [   34.5,   36.621696 ], [   31.082920,   33.122341 ]
    if inverse:
        x, y = interp2( 0., 0., 600000., 300000., [xx,yy], x, y, True )
    else:
        x, y = ibilinear( xx, yy, x, y )
        x = ( x + 1. ) * 300000.
        y = ( y + 1. ) * 150000.
    return numpy.array( [x, y] )

def ll2xy( x, y, inverse=False, projection=None, rot=40., lon0=-121., lat0=34.5,  ):
    """UTM TeraShake coordinate projection"""
    import numpy, pyproj
    if not projection:
        projection = pyproj.Proj( proj='utm', zone=11, ellps='WGS84' )
    x0, y0 = projection( lon0, lat0 )
    c = numpy.cos( numpy.pi / 180. * rot )
    s = numpy.sin( numpy.pi / 180. * rot )
    x = numpy.asarray( x )
    y = numpy.asarray( y )
    if inverse:
        x, y =  c*x + s*y, -s*x + c*y
        x = x + x0
        y = y + y0
        x, y = projection( x, y, inverse=True )
    else:
        x, y = projection( x, y )
        x = x - x0
        y = y - y0
        x, y = c*x - s*y, s*x + c*y
    return numpy.array( [x, y] )

def rotation( lon, lat, projection=ll2xy, eps=0.001 ):
    """
    mat, theta = rotation( lon, lat, proj )

    Rotation matrix and clockwise rotation angle to transform components in the
    geographic coordinate system to components in the local system.
    local_components = dot( mat, components )
    local_strike = strike + theta
    """
    import numpy
    lon = numpy.asarray( [[lon-eps, lon    ], [lon+eps, lon    ]] )
    lat = numpy.asarray( [[lat,     lat-eps], [lat,     lat+eps]] )
    x, y = projection( lon, lat )
    x = x[1] - x[0]
    y = y[1] - y[0]
    s = 1. / numpy.sqrt( x*x + y*y )
    mat = numpy.array([ s*x, s*y ])
    theta = 180. / numpy.pi * numpy.arctan2( mat[0], mat[1] )
    theta = 0.5 * theta.sum() - 45.
    return mat, theta

if __name__ == '__main__':
    import sys, getopt, numpy
    opts, args = getopt.getopt( sys.argv[1:], 'i' )
    for f in args:
        x, y = numpy.loadtxt( f, unpack=True )
        if '-i' in opts[0]:
            x, y = ll2xy( x, y, inverse=True )
        else:
            x, y = ll2xy( x, y )
        for xx, yy in zip( x, y ):
            print xx, yy

