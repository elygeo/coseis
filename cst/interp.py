"""
Interpolation tools.
"""

import sys
while '' in sys.path:
    sys.path.remove('')
import os

try:
    from cst.interp_ import trinterp
except ImportError:
    from distutils.core import setup, Extension
    import numpy as np
    cwd = os.getcwd()
    os.chdir(os.path.dirname(__file__))
    incl = [np.get_include()]
    ext = [Extension('interp_', ['interp_.c'], include_dirs=incl)]
    setup(ext_modules=ext, script_args=['build_ext', '--inplace'])
    os.chdir(cwd)
    from cst.interp_ import trinterp


def interp1(
  xlim, f, xi, fi=None, method='nearest', bound=False, mask=False,
  no_data_val='nan'):
    """
    1D piecewise interpolation of function values specified on regular grid.
    xlim: Range (x_min, x_max) of coordinate space covered by `f`.
    f: Array of regularly spaced data values to be interpolated.
    xi: Array of coordinates for the interpolation points, same shape as `fi`.
    fi: Output array for the interpolated values, same shape as `xi`.
    method: Interpolation method, 'nearest' or 'linear'.
    bound: If true, do not extrapolation values outside the coordinate range. A
        tuple species the left and right boundaries independently.
    mask: If true and `fi` is passed, non_data_vals are masked from output.
    no_data_val: value to insert for empty data.
    Returns an array of interpolated values, same shape as `xi`.
    """
    import numpy as np
    f = np.asarray(f)
    xi = np.asarray(xi)

    # test for empty data
    if no_data_val == 'nan':
        no_data_val = float('nan')
    if f.size == 0:
        if fi is None:
            fi = np.empty_like(xi)
            fi.fill(no_data_val)
        return fi

    # logical coordinates
    nx = f.shape[-1]
    x_ = xlim
    x = xi
    del(xi)
    x = (x - x_[0]) / (x_[1] - x_[0]) * (nx - 1)

    # compute mask
    m = False
    if not isinstance(bound, (tuple, list)):
        bound = bound, bound
    if bound[0]:
        m = m | (x < 0)
    if bound[1]:
        m = m | (x > nx - 1)
    x = np.minimum(np.maximum(x, 0), nx - 1)

    # NaNs
    nans = np.isnan(x)
    x[nans] = 0.0

    # interpolation
    if method == 'nearest':
        j = (x + 0.5).astype('i')
        f = f[..., j]
    elif method == 'linear':
        j = np.minimum(x.astype('i'), nx - 2)
        f = (1.0 - x + j) * f[..., j] + (x - j) * f[..., j+1]
    else:
        raise Exception('Unknown interpolation method: %s' % method)
    del(j, x)

    # apply mask
    if fi is None:
        nans = nans | m
        f[..., nans] = no_data_val
        fi = f
    else:
        if not mask:
            f[..., nans] = no_data_val
        elif str(no_data_val) == 'nan':
            m = m | nans | np.isnan(f)
        else:
            m = m | nans | (f == no_data_val)
        if m is False:
            fi[...] = f[...]
        else:
            fi[..., ~m] = f[..., ~m]
    return fi


def interp2(
  xlim, f, xi, fi=None, method='nearest', bound=False, mask=False,
  no_data_val='nan'):
    """
    2D piecewise interpolation of function values specified on regular grid.
    See 1D interp for documentation.
    """
    import numpy as np
    f = np.asarray(f)
    xi = np.asarray(xi)

    # test for empty data
    if no_data_val == 'nan':
        no_data_val = float('nan')
    if f.size == 0:
        if fi is None:
            fi = np.empty_like(xi[0])
            fi.fill(no_data_val)
        return fi

    # logical coordinates
    nx, ny = f.shape[-2:]
    x_, y_ = xlim
    x, y = xi
    del(xi)
    x = (x - x_[0]) / (x_[1] - x_[0]) * (nx - 1)
    y = (y - y_[0]) / (y_[1] - y_[0]) * (ny - 1)

    # compute mask
    m = False
    if not isinstance(bound, (tuple, list)):
        bound = [(bound, bound)] * 2
    bx, by = bound
    if bx[0]:
        m = m | (x < 0)
    if by[0]:
        m = m | (y < 0)
    if bx[1]:
        m = m | (x > nx - 1)
    if by[1]:
        m = m | (y > ny - 1)
    x = np.minimum(np.maximum(x, 0), nx - 1)
    y = np.minimum(np.maximum(y, 0), ny - 1)

    # NaNs
    nans = np.isnan(x) | np.isnan(y)
    x[nans] = 0.0
    y[nans] = 0.0

    # interpolation
    if method == 'nearest':
        j = (x + 0.5).astype('i')
        k = (y + 0.5).astype('i')
        f = f[..., j, k]
    elif method == 'linear':
        j = np.minimum(x.astype('i'), nx - 2)
        k = np.minimum(y.astype('i'), ny - 2)
        f = (
            (1.0 - x + j) * (1.0 - y + k) * f[..., j, k] +
            (1.0 - x + j) * (y - k) * f[..., j, k+1] +
            (x - j) * (1.0 - y + k) * f[..., j+1, k] +
            (x - j) * (y - k) * f[..., j+1, k+1]
        )
    else:
        raise Exception('Unknown interpolation method: %s' % method)
    del(j, k, x, y)

    # apply mask
    if fi is None:
        nans = nans | m
        f[..., nans] = no_data_val
        fi = f
    else:
        if not mask:
            f[..., nans] = no_data_val
        elif str(no_data_val) == 'nan':
            m = m | nans | np.isnan(f)
        else:
            m = m | nans | (f == no_data_val)
        if m is False:
            fi[...] = f[...]
        else:
            fi[..., ~m] = f[..., ~m]
    return fi


def interp3(
  xlim, f, xi, fi=None, method='nearest', bound=False, mask=False,
  no_data_val='nan'):
    """
    3D piecewise interpolation of function values specified on regular grid.
    See 1D interp for documentation.
    """
    import numpy as np

    f = np.asarray(f)
    xi = np.asarray(xi)

    # test for empty data
    if no_data_val == 'nan':
        no_data_val = float('nan')
    if f.size == 0:
        if fi is None:
            fi = np.empty_like(xi[0])
            fi.fill(no_data_val)
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
    m = False
    if isinstance(bound, (tuple, list)):
        bound = [(bound, bound)] * 3
    bx, by, bz = bound
    if bx[0]:
        m = m | (x < 0)
    if by[0]:
        m = m | (y < 0)
    if bz[0]:
        m = m | (z < 0)
    if bx[1]:
        m = m | (x > nx - 1)
    if by[1]:
        m = m | (y > ny - 1)
    if bz[1]:
        m = m | (z > nz - 1)
    x = np.minimum(np.maximum(x, 0), nx - 1)
    y = np.minimum(np.maximum(y, 0), ny - 1)
    z = np.minimum(np.maximum(z, 0), nz - 1)

    # NaNs
    nans = np.isnan(x) | np.isnan(y) | np.isnan(z)
    x[nans] = 0.0
    y[nans] = 0.0
    z[nans] = 0.0

    # interpolation
    if method == 'nearest':
        j = (x + 0.5).astype('i')
        k = (y + 0.5).astype('i')
        l = (z + 0.5).astype('i')
        f = f[..., j, k, l]
    elif method == 'linear':
        j = np.minimum(x.astype('i'), nx - 2)
        k = np.minimum(y.astype('i'), ny - 2)
        l = np.minimum(z.astype('i'), nz - 2)
        f = (
            (1.0 - x + j) * (1.0 - y + k) * (1.0 - z + l) * f[..., j, k, l] +
            (1.0 - x + j) * (1.0 - y + k) * (z - l) * f[..., j, k, l+1] +
            (1.0 - x + j) * (y - k) * (1.0 - z + l) * f[..., j, k+1, l] +
            (1.0 - x + j) * (y - k) * (z - l) * f[..., j, k+1, l+1] +
            (x - j) * (1.0 - y + k) * (1.0 - z + l) * f[..., j+1, k, l] +
            (x - j) * (1.0 - y + k) * (z - l) * f[..., j+1, k, l+1] +
            (x - j) * (y - k) * (1.0 - z + l) * f[..., j+1, k+1, l] +
            (x - j) * (y - k) * (z - l) * f[..., j+1, k+1, l+1]
        )
    else:
        raise Exception('Unknown interpolation method: %s' % method)
    del(j, k, l, x, y, z)

    # apply mask
    if fi is None:
        nans = nans | m
        f[..., nans] = no_data_val
        fi = f
    else:
        if not mask:
            f[..., nans] = no_data_val
        elif str(no_data_val) == 'nan':
            m = m | nans | np.isnan(f)
        else:
            m = m | nans | (f == no_data_val)
        if m is False:
            fi[...] = f[...]
        else:
            fi[..., ~m] = f[..., ~m]
    return fi


def trinterp_np(x, f, t, xi, fi=None, no_data_val=float('nan')):
    """
    2D linear interpolation of function values specified on triangular mesh.
    x:  shape (2, M) array of vertex coordinates.
    f:  shape (M) array of function values at the vertices.
    t:  shape (3, N) array of vertex indices for the triangles.
    xi: shape (2, ...) array of coordinates for the interpolation points.
    Returns array of interpolated values, same shape as `xi[0]`.
    Note: This is the NumPy version. The Cython version is faster.
    """
    import numpy as np

    x, y = x
    xi, yi = xi
    if fi is None:
        fi = np.empty_like(xi)
        fi.fill(no_data_val)

    # tolerance
    lmin = -0.000001
    lmax = 1.000001

    # loop over triangles
    for i0, i1, i2 in t.T:

        # barycentric coordinates
        A00 = x[i1] - x[i0]
        A01 = x[i2] - x[i0]
        A10 = y[i1] - y[i0]
        A11 = y[i2] - y[i0]
        d = A00 * A11 - A01 * A10
        if d == 0.0:
            continue
        d = 1.0 / d
        b0 = xi - x[i0]
        b1 = yi - y[i0]
        l1 = d * A11 * b0 - d * A01 * b1
        l2 = d * A00 * b1 - d * A10 * b0
        l0 = 1.0 - l1 - l2

        # interpolate points inside triangle
        i = (
            (l0 > lmin) & (l0 < lmax) &
            (l1 > lmin) & (l1 < lmax) &
            (l2 > lmin) & (l2 < lmax)
        )
        fi[i] = f[i0] * l0[i] + f[i1] * l1[i] + f[i2] * l2[i]

    return fi


def ibilinear(xx, yy, xi, yi):
    """
    Vectorized inverse bilinear interpolation
    """
    import numpy as np

    xx = np.asarray(xx)
    yy = np.asarray(yy)
    xi = np.asarray(xi) - 0.25 * xx.sum(0).sum(0)
    yi = np.asarray(yi) - 0.25 * yy.sum(0).sum(0)
    j1 = 0.25 * np.array([
        [xx[1, :] - xx[0, :], xx[:, 1] - xx[:, 0]],
        [yy[1, :] - yy[0, :], yy[:, 1] - yy[:, 0]]
    ]).sum(2)
    j2 = 0.25 * np.array([
        xx[1, 1] - xx[0, 1] - xx[1, 0] + xx[0, 0],
        yy[1, 1] - yy[0, 1] - yy[1, 0] + yy[0, 0]
    ])
    x = dx = solve2(j1, [xi, yi])
    i = 0
    while(abs(dx).max() > 1e-6):
        i += 1
        if i > 10:
            raise Exception('inverse bilinear interpolation did not converge')
        j = [
            [j1[0, 0] + j2[0] * x[1], j1[0, 1] + j2[0] * x[0]],
            [j1[1, 0] + j2[1] * x[1], j1[1, 1] + j2[1] * x[0]]
        ]
        b = [
            xi - j1[0, 0] * x[0] - j1[0, 1] * x[1] - j2[0] * x[0] * x[1],
            yi - j1[1, 0] * x[0] - j1[1, 1] * x[1] - j2[1] * x[0] * x[1]
        ]
        dx = solve2(j, b)
        x[0] += dx[0]
        x[1] += dx[1]
    return x


def solve2(A, b):
    """
    2 by 2 linear equation solver. Components may be scalars or numpy arrays.
    """
    d = 1.0 / (A[0, 0] * A[1, 1] - A[0, 1] * A[1, 0])
    x = [
        d * A[1, 1] * b[0] - d * A[0, 1] * b[1],
        d * A[0, 0] * b[1] - d * A[1, 0] * b[0],
    ]
    return x
