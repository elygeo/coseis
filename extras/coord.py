#!/usr/bin/env python
"""
Coordinate conversions
"""
import sys, numpy
import getopt

def matmul( A, B ):
    """
    Vectorized matrix multiplication. Not the same as numpy.dot()
    """
    A = numpy.array( A )
    B = numpy.array( B )
    return ( A[:,:,None,...] * B ).sum( axis=1 )

def solve2( A, b ):
    """
    Vectorized 2x2 linear equation solver
    """
    A = numpy.array( A )
    b = numpy.array( b ) / (A[0,0]*A[1,1] - A[0,1]*A[1,0])
    return numpy.array( [b[0]*A[1,1] - b[1]*A[0,1],
                         b[1]*A[0,0] - b[0]*A[1,0]] )

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
    strike = numpy.pi / 180.0 * numpy.array( strike )
    dip    = numpy.pi / 180.0 * numpy.array( dip ) 
    rake   = numpy.pi / 180.0 * numpy.array( rake )
    u = numpy.ones( strike.shape )
    z = numpy.zeros( strike.shape )
    c = numpy.cos( rake )
    s = numpy.sin( rake )
    A = numpy.array( [[c, s, z], [-s, c, z], [z, z, u]] )
    c = numpy.cos( dip )
    s = numpy.sin( dip )
    B = numpy.array( [[u, z, z], [z, c, s], [z, -s, c]] )
    c = numpy.cos( strike )
    s = numpy.sin( strike )
    C = numpy.array( [[s, c, z], [-c, s, z], [z, z, u]] )
    return matmul( matmul( A, B ), C )

def source_tensors( R ):
    """
    Given a rotation matrix R from world coordinates (east, north, up) to fault
    local coordinates (slip, rake, normal), find tensor components that may be
    scaled by moment or potency to compute moment tensors or potency tensors,
    respectively.  Rows of R are axis unit vectors of the fault local space in
    world coordinates.  R can be computed from strike, dip and rake angles with the
    'slipvectors' routine.  The return value is a 3x3 matrix T specifying
    contributions to the tensor W:
    column 1 is the (shear)  strike contribution to W23, W31, W12
    column 2 is the (shear)  dip    contribution to W23, W31, W12
    column 3 is the (volume) normal contribution to W11, W22, W33
    The columns can unpacked conveniently by:
    Tstrike, Tdip, Tnormal = coord.sliptensors( strike, dip, rake )
    """
    strike, dip, normal = slipvectors( R )
    del( R )
    strike = 0.5 * ([
        strike[1] * normal[2] + normal[1] * strike[2],
        strike[2] * normal[0] + normal[2] * strike[0],
        strike[0] * normal[1] + normal[0] * strike[1],
    ])
    dip = 0.5 * ([
        dip[1] * normal[2] + normal[1] * dip[2],
        dip[2] * normal[0] + normal[2] * dip[0],
        dip[0] * normal[1] + normal[0] * dip[1],
    ])
    normal = normal * normal
    return numpy.array( [strike, dip, normal] )

def interp( x0, dx, z, xi, extrapolate=False ):
    """
    1D interpolation on a regular grid
    """
    z = numpy.array( z )
    xi = (numpy.array( xi ) - x0) / dx
    j = numpy.int32( xi )
    n = z.shape[-1]
    if not extrapolate:
        i = (j < 0) | (j > n-2)
    j = numpy.minimum( numpy.maximum( j, 0 ), n-2 )
    zi = (1.0 - xi + j) * z[...,j] + (xi - j) * z[...,j+1]
    if not extrapolate:
        zi[...,i] = numpy.nan
    return zi

def interp2( x0, y0, dx, dy, z, xi, yi, extrapolate=False ):
    """
    2D interpolation on a regular grid
    """
    z = numpy.array( z )
    xi = (numpy.array( xi ) - x0) / dx
    yi = (numpy.array( yi ) - y0) / dy
    j = numpy.int32( xi )
    k = numpy.int32( yi )
    n = z.shape
    if not extrapolate:
        i = (j < 0) | (j > n[-2]-2) | (k < 0) | (k > n[-1]-2)
    j = numpy.minimum( numpy.maximum( j, 0 ), n[-2]-2 )
    k = numpy.minimum( numpy.maximum( k, 0 ), n[-1]-2 )
    zi = ( ( 1.0 - xi + j ) * ( 1.0 - yi + k ) * z[...,j,k]
         + ( 1.0 - xi + j ) * (       yi - k ) * z[...,j,k+1]
         + (       xi - j ) * ( 1.0 - yi + k ) * z[...,j+1,k]
         + (       xi - j ) * (       yi - k ) * z[...,j+1,k+1] )
    if not extrapolate:
        zi[...,i] = numpy.nan
    return zi

def ibilinear( xx, yy, xi, yi ):
    """
    Vectorized inverse bilinear interpolation
    """
    xx = numpy.array( xx )
    yy = numpy.array( yy )
    xi = numpy.array( xi ) - 0.25 * xx.sum(0).sum(0)
    yi = numpy.array( yi ) - 0.25 * yy.sum(0).sum(0)
    j1 = 0.25 * numpy.array([ [ xx[1,:] - xx[0,:], xx[:,1] - xx[:,0] ],
                              [ yy[1,:] - yy[0,:], yy[:,1] - yy[:,0] ] ]).sum(2)
    j2 = 0.25 * numpy.array([   xx[1,1] - xx[0,1] - xx[1,0] + xx[0,0],
                                yy[1,1] - yy[0,1] - yy[1,0] + yy[0,0] ])
    x = dx = solve2( j1, [xi, yi] )
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

def ll2ortho( x, y, z=None, lon0=-118.1, lat0=34.1, rearth = 6370000.0, inverse=False ):
    """
    Orthographic projection with optional sphirical z coordinate.
    """
    import pyproj
    projection = pyproj.Proj( proj='ortho', lon_0=lon0, lat_0=lat0 )
    if z == None:
        x, y = projection( x, y, inverse=inverse )
        return numpy.array( [x, y] )
    else:
        if inverse:
            z -= numpy.sqrt( rearth ** 2 - x ** 2 - y ** 2 ) - rearth
            y -= y * z / rearth
            x -= x * z / rearth
            x, y = projection( x, y, inverse=True )
        else:
            x, y = projection( x, y, inverse=False )
            x += x * z / rearth
            y += y * z / rearth
            z += numpy.sqrt( rearth ** 2 - x ** 2 - y ** 2 ) - rearth
        return numpy.array( [x, y, z] )

def ll2cvmh( x, y, inverse=False ):
    """
    Harvard CVM5 projection.
    """
    import pyproj
    projection = pyproj.Proj( proj='utm', zone=11, datum='NAD27', ellps='clrk66' )
    x = numpy.array( x )
    y = numpy.array( y )
    x, y = projection( x, y, inverse=inverse )
    return numpy.array( [x, y] )

def ll2cmu( x, y, inverse=False ):
    """
    CMU TeraShake coordinates projection
    """
    xx = [-121.0, -118.951292], [-116.032285, -113.943965]
    yy = [  34.5,   36.621696], [  31.082920,   33.122341]
    if inverse:
        x, y = interp2( 0.0, 0.0, 600000.0, 300000.0, [xx, yy], x, y, True )
    else:
        x, y = ibilinear( xx, yy, x, y )
        x = (x + 1.0) * 300000.0
        y = (y + 1.0) * 150000.0
    return numpy.array( [x, y] )

def ll2xy( x, y, inverse=False, projection=None, rot=40.0, lon0=-121.0, lat0=34.5 ):
    """
    UTM TeraShake coordinate projection
    """
    import pyproj
    if not projection:
        projection = pyproj.Proj( proj='utm', zone=11, ellps='WGS84' )
    x0, y0 = projection( lon0, lat0 )
    c = numpy.cos( numpy.pi / 180.0 * rot )
    s = numpy.sin( numpy.pi / 180.0 * rot )
    x = numpy.array( x )
    y = numpy.array( y )
    if inverse:
        x, y =  c * x + s * y,  -s * x + c * y
        x = x + x0
        y = y + y0
        x, y = projection( x, y, inverse=True )
    else:
        x, y = projection( x, y )
        x = x - x0
        y = y - y0
        x, y = c * x - s * y,  s * x + c * y
    return numpy.array( [x, y] )

def rotation( lon, lat, projection=ll2xy, eps=0.001 ):
    """
    mat, theta = rotation( lon, lat, proj )

    Rotation matrix and clockwise rotation angle to transform components in the
    geographic coordinate system to components in the local system.
    local_components = matmul( mat, components )
    local_strike = strike + theta
    """
    lon = numpy.array( [[lon-eps, lon    ], [lon+eps, lon    ]] )
    lat = numpy.array( [[lat,     lat-eps], [lat,     lat+eps]] )
    x, y = projection( lon, lat )
    x = x[1] - x[0]
    y = y[1] - y[0]
    s = 1.0 / numpy.sqrt( x * x + y * y )
    mat = numpy.array( [s * x, s * y] )
    theta = 180.0 / numpy.pi * numpy.arctan2( mat[0], mat[1] )
    theta = 0.5 * theta.sum(0) - 45.0
    return mat, theta

def rot_sym_tensor( w1, w2, rot ):
    """
    Rotate symmetric 3x3 tensor stored as diagonal and off-diagonal vectors.
    w1:  components w11, w22, w33
    w2:  components w23, w31, w12
    rot: rotation matrix
    """
    rot = numpy.array( rot )
    mat = numpy.diag( w1 )
    mat.flat[[5, 6, 1]] = w2
    mat.flat[[7, 2, 3]] = w2
    mat = matmul( matmul( rot, mat ), rot.T )
    w1  = numpy.diag( mat )
    w2  = mat.flat[[5, 6, 1]]
    return w1, w2

def rotmat( x, origin=(0, 0, 0), upvector=(0, 0, 1) ):
    """
    Given a position vector x, find the rotation matrix to r,h,v coordinates.
    """
    x = numpy.array( x ) - numpy.array( origin )
    nr = x / numpy.sqrt( (x * x).sum() )
    nh = numpy.cross( upvector, nr )
    if all( nh == 0.0 ):
        nh = numpy.cross( (1, 0, 0), nr )
    if all( nh == 0.0 ):
        nh = numpy.cross( (0, 1, 0), nr )
    nh = nh / numpy.sqrt( (nh * nh).sum() )
    nv = numpy.cross( nr, nh )
    nv = nv / numpy.sqrt( (nv * nv).sum() )
    return numpy.array( [nr, nh, nv] )

def compass( azimuth, radians=False ):
    """
    Get named direction from azimuth.
    """
    if radians:
        azimuth *= 180.0 / numpy.pi
    names = (
        'N', 'NNE', 'NE', 'ENE',
        'E', 'ESE', 'SE', 'SSE',
        'S', 'SSW', 'SW', 'WSW',
        'W', 'WNW', 'NW', 'NNW',
    )
    return names[ int( azimuth / 22.5 + 16.0 ) % 16 ]

def command_line():
    """
    Process command line options.
    """
    opts, args = getopt.getopt( sys.argv[1:], 'i' )
    for f in args:
        x, y = numpy.loadtxt( f, unpack=True )
        if '-i' in opts[0]:
            x, y = ll2xy( x, y, inverse=True )
        else:
            x, y = ll2xy( x, y )
        for xx, yy in zip( x, y ):
            print( xx, yy )

if __name__ == '__main__':
    command_line()
