#!/usr/bin/env python
"""
Coordinate conversions
"""

def matmul( A, B ):
    """
    Vectorized matrix multiplication. Not the same as numpy.dot()
    """
    from numpy import array, newaxis
    A = array( A )
    B = array( B )
    return ( A[:,:,newaxis,...] * B ).sum( axis=1 )

def solve2( A, b ):
    """
    Vectorized 2x2 linear equation solver
    """
    from numpy import array
    A = array( A )
    b = array( b ) / ( A[0,0]*A[1,1] - A[0,1]*A[1,0] )
    return array([ b[0]*A[1,1] - b[1]*A[0,1],
                   b[1]*A[0,0] - b[0]*A[1,0] ])

def slipvectors( strike, dip, rake ):
    """
    For given strike, dip, and rake (degrees), using the Aki & Richards convention
    of dip to the right of the strike vector, find the rotation matrix R from world
    coordinates (east, north, up) to fault local coordinates (slip, rake, normal).
    The transpose R^T performs the reverse rotation from fault local coordinates to
    world coordinates.  Rows of R are axis unit vectors of the fault local space in
    world coordinates.  Columns of R are axis unit vectors of the world space in
    fault local coordinates.
    """
    from numpy import pi, array, ones, zeros, cos, sin
    strike = pi / 180.0 * array( strike )
    dip    = pi / 180.0 * array( dip ) 
    rake   = pi / 180.0 * array( rake )
    u = ones( strike.shape )
    z = zeros( strike.shape )
    c = cos( rake )
    s = sin( rake )
    A = array([[ c, s, z ], [ -s, c, z ], [ z, z, u ]])
    c = cos( dip )
    s = sin( dip )
    B = array([[ u, z, z ], [ z, c, s ], [ z, -s, c ]])
    c = cos( strike )
    s = sin( strike )
    C = array([[ s, c, z ], [ -c, s, z ], [ z, z, u ]])
    return matmul( matmul( A, B ), C )

def interp2( x0, y0, dx, dy, z, xi, yi, extrapolate=False ):
    """
    2D interpolation on a regular grid
    """
    from numpy import array, int32, minimum, maximum, nan
    z  = array( z )
    xi = ( array( xi ) - x0 ) / dx
    yi = ( array( yi ) - y0 ) / dy
    j = int32( xi )
    k = int32( yi )
    n = z.shape
    if not extrapolate:
        i = (j < 0) | (j > n[0]-2) | (k < 0) | (k > n[1]-2)
    j = minimum( maximum( j, 0 ), n[0]-2 )
    k = minimum( maximum( k, 0 ), n[1]-2 )
    zi = ( ( 1.0 - xi + j ) * ( 1.0 - yi + k ) * z[...,j,k]
         + ( 1.0 - xi + j ) * (       yi - k ) * z[...,j,k+1]
         + (       xi - j ) * ( 1.0 - yi + k ) * z[...,j+1,k]
         + (       xi - j ) * (       yi - k ) * z[...,j+1,k+1] )
    if not extrapolate: # untested
        zi[...,i] = nan
    return zi

def ibilinear( xx, yy, xi, yi ):
    """
    Vectorized inverse bilinear interpolation
    """
    import sys
    from numpy import array
    xx, yy = array( xx ), array( yy )
    xi = array( xi ) - 0.25 * xx.sum(0).sum(0)
    yi = array( yi ) - 0.25 * yy.sum(0).sum(0)
    j1 = 0.25 * array([ [ xx[1,:] - xx[0,:], xx[:,1] - xx[:,0] ],
                        [ yy[1,:] - yy[0,:], yy[:,1] - yy[:,0] ] ]).sum(2)
    j2 = 0.25 * array([   xx[1,1] - xx[0,1] - xx[1,0] + xx[0,0],
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

def ll2cvmh( x, y, inverse=False ):
    import pyproj
    from numpy import array
    projection = pyproj.Proj( proj='utm', zone=11, datum='NAD27', ellps='clrk66' )
    x = array( x )
    y = array( y )
    x, y = projection( x, y, inverse=inverse )
    return array( [x, y] )

def ll2cmu( x, y, inverse=False ):
    """
    CMU TeraShake coordinates projection
    """
    import sys
    from numpy import array
    xx = [ -121.0, -118.951292 ], [ -116.032285, -113.943965 ]
    yy = [   34.5,   36.621696 ], [   31.082920,   33.122341 ]
    if inverse:
        x, y = interp2( 0.0, 0.0, 600000.0, 300000.0, [xx,yy], x, y, True )
    else:
        x, y = ibilinear( xx, yy, x, y )
        x = ( x + 1.0 ) * 300000.0
        y = ( y + 1.0 ) * 150000.0
    return array( [x, y] )

def ll2xy( x, y, inverse=False, projection=None, rot=40.0, lon0=-121.0, lat0=34.5,  ):
    """
    UTM TeraShake coordinate projection
    """
    import pyproj
    from numpy import array, pi, cos, sin
    if not projection:
        projection = pyproj.Proj( proj='utm', zone=11, ellps='WGS84' )
    x0, y0 = projection( lon0, lat0 )
    c = cos( pi / 180.0 * rot )
    s = sin( pi / 180.0 * rot )
    x = array( x )
    y = array( y )
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
    return array( [x, y] )

def rotation( lon, lat, projection=ll2xy, eps=0.001 ):
    """
    mat, theta = rotation( lon, lat, proj )

    Rotation matrix and clockwise rotation angle to transform components in the
    geographic coordinate system to components in the local system.
    local_components = matmul( mat, components )
    local_strike = strike + theta
    """
    from numpy import array, sqrt, arctan2, pi
    lon = array( [[lon-eps, lon    ], [lon+eps, lon    ]] )
    lat = array( [[lat,     lat-eps], [lat,     lat+eps]] )
    x, y = projection( lon, lat )
    x = x[1] - x[0]
    y = y[1] - y[0]
    s = 1.0 / sqrt( x*x + y*y )
    mat = array([ s*x, s*y ])
    theta = 180.0 / pi * arctan2( mat[0], mat[1] )
    theta = 0.5 * theta.sum(0) - 45.0
    return mat, theta

def rot_sym_tensor( w1, w2, rot ):
    """
    Rotate symmetric 3x3 tensor stored as diagonal and off-diagonal vectors.
    w1:  components w11, w22, w33
    w2:  components w23, w31, w12
    rot: rotation matrix
    """
    from numpy import array, diag
    rot = array( rot )
    mat = diag( w1 )
    mat.flat[[5,6,1]] = w2
    mat.flat[[7,2,3]] = w2
    mat = matmul( matmul( rot, mat ), rot.T )
    w1  = diag( mat )
    w2  = mat.flat[[5,6,1]]
    return w1, w2

def rotmat( x, origin=(0,0,0), upvector=(0,0,1) ):
    """
    Given a position vector x, find the rotation matrix to r,h,v coordinates.
    """
    from numpy import array, sqrt, cross
    x = array( x ) - array( origin )
    nr = x / sqrt( (x*x).sum() )
    nh = cross( upvector, nr )
    if all( nh == 0.0 ):
        nh = cross( (1,0,0), nr )
    if all( nh == 0.0 ):
        nh = cross( (0,1,0), nr )
    nh = nh / sqrt( (nh*nh).sum() )
    nv = cross( nr, nh )
    nv = nv / sqrt( (nv*nv).sum() )
    return array([ nr, nh, nv ])

if __name__ == '__main__':
    import sys, getopt
    from numpy import loadtxt
    opts, args = getopt.getopt( sys.argv[1:], 'i' )
    for f in args:
        x, y = loadtxt( f, unpack=True )
        if '-i' in opts[0]:
            x, y = ll2xy( x, y, inverse=True )
        else:
            x, y = ll2xy( x, y )
        for xx, yy in zip( x, y ):
            print( xx, yy )

