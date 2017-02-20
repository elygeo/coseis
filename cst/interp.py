"""
Interpolation functions
"""
import os
import numpy as np


def build():
    from distutils.core import setup, Extension
    import numpy as np
    cwd = os.getcwd()
    os.chdir(os.path.dirname(__file__))
    incl = [np.get_include()]
    ext = [Extension('interp_', ['interp_.c'], include_dirs=incl)]
    setup(ext_modules=ext, script_args=['build_ext', '--inplace'])
    os.chdir(cwd)


try:
    from .interp_ import trinterp, interp1, interp2, interp3
except ImportError:
    build()
    from .interp_ import trinterp, interp1, interp2, interp3
assert(trinterp)


def interp1_np(xlim, f, xi, fi=None, method='nearest'):
    """
    1D piecewise interpolation of function values specified on regular grid.
    xlim: Range (x_min, x_max) of coordinate space covered by `f`.
    f: Array of regularly spaced data values to be interpolated.
    xi: Array of coordinates for the interpolation points, same shape as `fi`.
    fi: Output array for the interpolated values, same shape as `xi`.
    method: Interpolation method, 'nearest' or 'linear'.
    Returns an array of interpolated values, same shape as `xi`.
    """
    f = np.asarray(f)
    xi = np.asarray(xi)
    if f.size == 0:
        if fi is None:
            fi = np.empty_like(xi)
            fi.fill(float('nan'))
        return fi

    x0, x1 = xlim
    nx = f.size
    x = (xi - x0) / (x1 - x0) * (nx - 1)

    if method == 'nearest':
        j = (x + 0.5).astype('i')
        j = np.maximum(j, 0)
        j = np.minimum(j, nx - 1)
        f = f[j]
    elif method == 'linear':
        j = x.astype('i')
        j = np.maximum(j, 0)
        j = np.minimum(j, nx - 2)
        f = (1.0 - x + j) * f[j] + (x - j) * f[j+1]
    else:
        raise Exception('Unknown interpolation method: %s' % method)

    if fi is None:
        fi = np.empty_like(xi)
        fi.fill(float('nan'))
    i = f == f & x >= 0 & x <= nx - 1
    fi[i] = f[i]

    return fi


def interp2_np(xlim, f, xi, fi=None, method='nearest'):
    """
    2D piecewise interpolation of function values specified on regular grid.
    """
    f = np.asarray(f)
    xi = np.asarray(xi)
    if f.size == 0:
        if fi is None:
            fi = np.empty_like(xi[..., 0])
            fi.fill(float('nan'))
        return fi

    [x0, x1], [y0, y1] = xlim
    nx, ny = f.shape
    x, y = xi.T
    x = (x - x0) / (x1 - x0) * (nx - 1)
    y = (y - y0) / (y1 - y0) * (ny - 1)

    if method == 'nearest':
        j = (x + 0.5).astype('i')
        k = (y + 0.5).astype('i')
        j = np.maximum(j, 0)
        k = np.maximum(k, 0)
        j = np.minimum(j, nx - 1)
        k = np.minimum(k, ny - 1)
        f = f[j, k]
    elif method == 'linear':
        j = x.astype('i')
        k = y.astype('i')
        j = np.maximum(j, 0)
        k = np.maximum(k, 0)
        j = np.minimum(j, nx - 2)
        k = np.minimum(k, ny - 2)
        f = (
            (1.0 - x + j) * (1.0 - y + k) * f[j, k] +
            (1.0 - x + j) * (y - k) * f[j, k+1] +
            (x - j) * (1.0 - y + k) * f[j+1, k] +
            (x - j) * (y - k) * f[j+1, k+1]
        )
    else:
        raise Exception('Unknown interpolation method: %s' % method)

    if fi is None:
        fi = np.empty_like(xi[..., 0])
        fi.fill(float('nan'))
    i = (
        f == f &
        x >= 0 & x <= nx - 1 &
        y >= 0 & y <= ny - 1
    )
    fi[i] = f[i]

    return fi


def interp3_np(xlim, f, xi, fi=None, method='nearest'):
    """
    3D piecewise interpolation of function values specified on regular grid.
    """
    f = np.asarray(f)
    xi = np.asarray(xi)
    if f.size == 0:
        if fi is None:
            fi = np.empty_like(xi[..., 0])
            fi.fill(float('nan'))
        return fi

    [x0, x1], [y0, y1], [z0, z1] = xlim
    nx, ny, nz = f.shape
    x, y, z = xi.T
    x = (x - x0) / (x1 - x0) * (nx - 1)
    y = (y - y0) / (y1 - y0) * (ny - 1)
    z = (z - z0) / (z1 - z0) * (nz - 1)

    if method == 'nearest':
        j = (x + 0.5).astype('i')
        k = (y + 0.5).astype('i')
        l = (z + 0.5).astype('i')
        j = np.maximum(j, 0)
        k = np.maximum(k, 0)
        l = np.maximum(l, 0)
        j = np.minimum(j, nx - 1)
        k = np.minimum(k, ny - 1)
        l = np.minimum(l, nz - 1)
        f = f[j, k, l]
    elif method == 'linear':
        j = x.astype('i')
        k = y.astype('i')
        l = z.astype('i')
        j = np.maximum(j, 0)
        k = np.maximum(k, 0)
        l = np.maximum(l, 0)
        j = np.minimum(j, nx - 2)
        k = np.minimum(k, ny - 2)
        l = np.minimum(l, nz - 2)
        f = (
            (1.0 - x + j) * (1.0 - y + k) * (1.0 - z + l) * f[j, k, l] +
            (1.0 - x + j) * (1.0 - y + k) * (z - l) * f[j, k, l+1] +
            (1.0 - x + j) * (y - k) * (1.0 - z + l) * f[j, k+1, l] +
            (1.0 - x + j) * (y - k) * (z - l) * f[j, k+1, l+1] +
            (x - j) * (1.0 - y + k) * (1.0 - z + l) * f[j+1, k, l] +
            (x - j) * (1.0 - y + k) * (z - l) * f[j+1, k, l+1] +
            (x - j) * (y - k) * (1.0 - z + l) * f[j+1, k+1, l] +
            (x - j) * (y - k) * (z - l) * f[j+1, k+1, l+1]
        )
    else:
        raise Exception('Unknown interpolation method: %s' % method)

    if fi is None:
        fi = np.empty_like(xi[..., 0])
        fi.fill(float('nan'))
    i = (
        f == f &
        x >= 0 & x <= nx - 1 &
        y >= 0 & y <= ny - 1 &
        z >= 0 & z <= nz - 1
    )
    fi[i] = f[i]

    return fi


def trinterp_np(x, f, t, xi, fi=None, no_data_val=float('nan')):
    """
    2D linear interpolation of function values specified on triangular mesh.
    x:  shape (M, 2) array of vertex coordinates.
    f:  shape (M) array of function values at the vertices.
    t:  shape (N, 3) array of vertex indices for the triangles.
    xi: shape (..., 2) array of coordinates for the interpolation points.
    Returns array of interpolated values, same shape as `xi[0]`.
    """
    if fi is None:
        fi = np.empty_like(xi[..., 0])
        fi.fill(no_data_val)

    # tolerance
    lmin = -0.000001
    lmax = 1.000001

    # loop over triangles
    for i0, i1, i2 in t:

        # barycentric coordinates
        A00 = x[i1, 0] - x[i0, 0]
        A01 = x[i2, 0] - x[i0, 0]
        A10 = x[i1, 1] - x[i0, 1]
        A11 = x[i2, 1] - x[i0, 1]
        d = A00 * A11 - A01 * A10
        if d == 0.0:
            continue
        d = 1.0 / d
        b = xi - x[i0]
        l1 = d * A11 * b[..., 0] - d * A01 * b[..., 1]
        l2 = d * A00 * b[..., 1] - d * A10 * b[..., 0]
        l0 = 1.0 - l1 - l2

        # interpolate points inside triangle
        i = (
            (l0 > lmin) & (l0 < lmax) &
            (l1 > lmin) & (l1 < lmax) &
            (l2 > lmin) & (l2 < lmax)
        )
        fi[i] = f[i0] * l0[i] + f[i1] * l1[i] + f[i2] * l2[i]

    return fi
