"""
Interpolation functions
"""
import numpy as np


def interp1(x, f, xi, fi=None, method='nearest'):
    """
    1D piecewise interpolation of function values specified on regular grid.
    xlim: Range (x_min, x_max) of coordinate space covered by `f`.
    f: Array of regularly spaced data values to be interpolated.
    xi: Array of coordinates for the interpolation points, same shape as `fi`.
    fi: Output array for the interpolated values, same shape as `xi`.
    method: Interpolation method, 'nearest' or 'linear'.
    Returns an array of interpolated values, same shape as `xi`.
    """
    xi = np.asarray(xi)
    if f.size == 0:
        if fi is None:
            fi = np.empty_like(xi)
            fi.fill(float('nan'))
        return fi
    x = np.asarray(x)
    f = np.asarray(f)
    n = np.array(f.shape)
    xi = (xi - x[0]) / (x[1] - x[0]) * (n - 1)
    if method == 'nearest':
        i = (xi + 0.5).astype('i')
        i = np.maximum(i, 0)
        i = np.minimum(i, n - 1)
        f = f[i]
    elif method == 'linear':
        i = xi.astype('i')
        i = np.maximum(i, 0)
        i = np.minimum(i, n - 2)
        x = xi - i
        f = (1 - x) * f[i] + x * f[i+1]
    else:
        raise Exception('Unknown interpolation method: %s' % method)
    if fi is None:
        fi = np.empty_like(xi)
        fi.fill(float('nan'))
    i = f == f & xi >= 0 & xi <= n - 1
    fi[i] = f[i]

    return fi


def interp2(x, f, xi, fi=None, method='nearest'):
    xi = np.asarray(xi)
    if f.size == 0:
        if fi is None:
            fi = np.empty_like(xi[..., 0])
            fi.fill(float('nan'))
        return fi
    x = np.asarray(x)
    f = np.asarray(f)
    n = np.array(f.shape)
    xi = (xi - x[0]) / (x[1] - x[0]) * (n - 1)
    if method == 'nearest':
        i = (xi + 0.5).astype('i')
        i = np.maximum(i, 0)
        i = np.minimum(i, n - 1)
        j, k = i.T
        f = f[j, k]
    elif method == 'linear':
        i = xi.astype('i')
        i = np.maximum(i, 0)
        i = np.minimum(i, n - 2)
        j, k = i.T
        x, y = (xi - i).T
        f = (
            (1 - x) * (1 - y) * f[j, k] +
            (1 - x) * y * f[j, k+1] +
            x * (1 - y) * f[j+1, k] +
            x * y * f[j+1, k+1]
        )
    else:
        raise Exception('Unknown interpolation method: %s' % method)
    if fi is None:
        fi = np.empty_like(xi)
        fi.fill(float('nan'))
    i = f == f & xi >= 0 & xi <= n - 1
    fi[i] = f[i]
    return fi


def interp3(x, f, xi, fi=None, method='nearest'):
    xi = np.asarray(xi)
    if f.size == 0:
        if fi is None:
            fi = np.empty_like(xi[..., 0])
            fi.fill(float('nan'))
        return fi
    x = np.asarray(x)
    f = np.asarray(f)
    n = np.array(f.shape)
    xi = (xi - x[0]) / (x[1] - x[0]) * (n - 1)
    if method == 'nearest':
        i = (xi + 0.5).astype('i')
        i = np.maximum(i, 0)
        i = np.minimum(i, n - 1)
        j, k, l = i.T
        f = f[j, k, l]
    elif method == 'linear':
        i = xi.astype('i')
        i = np.maximum(i, 0)
        i = np.minimum(i, n - 2)
        j, k, l = i.T
        x, y, z = (xi - i).T
        f = (
            (1 - x) * (1 - y) * (1 - z) * f[j, k, l] +
            (1 - x) * (1 - y) * z * f[j, k, l+1] +
            (1 - x) * y * (1 - z) * f[j, k+1, l] +
            (1 - x) * y * z * f[j, k+1, l+1] +
            x * (1 - y) * (1 - z) * f[j+1, k, l] +
            x * (1 - y) * z * f[j+1, k, l+1] +
            x * y * (1 - z) * f[j+1, k+1, l] +
            x * y * z * f[j+1, k+1, l+1]
        )
    else:
        raise Exception('Unknown interpolation method: %s' % method)
    if fi is None:
        fi = np.empty_like(xi[..., 0])
        fi.fill(float('nan'))
    i = f == f & xi >= 0 & xi <= n - 1
    fi[i] = f[i]
    return fi


def interp_tri(x, f, t, xi, fi=None):
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
        fi.fill(float('nan'))
    lmin = -0.000001
    lmax = 1.000001
    for i0, i1, i2 in t:
        A00 = x[i1, 0] - x[i0, 0]
        A01 = x[i2, 0] - x[i0, 0]
        A10 = x[i1, 1] - x[i0, 1]
        A11 = x[i2, 1] - x[i0, 1]
        d = A00 * A11 - A01 * A10
        i = d != 0.0
        d[i] = 1.0 / d[i]
        b = xi - x[i0]
        l1 = d * A11 * b[..., 0] - d * A01 * b[..., 1]
        l2 = d * A00 * b[..., 1] - d * A10 * b[..., 0]
        l0 = 1.0 - l1 - l2
        i = (
            (l0 > lmin) & (l0 < lmax) &
            (l1 > lmin) & (l1 < lmax) &
            (l2 > lmin) & (l2 < lmax)
        )
        fi[i] = f[i0] * l0[i] + f[i1] * l1[i] + f[i2] * l2[i]
    return fi
