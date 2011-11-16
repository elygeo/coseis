"""
Coordinate conversions
"""
import numpy as np

rearth = 6370000.0

def dot2(A, B):
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
    A = np.asarray(A).T
    B = np.asarray(B).T
    i = -min(A.ndim, 2)
    if A.shape[i] != B.shape[-1]:
        raise Exception('Incompatible arrays for dot product')
    elif A.ndim == 1:
        C = (A * B).T.sum(axis=0)
    elif B.ndim == 1:
        C = (A * B[...,None]).T.sum(axis=1)
    else:
        C = (A[...,None,:,:] * B[...,None]).T.sum(axis=1)
    return C


def solve2(A, b):
    """
    Vectorized 2x2 linear equation solver
    """
    A = np.asarray(A)
    b = np.asarray(b)
    A /= (A[0,0] * A[1,1] - A[0,1] * A[1,0])
    return np.array([ b[0] * A[1,1] - b[1] * A[0,1],
                      b[1] * A[0,0] - b[0] * A[1,0] ])


def interp(xlim, f, xi, fi=None, method='nearest', bound=False, mask_nan=False):
    """
    1D piecewise interpolation of function values specified on regular grid.

    Parameters
    ----------
    xlim: Range (x_min, x_max) of coordinate space covered by `f`.
    f: Array of regularly spaced data values to be interpolated.
    xi: Array of coordinates for the interpolation points, same shape as `fi`.
    fi: Output array for the interpolated values, same shape as `xi`.
    method: Interpolation method, 'nearest' or 'linear'.
    bound: If true, do not extrapolation values outside the coordinate range. A
        tuple species the left and right boundaries independently.
    mask_nan: If true and `fi` is passed, NaNs are masked from output.

    Returns
    -------
    fi: Array of interpolated values, same shape as `xi`.
    """
    # prepare arrays
    f = np.asarray(f)
    xi = np.asarray(xi)

   # test for empty data
    if f.size == 0:
        if fi is None:
            fi = np.empty_like(xi)
            fi.fill(np.nan)
        return fi

    # logical coordinates
    nx = f.shape[-1]
    x_ = xlim
    x = xi
    del(xi)
    x = (x - x_[0]) / (x_[1] - x_[0]) * (nx - 1)

    # compute mask
    mask = False
    if type(bound) not in (tuple, list):
        bound = bound, bound
    if bound[0]: mask = mask | (x < 0)
    if bound[1]: mask = mask | (x > nx - 1)
    x = np.minimum(np.maximum(x, 0), nx - 1)

    # interpolation
    if method == 'nearest':
        j = (x + 0.5).astype('i')
        f = f[...,j]
    elif method == 'linear':
        j = np.minimum(x.astype('i'), nx - 2)
        f = (1.0 - x + j) * f[...,j] + (x - j) * f[...,j+1]
    else:
        raise Exception('Unknown interpolation method: %s' % method)
    del(j, x)

    # apply mask
    if fi is None:
        fi = f
        if mask is not False:
            fi[...,mask] = np.nan
    else:
        if mask_nan:
            mask = mask | np.isnan(f)
        if mask is False:
            fi[...] = f[...]
        else:
            fi[...,~mask] = f[...,~mask]
    return fi


def interp2(xlim, f, xi, fi=None, method='nearest', bound=False, mask_nan=False):
    """
    2D piecewise interpolation of function values specified on regular grid.

    See 1D interp for documentation.
    """
    # prepare arrays
    f = np.asarray(f)
    xi = np.asarray(xi)

    # test for empty data
    if f.size == 0:
        if fi is None:
            fi = np.empty_like(xi)
            fi.fill(np.nan)
        return fi

    # logical coordinates
    nx, ny = f.shape[-2:]
    x_, y_ = xlim
    x, y = xi
    del(xi)
    x = (x - x_[0]) / (x_[1] - x_[0]) * (nx - 1)
    y = (y - y_[0]) / (y_[1] - y_[0]) * (ny - 1)

    # compute mask
    mask = False
    if type(bound) not in (tuple, list):
        bound = [(bound, bound)] * 2
    bx, by = bound
    if bx[0]: mask = mask | (x < 0)
    if by[0]: mask = mask | (y < 0)
    if bx[1]: mask = mask | (x > nx - 1)
    if by[1]: mask = mask | (y > ny - 1)
    x = np.minimum(np.maximum(x, 0), nx - 1)
    y = np.minimum(np.maximum(y, 0), ny - 1)

    # interpolation
    if method == 'nearest':
        j = (x + 0.5).astype('i')
        k = (y + 0.5).astype('i')
        f = f[...,j,k]
    elif method == 'linear':
        j = np.minimum(x.astype('i'), nx - 2)
        k = np.minimum(y.astype('i'), ny - 2)
        f = ( (1.0 - x + j) * (1.0 - y + k) * f[...,j,k]
            + (1.0 - x + j) * (y - k)       * f[...,j,k+1]
            + (x - j)       * (1.0 - y + k) * f[...,j+1,k]
            + (x - j)       * (y - k)       * f[...,j+1,k+1] )
    else:
        raise Exception('Unknown interpolation method: %s' % method)
    del(j, k, x, y)

    # apply mask
    if fi is None:
        fi = f
        if mask is not False:
            fi[...,mask] = np.nan
    else:
        if mask_nan:
            mask = mask | np.isnan(f)
        if mask is False:
            fi[...] = f[...]
        else:
            fi[...,~mask] = f[...,~mask]
    return fi


def interp3(xlim, f, xi, fi=None, method='nearest', bound=False, mask_nan=False):
    """
    3D piecewise interpolation of function values specified on regular grid.

    See 1D interp for documentation.
    """
    # prepare arrays
    f = np.asarray(f)
    xi = np.asarray(xi)

    # test for empty data
    if f.size == 0:
        if fi is None:
            fi = np.empty_like(xi)
            fi.fill(np.nan)
        return fi

    # logical coordinates
    nx, ny, nz = f.shape[-3:]
    x_, y_, z_ = xlim
    x, y, z = xi
    del(xi)
    x = (x - x_[0]) / (x_[1] - x_[0]) * (nx - 1)
    y = (y - y_[0]) / (y_[1] - y_[0]) * (ny - 1)
    z = (z - z_[0]) / (z_[1] - z_[0]) * (nz - 1)

    # compute mask
    mask = False
    if type(bound) not in (tuple, list):
        bound = [(bound, bound)] * 3
    bx, by, bz = bound
    if bx[0]: mask = mask | (x < 0)
    if by[0]: mask = mask | (y < 0)
    if bz[0]: mask = mask | (z < 0)
    if bx[1]: mask = mask | (x > nx - 1)
    if by[1]: mask = mask | (y > ny - 1)
    if bz[1]: mask = mask | (z > nz - 1)
    x = np.minimum(np.maximum(x, 0), nx - 1)
    y = np.minimum(np.maximum(y, 0), ny - 1)
    z = np.minimum(np.maximum(z, 0), nz - 1)

    # interpolation
    if method == 'nearest':
        j = (x + 0.5).astype('i')
        k = (y + 0.5).astype('i')
        l = (z + 0.5).astype('i')
        f = f[...,j,k,l]
    elif method == 'linear':
        j = np.minimum(x.astype('i'), nx - 2)
        k = np.minimum(y.astype('i'), ny - 2)
        l = np.minimum(z.astype('i'), nz - 2)
        f = ( (1.0 - x + j) * (1.0 - y + k) * (1.0 - z + l) * f[...,j,k,l]
            + (1.0 - x + j) * (1.0 - y + k) * (z - l)       * f[...,j,k,l+1]
            + (1.0 - x + j) * (y - k)       * (1.0 - z + l) * f[...,j,k+1,l]
            + (1.0 - x + j) * (y - k)       * (z - l)       * f[...,j,k+1,l+1]
            + (x - j)       * (1.0 - y + k) * (1.0 - z + l) * f[...,j+1,k,l]
            + (x - j)       * (1.0 - y + k) * (z - l)       * f[...,j+1,k,l+1]
            + (x - j)       * (y - k)       * (1.0 - z + l) * f[...,j+1,k+1,l]
            + (x - j)       * (y - k)       * (z - l)       * f[...,j+1,k+1,l+1] )
    else:
        raise Exception('Unknown interpolation method: %s' % method)
    del(j, k, l, x, y, z)

    # apply mask
    if fi is None:
        fi = f
        if mask is not False:
            fi[...,mask] = np.nan
    else:
        if mask_nan:
            mask = mask | np.isnan(f)
        if mask is False:
            fi[...] = f[...]
        else:
            fi[...,~mask] = f[...,~mask]
    return fi


def ibilinear(xx, yy, xi, yi):
    """
    Vectorized inverse bilinear interpolation
    """
    xx = np.asarray(xx)
    yy = np.asarray(yy)
    xi = np.asarray(xi) - 0.25 * xx.sum(0).sum(0)
    yi = np.asarray(yi) - 0.25 * yy.sum(0).sum(0)
    j1 = 0.25 * np.array([ [xx[1,:] - xx[0,:], xx[:,1] - xx[:,0]],
                           [yy[1,:] - yy[0,:], yy[:,1] - yy[:,0]] ]).sum(2)
    j2 = 0.25 * np.array([ xx[1,1] - xx[0,1] - xx[1,0] + xx[0,0],
                           yy[1,1] - yy[0,1] - yy[1,0] + yy[0,0] ])
    x = dx = solve2(j1, [xi, yi])
    i = 0
    while(abs(dx).max() > 1e-6):
        i += 1
        if i > 10:
            raise Exception('inverse bilinear interpolation did not converge')
        j = [ [j1[0,0] + j2[0]*x[1], j1[0,1] + j2[0]*x[0]],
              [j1[1,0] + j2[1]*x[1], j1[1,1] + j2[1]*x[0]] ]
        b = [ xi - j1[0,0]*x[0] - j1[0,1]*x[1] - j2[0]*x[0]*x[1],
              yi - j1[1,0]*x[0] - j1[1,1]*x[1] - j2[1]*x[0]*x[1] ]
        dx = solve2(j, b)
        x  = x + dx
    return x


def rot_sym_tensor(w1, w2, rot):
    """
    Rotate symmetric 3x3 tensor stored as diagonal and off-diagonal vectors.

    Parameters
    ----------
    w1: diagonal components w11, w22, w33
    w2: off-diagonal components w23, w31, w12
    rot: rotation matrix

    Returns
    -------
    w1, w2: rotated tensor components
    """
    rot = np.asarray(rot)
    m = np.diag(w1)
    m.flat[[5, 6, 1]] = w2
    m.flat[[7, 2, 3]] = w2
    m = dot2(dot2(rot, m), rot.T)
    w1 = np.diag(m)
    w2 = m.flat[[5, 6, 1]]
    return w1, w2


def eigvals_sym_tensor(w1, w2):
    """
    Eigenvalues of a symmetric 3x3 tensor stored as diagonal and off-diagonal vectors.

    Parameters
    ----------
    w1: diagonal components w11, w22, w33
    w2: off-diagonal components w23, w31, w12

    Returns
    -------
    w: eigenvalues
    """
    m = np.diag(w1)
    m.flat[[5, 6, 1]] = w2
    m.flat[[7, 2, 3]] = w2
    w = np.linalg.eigvalsh(m)
    return w


def rotmat(x, origin=(0, 0, 0), upvector=(0, 0, 1)):
    """
    Given a position vector x, find the rotation matrix to r,h,v coordinates.
    """
    x = np.asarray(x) - np.asarray(origin)
    nr = x / np.sqrt((x * x).sum())
    nh = np.cross(upvector, nr)
    if all(nh == 0.0):
        nh = np.cross((1, 0, 0), nr)
    if all(nh == 0.0):
        nh = np.cross((0, 1, 0), nr)
    nh = nh / np.sqrt((nh * nh).sum())
    nv = np.cross(nr, nh)
    nv = nv / np.sqrt((nv * nv).sum())
    return np.array([nr, nh, nv])


def llr2xyz(x, y, z, inverse=False):
    """
    Geographic to rectangular coordinate conversion.

    x <-> lon, y <-> lat, z <-> r
    """
    x = np.asarray(x)
    y = np.asarray(y)
    z = np.asarray(z)
    if inverse:
        r = np.sqrt(x * x + y * y + z * z)
        x = np.arctan2(y, x)
        y = np.arcsin(z / r)
        x = 180.0 / np.pi * x
        y = 180.0 / np.pi * y
        return np.array([x, y, r])
    else:
        x  = np.pi / 180.0 * x
        y  = np.pi / 180.0 * y
        x_ = np.cos(x) * np.cos(y) * z
        y_ = np.sin(x) * np.cos(y) * z
        z  = np.sin(y) * z
        return np.array([x_, y_, z])


def rotation(lon, lat, projection, eps=100.0):
    """
    mat, theta = rotation(lon, lat, projection)

    Rotation matrix and clockwise rotation angle to transform components in the
    geographic coordinate system to components in the local system.
    local_components = dot2(mat, components)
    local_strike = strike + theta
    """
    dlon = eps * 180.0 / (np.pi * rearth) * np.cos(np.pi / 180.0 * lat)
    dlat = eps * 180.0 / (np.pi * rearth)
    lon = np.array([
        [lon - dlon, lon],
        [lon + dlon, lon],
    ])
    lat = np.array([
        [lat, lat - dlat],
        [lat, lat + dlat],
    ])
    x, y = projection(lon, lat)
    x = x[1] - x[0]
    y = y[1] - y[0]
    s = 1.0 / np.sqrt(x * x + y * y)
    mat = np.array([s * x, s * y])
    theta = 180.0 / np.pi * np.arctan2(mat[0], mat[1])
    theta = 0.5 * theta.sum(0) - 45.0
    return mat, theta


def rotation3(lon, lat, dep, projection, eps=100.0):
    """
    mat = rotation(lon, lat, dep, projection)

    Rotation matrix to transform components in the
    geographic coordinate system to components in the local system.
    local_components = dot2(mat, components)
    """
    dlon = eps * 180.0 / (np.pi * rearth) * np.cos(np.pi / 180.0 * lat)
    dlat = eps * 180.0 / (np.pi * rearth)
    lon = np.array([
        [lon - dlon, lon, lon],
        [lon + dlon, lon, lon],
    ])
    lat = np.array([
        [lat, lat - dlat, lat],
        [lat, lat + dlat, lat],
    ])
    dep = np.array([
        [dep, dep, dep - eps],
        [dep, dep, dep + eps],
    ])
    x, y, z = projection(lon, lat, dep)
    x = x[1] - x[0]
    y = y[1] - y[0]
    z = z[1] - z[0]
    s = 1.0 / np.sqrt(x * x + y * y + z * z)
    mat = np.array([s * x, s * y, s * z])
    return mat


class Transform():
    """
    Coordinate transform for scale, rotation, and origin translation.

    Optional Parameters
    -------------------
    proj: Map projection defined by Pyproj or similar.
    scale: Scale factor.
    rotate: Rotation angle in degrees.
    translate: Translation amount.
    origin: Untransformed coordinates of the new origin.  If two sets of points
        are given, the origin is centered between them, and rotation is relative to the
        connecting line.

    Returns
    -------
    proj: Coordinate transformation function

    Example: TeraShake SDSU/Okaya projection
    >>> import pyproj
    >>> proj = pyproj.Proj(proj='utm', zone=11, ellps='WGS84')
    >>> proj = Transform(proj, rotate=40.0, origin=(-121.0, 34.5))
    >>> proj(-120.0, 35.0)
    array([  38031.1000251 ,  100171.63485189])
    >>> proj(0, 0, inverse=True)
    array([-121. ,   34.5])
    """
    def __init__(self, proj=None, origin=None, scale=1.0, rotate=0.0,
        translate=(0.0, 0.0), matrix=((1,0,0),(0,1,0),(0,0,1))):
        phi = np.pi / 180.0 * rotate
        if origin == None:
            x, y = 0.0, 0.0
        else:
            x, y = origin
            if proj != None:
                x, y = proj(x, y)
            if type(x) in (list, tuple):
                phi -= np.arctan2(y[1] - y[0], x[1] - x[0])
                x, y = 0.5 * (x[0] + x[1]), 0.5 * (y[0] + y[1])
        mat = [[1, 0, -x], [0, 1, -y], [0, 0, 1]]
        if hasattr(proj, 'mat'):
            mat = np.dot(mat, proj.mat)
            proj = proj.proj
        c = scale * np.cos(phi)
        s = scale * np.sin(phi)
        x, y = translate
        mat = np.dot([[c, -s, x], [s, c, y], [0, 0, 1]], mat)
        mat = np.dot(matrix, mat)
        self.mat = mat
        self.proj = proj
    def __call__(self, x, y, **kwarg):
        proj = self.proj
        x = np.asarray(x)
        y = np.asarray(y)
        if kwarg.get('inverse') is not True:
            if proj != None:
                x, y = proj(x, y, **kwarg)
            x, y = dot2(self.mat[:2,:2], [x, y])
            x += self.mat[0,2]
            y += self.mat[1,2]
        else:
            x = x - self.mat[0,2]
            y = y - self.mat[1,2]
            x, y = solve2(self.mat[:2,:2], [x, y])
            if proj != None:
                x, y = proj(x, y, **kwarg)
        return np.array([x, y])


def cmu(x, y, inverse=False):
    """
    CMU TeraShake coordinates projection
    """
    xx = [-121.0, -118.951292], [-116.032285, -113.943965]
    yy = [  34.5,   36.621696], [  31.082920,   33.122341]
    if inverse:
        extent = (0.0, 600000.0), (0.0, 300000.0)
        x, y = interp2(extent, (xx, yy), (x, y), extrapolate=True)
    else:
        x, y = ibilinear(xx, yy, x, y)
        x = (x + 1.0) * 300000.0
        y = (y + 1.0) * 150000.0
    return np.array([x, y])


def slip_vectors(strike, dip, rake, dtype=None):
    """
    For given strike, dip, and rake (degrees), using the Aki & Richards convention
    of dip to the right of the strike vector, find the rotation matrix R from world
    coordinates (east, north, up) to fault local coordinates (slip1, slip2, normal).
    The transpose R^T performs the reverse rotation from fault local coordinates to
    world coordinates.  Columns of R are axis unit vectors of the world space in
    fault local coordinates.  Rows of R are axis unit vectors of the fault local
    space in world coordinates, that can be unpacked by:
    n_slip1, n_slip2, n_normal = coord.slipvectors(strike, dip, rake)
    """

    A = np.pi / 180.0 * np.asarray(rake)
    B = np.pi / 180.0 * np.asarray(dip)
    C = np.pi / 180.0 * np.asarray(strike)
    u, z = np.ones_like(A), np.zeros_like(A)
    c, s = np.cos(A), np.sin(A)
    A = np.array([[c, s, z], [-s, c, z], [z, z, u]])
    c, s = np.cos(B), np.sin(B)
    B = np.array([[u, z, z], [z, c, s], [z, -s, c]])
    c, s = np.cos(C), np.sin(C)
    C = np.array([[s, c, z], [-c, s, z], [z, z, u]])
    return dot2(dot2(A, B), C)


def potency_tensor(normal, slip):
    """
    Given a fault unit normal and a slip vector, return a symmetric potency tensor as
    volume components (W11, W22, W33), and shear components (W23, W31, W12).
    """
    p = np.array([ normal * slip, [
        0.5 * (normal[1] * slip[2] + slip[1] * normal[2]),
        0.5 * (normal[2] * slip[0] + slip[2] * normal[0]),
        0.5 * (normal[0] * slip[1] + slip[0] * normal[1]),
    ]])
    return p


def viewmatrix(azimuth, elevation, up=None):
    """
    Compute transformation matrix from view azimuth and elevation.
    """
    if up is None:
          if 5.0 < abs(elevation) < 175.0:
              up = 0, 0, 1
          else:
              up = 0, 1, 0
    z = llr2xyz([azimuth], [90.0 - elevation], [1]).T[0]
    x = np.cross(up, z)
    y = np.cross(z, x)
    x = x / np.sqrt((x * x).sum())
    y = y / np.sqrt((y * y).sum())
    z = z / np.sqrt((z * z).sum())
    return np.array([x, y, z]).T


def compass(azimuth, radians=False):
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
    return names[int((azimuth / 22.5 + 0.5) % 16.0)]

