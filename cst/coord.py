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
    A = np.asarray( A ).T
    B = np.asarray( B ).T
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
    A = np.asarray( A )
    b = np.asarray( b )
    A /= (A[0,0] * A[1,1] - A[0,1] * A[1,0])
    return np.array( [b[0] * A[1,1] - b[1] * A[0,1],
                      b[1] * A[0,0] - b[0] * A[1,0]] )


def interp( extent, f, coords, out=None, bound=None, mask_nan=False, extrapolate=False ):
    """
    1D interpolation on a regular grid
    """
    f = np.asarray( f )
    x0, x1 = extent
    delta = (x1 - x0) / (f.shape[-1] - 1)
    xi = (np.asarray( coords ) - x0) / delta
    del( coords )
    j = np.int32( xi )
    n = f.shape[-1]
    i = True
    if bound is not None:
        if bound[0]: i = i & (j >= 0)
        if bound[1]: i = i & (j <= n-2)
    j = np.minimum( np.maximum( j, 0 ), n-2 )
    if not extrapolate:
        xi = np.minimum( np.maximum( xi, 0 ), n-1 )
    f = (1.0 - xi + j) * f[...,j] + (xi - j) * f[...,j+1]
    if out is None:
        if i is not True:
            f[...,~i] = np.nan
        return f
    else:
        if mask_nan:
            i = i & ~np.isnan( f )
        if i is True:
            out[...] = f[...]
        else:
            out[...,i] = f[...,i]
        return


def interp2( extent, f, coords, out=None, method='linear', bound=None, mask_nan=False, extrapolate=False ):
    """
    2D interpolation on a regular grid
    """
    f = np.asarray( f )
    x0, x1 = np.array( extent ).T
    delta = (x1 - x0) / (np.array( f.shape[-2:] ) - 1)
    xi = (np.asarray( coords[0] ) - x0[0]) / delta[0]
    yi = (np.asarray( coords[1] ) - x0[1]) / delta[1]
    del( coords )
    n = f.shape
    i = True
    if method == 'nearest':
        j = np.array( xi + 0.5, 'i' )
        k = np.array( yi + 0.5, 'i' )
        if bound is not None:
            if bound[0][0]: i = i & (j >= 0)
            if bound[1][0]: i = i & (k >= 0)
            if bound[0][1]: i = i & (j <= n[-2]-1)
            if bound[1][1]: i = i & (k <= n[-1]-1)
        j = np.minimum( np.maximum( j, 0 ), n[-2]-1 )
        k = np.minimum( np.maximum( k, 0 ), n[-1]-1 )
        f = f[...,j,k]
    elif method == 'linear':
        j = np.array( xi, 'i' )
        k = np.array( yi, 'i' )
        if bound != None:
            if bound[0][0]: i = i & (j >= 0)
            if bound[1][0]: i = i & (k >= 0)
            if bound[0][1]: i = i & (j <= n[-2]-2)
            if bound[1][1]: i = i & (k <= n[-1]-2)
        j = np.minimum( np.maximum( j, 0 ), n[-2]-2 )
        k = np.minimum( np.maximum( k, 0 ), n[-1]-2 )
        if not extrapolate:
            xi = np.minimum( np.maximum( xi, 0 ), n[-2]-1 )
            yi = np.minimum( np.maximum( yi, 0 ), n[-1]-1 )
        f = ( ( 1.0 - xi + j ) * ( 1.0 - yi + k ) * f[...,j,k]
            + ( 1.0 - xi + j ) * (       yi - k ) * f[...,j,k+1]
            + (       xi - j ) * ( 1.0 - yi + k ) * f[...,j+1,k]
            + (       xi - j ) * (       yi - k ) * f[...,j+1,k+1] )
    else:
        sys.exit( 'Unknon interpolation method: %s' % method )
    if out is None:
        if i is not True:
            f[...,~i] = np.nan
        return f
    else:
        if mask_nan:
            i = i & ~np.isnan( f )
        if i is True:
            out[...] = f[...]
        else:
            out[...,i] = f[...,i]
        return


def interp3( extent, f, coords, out=None, method='linear', bound=None, mask_nan=False, extrapolate=False ):
    """
    3D interpolation on a regular grid
    """
    x0, x1 = np.array( extent ).T
    delta = (x1 - x0) / (np.array( f.shape[-3:] ) - 1)
    f = np.asarray( f )
    xi = (np.asarray( coords[0] ) - x0[0]) / delta[0]
    yi = (np.asarray( coords[1] ) - x0[1]) / delta[1]
    zi = (np.asarray( coords[2] ) - x0[2]) / delta[2]
    del( coords )
    n = f.shape
    i = True
    if method == 'nearest':
        j = np.array( xi + 0.5, 'i' )
        k = np.array( yi + 0.5, 'i' )
        l = np.array( zi + 0.5, 'i' )
        if bound is not None:
            if bound[0][0]: i = i & (j >= 0)
            if bound[1][0]: i = i & (k >= 0)
            if bound[2][0]: i = i & (l >= 0)
            if bound[0][1]: i = i & (j <= n[-3]-1)
            if bound[1][1]: i = i & (k <= n[-2]-1)
            if bound[2][1]: i = i & (l <= n[-1]-1)
        j = np.minimum( np.maximum( j, 0 ), n[-3]-1 )
        k = np.minimum( np.maximum( k, 0 ), n[-2]-1 )
        l = np.minimum( np.maximum( l, 0 ), n[-1]-1 )
        f = f[...,j,k,l]
    elif method == 'linear':
        j = np.array( xi, 'i' )
        k = np.array( yi, 'i' )
        l = np.array( zi, 'i' )
        if bound != None:
            if bound[0][0]: i = i & (j >= 0)
            if bound[1][0]: i = i & (k >= 0)
            if bound[2][0]: i = i & (l >= 0)
            if bound[0][1]: i = i & (j <= n[-3]-2)
            if bound[1][1]: i = i & (k <= n[-2]-2)
            if bound[2][1]: i = i & (l <= n[-1]-2)
        j = np.minimum( np.maximum( j, 0 ), n[-3]-2 )
        k = np.minimum( np.maximum( k, 0 ), n[-2]-2 )
        l = np.minimum( np.maximum( l, 0 ), n[-1]-2 )
        if not extrapolate:
            xi = np.minimum( np.maximum( xi, 0 ), n[-3]-1 )
            yi = np.minimum( np.maximum( yi, 0 ), n[-2]-1 )
            zi = np.minimum( np.maximum( zi, 0 ), n[-1]-1 )
        f = ( ( 1.0 - xi + j ) * ( 1.0 - yi + k ) * ( 1.0 - zi + l ) * f[...,j,k,l]
            + ( 1.0 - xi + j ) * ( 1.0 - yi + k ) * (       zi - l ) * f[...,j,k,l+1]
            + ( 1.0 - xi + j ) * (       yi - k ) * ( 1.0 - zi + l ) * f[...,j,k+1,l]
            + ( 1.0 - xi + j ) * (       yi - k ) * (       zi - l ) * f[...,j,k+1,l+1]
            + (       xi - j ) * ( 1.0 - yi + k ) * ( 1.0 - zi + l ) * f[...,j+1,k,l]
            + (       xi - j ) * ( 1.0 - yi + k ) * (       zi - l ) * f[...,j+1,k,l+1]
            + (       xi - j ) * (       yi - k ) * ( 1.0 - zi + l ) * f[...,j+1,k+1,l]
            + (       xi - j ) * (       yi - k ) * (       zi - l ) * f[...,j+1,k+1,l+1] )
    else:
        sys.exit( 'Unknon interpolation method: %s' % method )
    if out is None:
        if i is not True:
            f[...,~i] = np.nan
        return f
    else:
        if mask_nan:
            i = i & ~np.isnan( f )
        if i is True:
            out[...] = f[...]
        else:
            out[...,i] = f[...,i]
        return


def ibilinear( xx, yy, xi, yi ):
    """
    Vectorized inverse bilinear interpolation
    """
    xx = np.asarray( xx )
    yy = np.asarray( yy )
    xi = np.asarray( xi ) - 0.25 * xx.sum(0).sum(0)
    yi = np.asarray( yi ) - 0.25 * yy.sum(0).sum(0)
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

    Parameters
    ----------
        w1 : volume components w11, w22, w33
        w2 : shear components w23, w31, w12
        rot : rotation matrix

    Returns
    -------
        w1, w2 : rotated tensor components
    """
    rot = np.asarray( rot )
    mat = np.diag( w1 )
    mat.flat[[5, 6, 1]] = w2
    mat.flat[[7, 2, 3]] = w2
    mat = dot2( dot2( rot, mat ), rot.T )
    w1 = np.diag( mat )
    w2 = mat.flat[[5, 6, 1]]
    return w1, w2


def rotmat( x, origin=(0, 0, 0), upvector=(0, 0, 1) ):
    """
    Given a position vector x, find the rotation matrix to r,h,v coordinates.
    """
    x = np.asarray( x ) - np.asarray( origin )
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
    x = np.asarray( x )
    y = np.asarray( y )
    z = np.asarray( z )
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

    Returns
    -------
    proj : Coordinate transformation function

    Example: TeraShake SDSU/Okaya projection
    >>> import pyproj
    >>> proj = pyproj.Proj( proj='utm', zone=11, ellps='WGS84' )
    >>> proj = Transform( proj, rotate=40.0, origin=(-121.0, 34.5) )
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
        x = np.asarray( x )
        y = np.asarray( y )
        if kwarg.get( 'inverse' ) is not True:
            if proj != None:
                x, y = proj( x, y, **kwarg )
            x, y = dot2( self.mat[:2,:2], [x, y] )
            x += self.mat[0,2]
            y += self.mat[1,2]
        else:
            x = x - self.mat[0,2]
            y = y - self.mat[1,2]
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
        extent = (0.0, 600000.0), (0.0, 300000.0)
        x, y = interp2( extent, (xx, yy), (x, y), extrapolate=True )
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
    world coordinates.  Columns of R are axis unit vectors of the world space in
    fault local coordinates.  Rows of R are axis unit vectors of the fault local
    space in world coordinates, that can be unpacked by:
    n_slip, n_rake, n_normal = coord.slipvectors( strike, dip, rake )
    """
    strike = np.pi / 180.0 * np.asarray( strike )
    dip    = np.pi / 180.0 * np.asarray( dip )
    rake   = np.pi / 180.0 * np.asarray( rake )
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
    row 1 is the (shear)  strike contribution to W23, W31, W12
    row 2 is the (shear)  dip    contribution to W23, W31, W12
    row 3 is the (volume) normal contribution to W11, W22, W33
    The rows can unpacked conveniently by:
    T_strike, T_dip, T_normal = coord.slip_tensors( R )
    """
    strike, dip, normal = R
    del( R )
    strike = 0.5 * np.array( [
        strike[1] * normal[2] + normal[1] * strike[2],
        strike[2] * normal[0] + normal[2] * strike[0],
        strike[0] * normal[1] + normal[0] * strike[1],
    ] )
    dip = 0.5 * np.array( [
        dip[1] * normal[2] + normal[1] * dip[2],
        dip[2] * normal[0] + normal[2] * dip[0],
        dip[0] * normal[1] + normal[0] * dip[1],
    ] )
    normal = normal * normal
    return np.array( [strike, dip, normal] )


def viewmatrix( azimuth, elevation, up=None ):
    """
    Compute transformation matrix from view azimuth and elevation.
    """
    if up is None:
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
    return names[ int( (azimuth / 22.5 + 0.5) % 16.0 ) ]

