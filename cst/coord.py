"""
Coordinate conversion tools.
"""
import math

rearth = 6370000.0


def dotvv(a, b, check=True):
    """
    Vector-vector dot product, optimized for small number of components
    containing large arrays. For large numbers of components use numpy.dot
    instead. Unlike numpy.dot, broadcasting rules only apply component-wise, so
    components may be a mix of scalars and numpy arrays of any shape compatible
    for broadcasting.
    """
    n = len(a)
    if check and n > 8:
        raise Exception('Too large. Use numpy.dot')
    c = 0.0
    for i in range(n):
        c += a[i] * b[i]
    return c


def dotmv(A, b, check=True):
    """
    Matrix-vector dot product, optimized for small number of components
    containing large arrays. For large numbers of components use numpy.dot
    instead. Unlike numpy.dot, broadcasting rules only apply component-wise, so
    components may be a mix of scalars and numpy arrays of any shape compatible
    for broadcasting.
    """
    m = len(A)
    n = len(A[0])
    if check and m * n > 64:
        raise Exception('Too large. Use numpy.dot')
    C = []
    for j in range(m):
        c = 0.0
        for i in range(n):
            c += A[j][i] * b[i]
        C.append(c)
    return C


def dotmm(A, B, check=True):
    """
    Matrix-matrix dot product, optimized for small number of components
    containing large arrays. For large numbers of components use numpy.dot
    instead. Unlike numpy.dot, broadcasting rules only apply component-wise, so
    components may be a mix of scalars and numpy arrays of any shape compatible
    for broadcasting.
    """
    m = len(A)
    n = len(B[0])
    p = len(B)
    if check and m * n * p > 512:
        raise Exception('Too large. Use numpy.dot')
    D = []
    for j in range(m):
        C = []
        for k in range(n):
            c = 0.0
            for i in range(p):
                c += A[j][i] * B[i][k]
            C.append(c)
        D.append(C)
    return D


def solve2(A, b):
    """
    2x2 linear equation solver. Components may be scalars or numpy arrays.
    """
    d = 1.0 / (A[0, 0] * A[1, 1] - A[0, 1] * A[1, 0])
    x = [
        d * A[1, 1] * b[0] - d * A[0, 1] * b[1],
        d * A[0, 0] * b[1] - d * A[1, 0] * b[0],
    ]
    return x


def rot_sym_tensor(w1, w2, rot):
    """
    Rotate symmetric 3x3 tensor stored as diagonal and off-diagonal vectors.

    Parameters:

    w1: diagonal components w11, w22, w33
    w2: off-diagonal components w23, w31, w12
    rot: rotation matrix

    Returns: (w1, w2) rotated tensor components
    """
    import numpy as np

    rot = np.asarray(rot)
    m = np.diag(w1)
    m.flat[[5, 6, 1]] = w2
    m.flat[[7, 2, 3]] = w2
    m = dotmm(dotmm(rot, m), rot.T)
    w1 = np.diag(m)
    w2 = m.flat[[5, 6, 1]]
    return w1, w2


def eigvals_sym_tensor(w1, w2):
    """
    Returns eigenvalues of a symmetric 3x3 tensor stored as diagonal and
    off-diagonal vectors.
    w1: diagonal components w11, w22, w33
    w2: off-diagonal components w23, w31, w12
    """
    import numpy as np

    m = np.diag(w1)
    m.flat[[5, 6, 1]] = w2
    m.flat[[7, 2, 3]] = w2
    w = np.linalg.eigvalsh(m)
    return w


def rotmat(x, origin=(0, 0, 0), upvector=(0, 0, 1)):
    """
    Given a position vector x, find the rotation matrix to r,h,v coordinates.
    """
    import numpy as np

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
    Spherical to Cartesian coordinate conversion. Spherical coordinates are
    parameterized in degrees longitude and latitude. This approximates
    Geographic to Earth-Centered, Earth-Fixed (ECEF) Cartesian coordinates.
    Cartesian X axis is at lon 0, lat 0.
    Cartesian Y axis is at lon 90, lat 0.
    Cartesian Z axis is at lat 90.

    x <-> lon, y <-> lat, z <-> r
    """
    import numpy as np
    if inverse:
        r = np.sqrt(x * x + y * y + z * z)
        x = np.arctan2(y, x)
        y = np.arcsin(z / r)
        x = 180.0 / math.pi * x
        y = 180.0 / math.pi * y
        return x, y, r
    else:
        x = math.pi / 180.0 * x
        y = math.pi / 180.0 * y
        x_ = np.cos(x) * np.cos(y) * z
        y_ = np.sin(x) * np.cos(y) * z
        z = np.sin(y) * z
        return x_, y_, z


def euler_rotation(phi=0.0, theta=0.0, psi=0.0):
    """
    Compute rotation matrix from Euler angles (Z-X-Z convention).

    http://mathworld.wolfram.com/EulerAngles.html

    ECEF Cartesian to East, North, Up transform:
    m = euler_rotation(lon + 90, 90 - lat)

    East, North, Up to fault surface coordinates:
    m = euler_rotation(90 - strike, dip, rake)
    """
    import numpy as np
    A = math.pi / 180.0 * phi
    B = math.pi / 180.0 * theta
    C = math.pi / 180.0 * psi
    del(phi, theta, psi)
    c, s = np.cos(A), np.sin(A)
    A = [c, s, 0], [-s, c, 0], [0,  0, 1]
    c, s = np.cos(B), np.sin(B)
    B = [1, 0, 0], [0,  c, s], [0, -s, c]
    c, s = np.cos(C), np.sin(C)
    C = [c, s, 0], [-s, c, 0], [0,  0, 1]
    return dotmm(dotmm(C, B), A)


def slip_vectors(strike, dip, rake, dtype=None):
    """
    For given strike, dip, and rake (degrees), using the Aki & Richards
    convention of dip to the right of the strike vector, find the rotation
    matrix R from world coordinates (east, north, up) to fault local
    coordinates (slip1, slip2, normal). The transpose R^T performs the reverse
    rotation from fault local coordinates to world coordinates.  Columns of R
    are axis unit vectors of the world space in fault local coordinates.  Rows
    of R are axis unit vectors of the fault local space in world coordinates,
    that can be unpacked by: n_slip1, n_slip2, n_normal = slip_vectors(strike,
    dip, rake)
    """
    return euler_rotation(90 - strike, dip, rake)


def rotation(lon, lat, projection, eps=100.0):
    """
    mat, theta = rotation(lon, lat, projection)
    Rotation matrix and clockwise rotation angle to transform components in the
    geographic coordinate system to components in the local system.
    local_components = dotmv(mat, components)
    local_strike = strike + theta
    """
    import numpy as np
    dlon = eps * 180.0 / (math.pi * rearth) * np.cos(math.pi / 180.0 * lat)
    dlat = eps * 180.0 / (math.pi * rearth)
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
    theta = 180.0 / math.pi * np.arctan2(mat[0], mat[1])
    theta = 0.5 * theta.sum(0) - 45.0
    return mat, theta


def rotation3(lon, lat, dep, projection, eps=100.0):
    """
    mat = rotation(lon, lat, dep, projection)
    Rotation matrix to transform components in the
    geographic coordinate system to components in the local system.
    local_components = dotmv(mat, components)
    """
    import numpy as np
    dlon = eps * 180.0 / (math.pi * rearth) * np.cos(math.pi / 180.0 * lat)
    dlat = eps * 180.0 / (math.pi * rearth)
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
    proj: Map projection defined by Pyproj or similar.
    scale: Scale factor.
    rotate: Rotation angle in degrees.
    translate: Translation amount.
    origin: Untransformed coordinates of the new origin.  If two sets of points
        are given, the origin is centered between them, and rotation is
        relative to the connecting line.
    Returns a coordinate transformation function.

    Example: TeraShake SDSU/Okaya projection
    >>> import pyproj
    >>> proj = pyproj.Proj(proj='utm', zone=11, ellps='WGS84')
    >>> proj = Transform(proj, rotate=40.0, origin=(-121.0, 34.5))
    >>> proj(-120.0, 35.0)
    array([  38031.1000251 ,  100171.63485189])
    >>> proj(0, 0, inverse=True)
    array([-121. ,   34.5])
    """

    def __init__(
      self, proj=None, origin=None, scale=1.0, rotate=0.0,
      translate=(0.0, 0.0), matrix=((1, 0, 0), (0, 1, 0), (0, 0, 1))):
        import numpy as np
        phi = math.pi / 180.0 * rotate
        if origin is None:
            x, y = 0.0, 0.0
        else:
            x, y = origin
            if proj is not None:
                x, y = proj(x, y)
            if isinstance(x, (list, tuple)):
                phi -= np.arctan2(y[1] - y[0], x[1] - x[0])
                x = 0.5 * (x[0] + x[1])
                y = 0.5 * (y[0] + y[1])
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
        import numpy as np
        proj = self.proj
        x = np.asarray(x)
        y = np.asarray(y)
        if kwarg.get('inverse') is not True:
            if proj is not None:
                x, y = proj(x, y, **kwarg)
            x, y = dotmv(self.mat[:2, :2], [x, y])
            x += self.mat[0, 2]
            y += self.mat[1, 2]
        else:
            x = x - self.mat[0, 2]
            y = y - self.mat[1, 2]
            x, y = solve2(self.mat[:2, :2], [x, y])
            if proj is not None:
                x, y = proj(x, y, **kwarg)
        return np.array([x, y])


def potency_tensor(normal, slip):
    """
    Given a fault unit normal and a slip vector, return a symmetric potency
    tensor as volume components (W11, W22, W33), and shear components
    (W23, W31, W12).
    """
    v = [
        normal[0] * slip[0],
        normal[1] * slip[1],
        normal[2] * slip[2],
    ]
    s = [
        0.5 * (normal[1] * slip[2] + normal[2] * slip[1]),
        0.5 * (normal[2] * slip[0] + normal[0] * slip[2]),
        0.5 * (normal[0] * slip[1] + normal[1] * slip[0]),
    ]
    return [v, s]


def compass(azimuth, radians=False):
    """
    Get named direction from azimuth.
    """
    if radians:
        azimuth *= 180.0 / math.pi
    names = (
        'N', 'NNE', 'NE', 'ENE',
        'E', 'ESE', 'SE', 'SSE',
        'S', 'SSW', 'SW', 'WSW',
        'W', 'WNW', 'NW', 'NNW',
    )
    return names[int((azimuth / 22.5 + 0.5) % 16.0)]
