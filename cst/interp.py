"""
Interpolation functions
"""
import numpy


def interp1(extent, f, x, out=float('nan'), method='linear'):
    """
    1D piecewise interpolation of function values specified on regular grid.
    extent: Range (xmin, xmax) of coordinate space covered by `f`.
    f: Array of regularly spaced data values to be interpolated.
    x: Array of coordinates for the interpolation points.
    out: Output array for the interpolated values or no-data-value.
    method: Interpolation method, 'nearest' or 'linear'.
    """
    f = numpy.asarray(f)
    x = numpy.asarray(x)
    if f.size == 0:
        if isinstance(out, (int, float)):
            f = numpy.empty(x.shape, type(out))
            f.fill(out)
        return f
    lx = f.shape[0] - 1
    x0, x1 = extent
    i = (x >= x0) & (x <= x1)
    x = (x - x0) * lx / (x1 - x0)
    if method == 'nearest':
        x = numpy.maximum(0, (x + 0.5).astype('i'))
        x = numpy.minimum(x, lx)
        f = f[x]
    elif method == 'linear':
        j = numpy.maximum(0, x.astype('i'))
        j = numpy.minimum(j, lx - 1)
        x = x - j
        f = (1 - x) * f[j] + x * f[j+1]
    else:
        raise Exception('Unknown method: %s' % method)
    i &= f == f
    if isinstance(out, (int, float)):
        f[~i] = out
        return f
    out[i] = f[i]
    return out


def interp2(extent, f, x, out=float('nan'), method='nearest'):
    f = numpy.asarray(f)
    x, y = numpy.asarray(x)
    if f.size == 0:
        if isinstance(out, (int, float)):
            f = numpy.empty(x.shape, type(out))
            f.fill(out)
        return f
    lx, ly = f.shape
    lx, ly = lx - 1, ly - 1
    [x0, x1], [y0, y1] = extent
    i = (x >= x0) & (x <= x1) & (y >= y0) & (y <= y1)
    x = (x - x0) * lx / (x1 - x0)
    y = (y - y0) * ly / (y1 - y0)
    if method == 'nearest':
        x = numpy.maximum(0, (x + 0.5).astype('i'))
        y = numpy.maximum(0, (y + 0.5).astype('i'))
        x = numpy.minimum(x, lx)
        y = numpy.minimum(y, ly)
        f = f[x, y]
    elif method == 'linear':
        j = numpy.maximum(0, x.astype('i'))
        k = numpy.maximum(0, y.astype('i'))
        j = numpy.minimum(j, lx - 1)
        k = numpy.minimum(k, ly - 1)
        x = x - j
        y = y - k
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
    f = numpy.asarray(f)
    x, y, z = numpy.asarray(x)
    if f.size == 0:
        if isinstance(out, (int, float)):
            f = numpy.empty(x.shape, type(out))
            f.fill(out)
        return f
    lx, ly, lz = f.shape
    lx, ly, lz = lx - 1, ly - 1, lz - 1
    [x0, x1], [y0, y1], [z0, z1] = extent
    i = (x >= x0) & (x <= x1) & (y >= y0) & (y <= y1) & (z >= z0) & (z <= z1)
    x = (x - x0) * lx / (x1 - x0)
    y = (y - y0) * ly / (y1 - y0)
    z = (z - z0) * lz / (z1 - z0)
    if method == 'nearest':
        x = numpy.maximum(0, (x + 0.5).astype('i'))
        y = numpy.maximum(0, (y + 0.5).astype('i'))
        z = numpy.maximum(0, (z + 0.5).astype('i'))
        x = numpy.minimum(x, lx)
        y = numpy.minimum(y, ly)
        z = numpy.minimum(z, lz)
        f = f[x, y, z]
    elif method == 'linear':
        j = numpy.maximum(0, x.astype('i'))
        k = numpy.maximum(0, y.astype('i'))
        l = numpy.maximum(0, z.astype('i'))
        j = numpy.minimum(j, lx - 1)
        k = numpy.minimum(k, ly - 1)
        l = numpy.minimum(l, lz - 1)
        x = x - j
        y = y - k
        z = z - l
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
        fi = numpy.empty_like(xi[..., 0])
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
