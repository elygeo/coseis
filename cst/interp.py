"""
Interpolation functions
"""
import numpy as np


def interp1(extent, f, x, out=float('nan'), method='linear'):
    """
    1D piecewise interpolation of function values specified on regular grid.
    extent: Range (xmin, xmax) of coordinate space covered by `f`.
    f: Array of regularly spaced data values to be interpolated.
    x: Array of coordinates for the interpolation points.
    out: Output array for the interpolated values or no-data-value.
    method: Interpolation method, 'nearest' or 'linear'.
    """
    f = np.asarray(f)
    x = np.asarray(x)
    if f.size == 0:
        if isinstance(out, (int, float)):
            n = x.shape + f.shape[1:]
            f = np.empty(n, type(out))
            f.fill(out)
        return f
    m = len(f.shape) - 1
    n = f.shape[0] - 1
    a, b = extent
    i = (x >= a) & (x <= b)
    i = i.reshape(i.shape + m * (1,))
    d = b - a
    x = (x - a) * n
    if method == 'nearest':
        x = ((x + d / 2) / d).astype('i')
        x = np.maximum(x, 0)
        x = np.minimum(x, n)
        f = f[x]
    elif method == 'linear':
        j = (x / d).astype('i')
        j = np.maximum(j, 0)
        j = np.minimum(j, n - 1)
        n = x.shape + m * (1,)
        x = (x - d * j).reshape(n)
        f = ((d - x) * f[j] + x * f[j+1]) / d
    else:
        raise Exception('Unknown method: %s' % method)
    i = i & (f == f)
    if isinstance(out, (int, float)):
        f[~i] = out
        return f
    out[i] = f[i]
    return out


def interp2(extent, f, x, out=float('nan'), method='nearest'):
    f = np.asarray(f)
    x = np.asarray(x)
    if f.size == 0:
        if isinstance(out, (int, float)):
            n = x.shape[:-1] + f.shape[2:]
            f = np.empty(n, type(out))
            f.fill(out)
        return f
    m = len(f.shape) - 2
    n = np.array(f.shape[:2]) - 1
    a, b = np.asarray(extent)
    i = ((x >= a) & (x <= b)).min(-1)
    i = i.reshape(i.shape + m * (1,))
    x = (x - a) * n / (b - a)
    if method == 'nearest':
        x = (x + 0.5).astype('i')
        x = np.maximum(x, 0)
        x = np.minimum(x, n)
        x, y = np.rollaxis(x, -1)
        f = f[x, y]
    elif method == 'linear':
        j = x.astype('i')
        j = np.maximum(j, 0)
        j = np.minimum(j, n - 1)
        n = x.shape[-1:] + x.shape[:-1] + m * (1,)
        x, y = np.rollaxis(x - j, -1).reshape(n)
        j, k = np.rollaxis(j, -1)
        f = (
            (1 - x) * (1 - y) * f[j, k] +
            (1 - x) * y * f[j, k+1] +
            x * (1 - y) * f[j+1, k] +
            x * y * f[j+1, k+1]
        )
    else:
        raise Exception('Unknown method: %s' % method)
    i &= f == f
    if isinstance(out, (int, float)):
        f[~i] = out
        return f
    out[i] = f[i]
    return out


def interp3(extent, f, x, out=float('nan'), method='nearest'):
    f = np.asarray(f)
    x = np.asarray(x)
    if f.size == 0:
        if isinstance(out, (int, float)):
            n = x.shape[:-1] + f.shape[3:]
            f = np.empty(n, type(out))
            f.fill(out)
        return f
    m = len(f.shape) - 3
    n = np.array(f.shape[:3]) - 1
    a, b = np.asarray(extent)
    i = ((x >= a) & (x <= b)).min(-1)
    i = i.reshape(i.shape + m * (1,))
    x = (x - a) * n / (b - a)
    if method == 'nearest':
        x = (x + 0.5).astype('i')
        x = np.maximum(x, 0)
        x = np.minimum(x, n)
        x, y, z = np.rollaxis(x, -1)
        f = f[x, y, z]
    elif method == 'linear':
        j = x.astype('i')
        j = np.maximum(j, 0)
        j = np.minimum(j, n - 1)
        n = x.shape[-1:] + x.shape[:-1] + m * (1,)
        x, y, z = np.rollaxis(x - j, -1).reshape(n)
        j, k, l = np.rollaxis(j, -1)
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
        raise Exception('Unknown method: %s' % method)
    i &= f == f
    if isinstance(out, (int, float)):
        f[~i] = out
        return f
    out[i] = f[i]
    return out


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
