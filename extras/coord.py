#!/usr/bin/env python
"""
Coordinate conversions
"""
import sys, numpy
import getopt

rearth = 6370000.0

def downsample_sphere( f, d ):
    """
    Down-sample node-registered spherical surface with averaging.

    The indices of the 2D array f are, respectively, longitude and latitude.
    d is the decimation interval which must be odd.
    """
    n = f.shape
    ii = numpy.arange( d ) - (d - 1) / 2
    jj = numpy.arange( 0, n[0], d )
    kk = numpy.arange( 0, n[1], d )
    nn = jj.size, kk.size
    ff = numpy.zeros( nn, f.dtype )
    jj, kk = numpy.ix_( jj, kk )
    for dk in ii:
        k = n[1] - 1 - abs( n[1] - 1 - abs( dk + kk ) )
        for dj in ii:
            j = (jj + dj) % n[0]
            ff = ff + f[j,k]
    ff[:,0] = ff[:,0].mean()
    ff[:,-1] = ff[:,-1].mean()
    ff *= 1.0 / (d * d)
    return ff

def dot2( A, B ):
    """
    Vectorized 2d dot product (matrix multiplication).

    The first two dimensions index the matrix rows and columns. The remaining
    dimensions index multiple matrices for which dot products are computed
    separately. This differs from numpy.dot, where the higher dimensions index
    N-dimensional 'matrices.' Also, broadcasting is effectively reversed by using
    the transpose, so that ones are appended to the shape if necessary, rather than
    prepended.

    This could be made more general with arbitrary maximum matrix dimension, at
    the cost of code clarity.
    """
    A = numpy.array( A ).T
    B = numpy.array( B ).T
    i = -min( A.ndim, 2 )
    if A.shape[i] != B.shape[-1]:
        sys.exit( 'Incompatible arrays for dot product' )
    elif A.ndim == 1:
        return ( A * B ).T.sum( axis=0 )
    elif B.ndim == 1:
        return ( A * B[...,None] ).T.sum( axis=1 )
    else:
        return ( A[...,None,:,:] * B[...,None] ).T.sum( axis=1 )

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
    return dot2( dot2( A, B ), C )

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
    j = numpy.array( xi, 'i' )
    k = numpy.array( yi, 'i' )
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

def rotation( lon, lat, projection, eps=100.0 ):
    """
    mat, theta = rotation( lon, lat, projection )

    Rotation matrix and clockwise rotation angle to transform components in the
    geographic coordinate system to components in the local system.
    local_components = dot2( mat, components )
    local_strike = strike + theta
    """
    dlon = eps * 180.0 / (numpy.pi * rearth) * numpy.cos( numpy.pi / 180.0 * lat )
    dlat = eps * 180.0 / (numpy.pi * rearth)
    lon = numpy.array( [
        [lon - dlon, lon ],
        [lon + dlon, lon ],
    ] )
    lat = numpy.array( [
        [lat, lat - dlat],
        [lat, lat + dlat],
    ])
    x, y = projection( lon, lat )
    x = x[1] - x[0]
    y = y[1] - y[0]
    s = 1.0 / numpy.sqrt( x * x + y * y )
    mat = numpy.array( [s * x, s * y] )
    theta = 180.0 / numpy.pi * numpy.arctan2( mat[0], mat[1] )
    theta = 0.5 * theta.sum(0) - 45.0
    return mat, theta

def rotation3( lon, lat, dep, projection, eps=100.0 ):
    """
    mat = rotation( lon, lat, dep, projection )

    Rotation matrix to transform components in the
    geographic coordinate system to components in the local system.
    local_components = dot2( mat, components )
    """
    dlon = eps * 180.0 / (numpy.pi * rearth) * numpy.cos( numpy.pi / 180.0 * lat )
    dlat = eps * 180.0 / (numpy.pi * rearth)
    lon = numpy.array( [
        [lon - dlon, lon, lon],
        [lon + dlon, lon, lon],
    ] )
    lat = numpy.array( [
        [lat, lat - dlat, lat],
        [lat, lat + dlat, lat],
    ] )
    dep = numpy.array( [
        [dep, dep, dep - eps],
        [dep, dep, dep + eps],
    ] )
    x, y, z = projection( lon, lat, dep )
    x = x[1] - x[0]
    y = y[1] - y[0]
    z = z[1] - z[0]
    s = 1.0 / numpy.sqrt( x * x + y * y + z * z )
    mat = numpy.array( [s * x, s * y, s * z] )
    return mat

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
    mat = dot2( dot2( rot, mat ), rot.T )
    w1  = numpy.diag( mat )
    w2  = mat.flat[[5, 6, 1]]
    return w1, w2

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

def llr2xyz( x, y, z, inverse=False ):
    """
    Geographic to rectangular coordinate conversion.

    x <-> lon, y <-> lat, z <-> r
    """
    x = numpy.array( x )
    y = numpy.array( y )
    z = numpy.array( z )
    if inverse:
        r = numpy.sqrt( x * x + y * y + z * z )
        x = numpy.arctan2( y, x )
        y = numpy.arcsin( z / r )
        x = 180.0 / numpy.pi * x
        y = 180.0 / numpy.pi * y
        return numpy.array( [x, y, r] )
    else:
        x  = numpy.pi / 180.0 * x
        y  = numpy.pi / 180.0 * y
        x_ = numpy.cos( x ) * numpy.cos( y ) * z
        y_ = numpy.sin( x ) * numpy.cos( y ) * z
        z  = numpy.sin( y ) * z
        return numpy.array( [x_, y_, z] )

def viewmatrix( azimuth, elevation, up=None ):
    """
    Compute transformation matrix from view azimuth and elevation.
    """
    if up == None:
          if 5.0 < abs( elevation ) < 175.0:
              up = 0, 0, 1
          else:
              up = 0, 1, 0
    z = llr2xyz( [azimuth], [90.0 - elevation], [1] ).T[0]
    x = numpy.cross( up, z )
    y = numpy.cross( z, x )
    x = x / numpy.sqrt( ( x * x ).sum() )
    y = y / numpy.sqrt( ( y * y ).sum() )
    z = z / numpy.sqrt( ( z * z ).sum() )
    return numpy.array( [x, y, z] ).T

def ll2ortho( x, y, z=None, lon0=-118.0, lat0=34.0, rot=0.0, rearth=6370000.0, inverse=False ):
    """
    Orthographic projection. Optional z coordinate has spherical curvature.

    x <-> lon, y <-> lat, z <-> r
    Useful for cuboid subsection of a spherical Earth.
    Pro: lateral and depth boundaries are normal to the Cartesian axes so
         PML absorbing boundaries may be used.
    Con: lateral boundaries and z grid lines are not purely vertical in the
         geographic coordinate system. Deflection from vertical increases
         with distance from the origin.
    """
    import pyproj
    projection = pyproj.Proj( proj='ortho', lon_0=lon0, lat_0=lat0 )
    c = numpy.cos( numpy.pi / 180.0 * rot )
    s = numpy.sin( numpy.pi / 180.0 * rot )
    x = numpy.array( x )
    y = numpy.array( y )
    if z == None:
        if inverse:
            x, y = c * x + s * y,  -s * x + c * y
            x, y = projection( x, y, inverse=True )
        else:
            x, y = projection( x, y, inverse=False )
            x, y = c * x - s * y,  s * x + c * y
        return numpy.array( [x, y] )
    else:
        if inverse:
            z -= numpy.sqrt( rearth ** 2 - x ** 2 - y ** 2 ) - rearth
            x, y = c * x + s * y, -s * x + c * y
            y -= y * z / rearth
            x -= x * z / rearth
            x, y = projection( x, y, inverse=True )
        else:
            x, y = projection( x, y, inverse=False )
            x += x * z / rearth
            y += y * z / rearth
            x, y = c * x - s * y,  s * x + c * y
            z += numpy.sqrt( rearth ** 2 - x ** 2 - y ** 2 ) - rearth
        return numpy.array( [x, y, z] )

def ll2xy( x, y, inverse=False, projection=None, rot=40.0, lon0=-121.0, lat0=34.5 ):
    """
    UTM TeraShake coordinate projection

    x <-> lon, y <-> lat, z <-> r
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
        x, y = c * x + s * y,  -s * x + c * y
        x = x + x0
        y = y + y0
        x, y = projection( x, y, inverse=True )
    else:
        x, y = projection( x, y, inverse=False )
        x = x - x0
        y = y - y0
        x, y = c * x - s * y,  s * x + c * y
    return numpy.array( [x, y] )

def ll2cvmh( x, y, inverse=False ):
    """
    Harvard CVM5 projection.

    x <-> lon, y <-> lat
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

    x <-> lon, y <-> lat
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

