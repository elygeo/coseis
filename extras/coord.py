#!/usr/bin/env python
"""
Coordinate conversions
"""
import sys
import numpy as np

rearth = 6370000.0

def dot2( A, B ):
    """
    Vectorized 2d dot product (matrix multiplication).

    The first two dimensions index the matrix rows and columns. The remaining
    dimensions index multiple matrices for which dot products are computed
    separately. This differs from np.dot, where the higher dimensions index
    N-dimensional 'matrices.' Also, broadcasting is effectively reversed by using
    the transpose, so that ones are appended to the shape if necessary, rather than
    prepended.

    This could be made more general with arbitrary maximum matrix dimension, at
    the cost of code clarity.
    """
    A = np.array( A ).T
    B = np.array( B ).T
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
    A = np.array( A )
    b = np.array( b )
    A /= (A[0,0] * A[1,1] - A[0,1] * A[1,0])
    return np.array( [b[0] * A[1,1] - b[1] * A[0,1],
                      b[1] * A[0,0] - b[0] * A[1,0]] )

def interp( x0, dx, z, xi, extrapolate=False ):
    """
    1D interpolation on a regular grid
    """
    z = np.array( z )
    xi = (np.array( xi ) - x0) / dx
    j = np.int32( xi )
    n = z.shape[-1]
    if not extrapolate:
        i = (j < 0) | (j > n-2)
    j = np.minimum( np.maximum( j, 0 ), n-2 )
    zi = (1.0 - xi + j) * z[...,j] + (xi - j) * z[...,j+1]
    if not extrapolate:
        zi[...,i] = np.nan
    return zi

def interp2( x0, y0, dx, dy, z, xi, yi, extrapolate=False ):
    """
    2D interpolation on a regular grid
    """
    z = np.array( z )
    xi = (np.array( xi ) - x0) / dx
    yi = (np.array( yi ) - y0) / dy
    j = np.array( xi, 'i' )
    k = np.array( yi, 'i' )
    n = z.shape
    if not extrapolate:
        i = (j < 0) | (j > n[-2]-2) | (k < 0) | (k > n[-1]-2)
    j = np.minimum( np.maximum( j, 0 ), n[-2]-2 )
    k = np.minimum( np.maximum( k, 0 ), n[-1]-2 )
    zi = ( ( 1.0 - xi + j ) * ( 1.0 - yi + k ) * z[...,j,k]
         + ( 1.0 - xi + j ) * (       yi - k ) * z[...,j,k+1]
         + (       xi - j ) * ( 1.0 - yi + k ) * z[...,j+1,k]
         + (       xi - j ) * (       yi - k ) * z[...,j+1,k+1] )
    if not extrapolate:
        zi[...,i] = np.nan
    return zi

def ibilinear( xx, yy, xi, yi ):
    """
    Vectorized inverse bilinear interpolation
    """
    xx = np.array( xx )
    yy = np.array( yy )
    xi = np.array( xi ) - 0.25 * xx.sum(0).sum(0)
    yi = np.array( yi ) - 0.25 * yy.sum(0).sum(0)
    j1 = 0.25 * np.array([ [ xx[1,:] - xx[0,:], xx[:,1] - xx[:,0] ],
                           [ yy[1,:] - yy[0,:], yy[:,1] - yy[:,0] ] ]).sum(2)
    j2 = 0.25 * np.array([   xx[1,1] - xx[0,1] - xx[1,0] + xx[0,0],
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

def rot_sym_tensor( w1, w2, rot ):
    """
    Rotate symmetric 3x3 tensor stored as diagonal and off-diagonal vectors.
    w1:  components w11, w22, w33
    w2:  components w23, w31, w12
    rot: rotation matrix
    """
    rot = np.array( rot )
    mat = np.diag( w1 )
    mat.flat[[5, 6, 1]] = w2
    mat.flat[[7, 2, 3]] = w2
    mat = dot2( dot2( rot, mat ), rot.T )
    w1  = np.diag( mat )
    w2  = mat.flat[[5, 6, 1]]
    return w1, w2

def rotmat( x, origin=(0, 0, 0), upvector=(0, 0, 1) ):
    """
    Given a position vector x, find the rotation matrix to r,h,v coordinates.
    """
    x = np.array( x ) - np.array( origin )
    nr = x / np.sqrt( (x * x).sum() )
    nh = np.cross( upvector, nr )
    if all( nh == 0.0 ):
        nh = np.cross( (1, 0, 0), nr )
    if all( nh == 0.0 ):
        nh = np.cross( (0, 1, 0), nr )
    nh = nh / np.sqrt( (nh * nh).sum() )
    nv = np.cross( nr, nh )
    nv = nv / np.sqrt( (nv * nv).sum() )
    return np.array( [nr, nh, nv] )

def llr2xyz( x, y, z, inverse=False ):
    """
    Geographic to rectangular coordinate conversion.

    x <-> lon, y <-> lat, z <-> r
    """
    x = np.array( x )
    y = np.array( y )
    z = np.array( z )
    if inverse:
        r = np.sqrt( x * x + y * y + z * z )
        x = np.arctan2( y, x )
        y = np.arcsin( z / r )
        x = 180.0 / np.pi * x
        y = 180.0 / np.pi * y
        return np.array( [x, y, r] )
    else:
        x  = np.pi / 180.0 * x
        y  = np.pi / 180.0 * y
        x_ = np.cos( x ) * np.cos( y ) * z
        y_ = np.sin( x ) * np.cos( y ) * z
        z  = np.sin( y ) * z
        return np.array( [x_, y_, z] )

def rotation( lon, lat, projection, eps=100.0 ):
    """
    mat, theta = rotation( lon, lat, projection )

    Rotation matrix and clockwise rotation angle to transform components in the
    geographic coordinate system to components in the local system.
    local_components = dot2( mat, components )
    local_strike = strike + theta
    """
    dlon = eps * 180.0 / (np.pi * rearth) * np.cos( np.pi / 180.0 * lat )
    dlat = eps * 180.0 / (np.pi * rearth)
    lon = np.array( [
        [lon - dlon, lon ],
        [lon + dlon, lon ],
    ] )
    lat = np.array( [
        [lat, lat - dlat],
        [lat, lat + dlat],
    ])
    x, y = projection( lon, lat )
    x = x[1] - x[0]
    y = y[1] - y[0]
    s = 1.0 / np.sqrt( x * x + y * y )
    mat = np.array( [s * x, s * y] )
    theta = 180.0 / np.pi * np.arctan2( mat[0], mat[1] )
    theta = 0.5 * theta.sum(0) - 45.0
    return mat, theta

def rotation3( lon, lat, dep, projection, eps=100.0 ):
    """
    mat = rotation( lon, lat, dep, projection )

    Rotation matrix to transform components in the
    geographic coordinate system to components in the local system.
    local_components = dot2( mat, components )
    """
    dlon = eps * 180.0 / (np.pi * rearth) * np.cos( np.pi / 180.0 * lat )
    dlat = eps * 180.0 / (np.pi * rearth)
    lon = np.array( [
        [lon - dlon, lon, lon],
        [lon + dlon, lon, lon],
    ] )
    lat = np.array( [
        [lat, lat - dlat, lat],
        [lat, lat + dlat, lat],
    ] )
    dep = np.array( [
        [dep, dep, dep - eps],
        [dep, dep, dep + eps],
    ] )
    x, y, z = projection( lon, lat, dep )
    x = x[1] - x[0]
    y = y[1] - y[0]
    z = z[1] - z[0]
    s = 1.0 / np.sqrt( x * x + y * y + z * z )
    mat = np.array( [s * x, s * y, s * z] )
    return mat

class Transform():
    """
    Coordinate transform for scale, rotation, and origin translation.

    Optional Parameters
    -------------------
    proj : Map projection defined by Pyproj or similar.
    scale : Scale factor.
    rotate : Rotation angle in degrees.
    translate : Translation amount.
    origin : Untransformed coordinates of the new origin.  If two sets of points
    are given, the origin is centered between them, and rotation is relative to the
    connecting line. 

    Example: TeraShake SDSU/Okaya projection
    >>> import pyproj, sord
    >>> proj = pyproj.Proj( proj='utm', zone=11, ellps='WGS84' )
    >>> proj = sord.coord.Transform( proj, rotation=40.0, origin=(-121.0, 34.5) )
    >>> proj( -120.0, 35.0 )
    array([  38031.1000251 ,  100171.63485189])
    >>> proj( 0, 0, inverse=True )
    array([-121. ,   34.5])
    """
    def __init__( self, proj=None, origin=None, scale=1.0, rotate=0.0, translate=(0.0, 0.0), matrix=((1,0,0),(0,1,0),(0,0,1)) ):
        phi = np.pi / 180.0 * rotate
        if origin == None:
            x, y = 0.0, 0.0
        else:
            x, y = origin
            if proj != None:
                x, y = proj( x, y )
            if type( x ) in (list, tuple):
                phi -= np.arctan2( y[1] - y[0], x[1] - x[0] )
                x, y = 0.5 * (x[0] + x[1]), 0.5 * (y[0] + y[1])
        mat = [[1, 0, -x], [0, 1, -y], [0, 0, 1]]
        if hasattr( proj, 'mat' ):
            mat = np.dot( mat, proj.mat )
            proj = proj.proj
        c = scale * np.cos( phi )
        s = scale * np.sin( phi )
        x, y = translate
        mat = np.dot( [[c, -s, x], [s, c, y], [0, 0, 1]], mat )
        mat = np.dot( matrix, mat )
        self.mat = mat
        self.proj = proj
    def __call__( self, x, y, **kwarg ):
        proj = self.proj
        x = np.array( x )
        y = np.array( y )
        if kwarg.get( 'inverse' ) != True:
            if proj != None:
                x, y = proj( x, y, **kwarg )
            x, y = dot2( self.mat[:2,:2], [x, y] )
            x += self.mat[0,2]
            y += self.mat[1,2]
        else:
            x -= self.mat[0,2]
            y -= self.mat[1,2]
            x, y = solve2( self.mat[:2,:2], [x, y] )
            if proj != None:
                x, y = proj( x, y, **kwarg )
        return np.array( [x, y] )

def cmu( x, y, inverse=False ):
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
    return np.array( [x, y] )

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
    strike = np.pi / 180.0 * np.array( strike )
    dip    = np.pi / 180.0 * np.array( dip ) 
    rake   = np.pi / 180.0 * np.array( rake )
    u = np.ones( strike.shape )
    z = np.zeros( strike.shape )
    c = np.cos( rake )
    s = np.sin( rake )
    A = np.array( [[c, s, z], [-s, c, z], [z, z, u]] )
    c = np.cos( dip )
    s = np.sin( dip )
    B = np.array( [[u, z, z], [z, c, s], [z, -s, c]] )
    c = np.cos( strike )
    s = np.sin( strike )
    C = np.array( [[s, c, z], [-c, s, z], [z, z, u]] )
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
    return np.array( [strike, dip, normal] )

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
    x = np.cross( up, z )
    y = np.cross( z, x )
    x = x / np.sqrt( ( x * x ).sum() )
    y = y / np.sqrt( ( y * y ).sum() )
    z = z / np.sqrt( ( z * z ).sum() )
    return np.array( [x, y, z] ).T

def compass( azimuth, radians=False ):
    """
    Get named direction from azimuth.
    """
    if radians:
        azimuth *= 180.0 / np.pi
    names = (
        'N', 'NNE', 'NE', 'ENE',
        'E', 'ESE', 'SE', 'SSE',
        'S', 'SSW', 'SW', 'WSW',
        'W', 'WNW', 'NW', 'NNW',
    )
    return names[ int( azimuth / 22.5 + 16.0 ) % 16 ]

if __name__ == '__main__':
    import doctest
    doctest.testmod()

